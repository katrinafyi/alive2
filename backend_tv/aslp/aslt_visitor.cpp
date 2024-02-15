#include "aslt_visitor.hpp"
#include "aslp/interface.hpp"
#include "tree/TerminalNode.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Instructions.h"

#include <format>
#include <llvm/IR/Constants.h>
#include <llvm/Support/Casting.h>

#include <ranges>

using namespace aslt;

namespace {
  antlr4::tree::TerminalNode* OR(antlr4::tree::TerminalNode* x, antlr4::tree::TerminalNode* y) {
    return x ? x : y;
  }


 [[noreturn]] void die(llvm::Value* val, const std::string_view& str) {
   std::cerr << "Assertion failure! " << str << std::endl;
   std::string s;
   llvm::raw_string_ostream os{s};
   val->print(os, true);
   std::cerr << s << std::endl;
   *(volatile int*)0 = 0xded;
   throw std::runtime_error("unreachable");
  }
}

namespace aslp {


std::pair<expr_t, expr_t> aslt_visitor::ptr_expr(llvm::Value* x) {
  lexpr_t base = nullptr;
  expr_t offset = nullptr;

  auto Add = llvm::BinaryOperator::BinaryOps::Add;
  if (auto add = llvm::dyn_cast<llvm::BinaryOperator>(x); add && add->getOpcode() == Add) {
    // undo the add instruction into a GEP operation
    auto _base = add->getOperand(0);
    offset = add->getOperand(1);

    add->eraseFromParent();
    base = ref_expr(_base);

  } else if (auto load = llvm::dyn_cast<llvm::LoadInst>(x); load) {
    auto wd = load->getType()->getIntegerBitWidth();
    base = ref_expr(load);
    offset = iface.getIntConst(0, wd);
  }

  assert(base && offset && "unable to coerce to pointer");
  auto load = iface.createLoad(base->getAllocatedType(), base);
  auto ptr = new llvm::IntToPtrInst(load, llvm::PointerType::get(context, 0), "", iface.get_bb());
  return {ptr, offset};
}

std::pair<llvm::Value*, llvm::Value*> aslt_visitor::unify_sizes(llvm::Value* x, llvm::Value* y) {
  auto ty1 = x->getType(), ty2 = y->getType();
  auto wd1 = ty1->getIntegerBitWidth(), wd2 = ty2->getIntegerBitWidth();

  if (wd1 < wd2) {
    x = iface.createSExt(x, ty2);
  } else if (wd2 < wd1) {
    y = iface.createSExt(y, ty1);
  }
  return std::make_pair(x, y);
}

std::any aslt_visitor::visitStmt(SemanticsParser::StmtContext *ctx) {
  return std::any_cast<stmt_t>(super::visitStmt(ctx));
}

std::any aslt_visitor::visitStmts(SemanticsParser::StmtsContext *ctx) {
  log() << "visitStmts " << '\n';

  // store and reset current bb to support nesting statements nicely
  auto bb = iface.get_bb();

  if (ctx == nullptr) {
    auto empty = new_stmt("stmtlist_empty");
    iface.set_bb(bb);
    return empty;
  }

  auto ctxs = ctx->stmt();
  assert(!ctxs.empty() && "statement list must not be empty!");

  stmt_counts[depth+1] = 0;
  stmt_t s = stmt(ctxs.at(0));
  for (auto& s2 : ctx->stmt() | std::ranges::views::drop(1)) {
    s = link(s, stmt(s2));
  }

  iface.set_bb(bb);
  return s;
}

std::any aslt_visitor::visitAssign(SemanticsParser::AssignContext *ctx) {
  log() << "visitAssign : " << ctx->getText() << '\n';

  stmt_t s = new_stmt("assign");
  auto lhs = lexpr(ctx->lexpr());
  auto rhs = expr(ctx->expr());

  iface.createStore(rhs, lhs);
  return s;
}

std::any aslt_visitor::visitConstDecl(SemanticsParser::ConstDeclContext *ctx) {
  log() << "visitConstDecl" << '\n';

  auto s = new_stmt("constdecl");
  type_t ty = type(ctx->type());
  auto rhs = expr(ctx->expr());

  auto name = ctx->METHOD()->getText();
  log() << name << '\n';

  auto v = new llvm::AllocaInst(ty, 0, name, s.second);
  new llvm::StoreInst(rhs, v, s.second);

  add_local(name, v);
  return s;
}

std::any aslt_visitor::visitVarDecl(SemanticsParser::VarDeclContext *ctx) {
  log() << "visitVarDecl" << '\n';

  auto s = new_stmt("vardecl");
  type_t ty = type(ctx->type());
  auto rhs = expr(ctx->expr());

  auto name = ctx->METHOD()->getText();
  log() << name << '\n';

  auto v = new llvm::AllocaInst(ty, 0, name, s.second);
  new llvm::StoreInst(rhs, v, s.second);

  add_local(name, v);
  return s;
}

std::any aslt_visitor::visitVarDeclsNoInit(SemanticsParser::VarDeclsNoInitContext *ctx) {
  log() << "visitVarDeclsNoInit" << '\n';

  auto s = new_stmt("vardeclnoinit");
  type_t ty = type(ctx->type());
  auto names = ctx->METHOD();

  for (auto namectx : names) {
    auto name = namectx->getText();
    log() << name << '\n';
    auto v = new llvm::AllocaInst(ty, 0, name, s.second);
    add_local(name, v);
  }

  return s;
}

std::any aslt_visitor::visitAssert(SemanticsParser::AssertContext *ctx) {
  log() << "visitAssert" << '\n';

  auto s = new_stmt("assert");
  auto c = expr(ctx->expr());
  iface.assertTrue(c);
  return s;
}

std::any aslt_visitor::visitCall_stmt(SemanticsParser::Call_stmtContext *ctx) {
  auto name = ctx->METHOD()->getText();
  log() << "visitCall_stmt" << '\n';

  auto s = new_stmt("call");

  auto args = map(ctx->expr(), &aslt_visitor::expr);
  auto targctxs = map(ctx->targs(), [](auto x) { return x->expr(); });
  auto targs = map(targctxs, &aslt_visitor::lit_int);

  if (args.size() == 4) {
    if (name == "Mem.set.0") {
      // Mem[] - assignment (write) form
      // ===============================
      // Perform a write of 'size' bytes. The byte order is reversed for a big-endian access.
      // Mem[bits(64) address, integer size, AccType acctype] = bits(size*8) value
      auto addr = args[0], bytes = args[1], acctype = args[2], val = args[3];

      auto size = llvm::cast<llvm::ConstantInt>(bytes)->getSExtValue();
      auto [ptr, offset] = ptr_expr(addr);
      iface.storeToMemoryValOffset(ptr, offset, size, val);
      return s;
    }
  }

  assert(false && "call stmt unsup");
}

std::any aslt_visitor::visitConditionalStmt(SemanticsParser::ConditionalStmtContext *ctx) {
  log() << "visitConditional_stmt" << '\n';

  auto entry = new_stmt("conditional");
  
  auto cond = expr(ctx->expr());
  assert(cond->getType()->getIntegerBitWidth() == 1 && "condition must have type i1");

  // NOTE! visitStmts will restore the bb after it concludes, i.e. reset to 'entry'
  auto tstmts = std::any_cast<stmt_t>(visitStmts(ctx->tcase));
  auto fstmts = std::any_cast<stmt_t>(visitStmts(ctx->fcase));

  iface.createBranch(cond, tstmts.first, fstmts.first);

  auto join = new_stmt("conditional_join");
  link(tstmts, join);
  link(fstmts, join);

  return static_cast<stmt_t>(std::make_pair(entry.first, join.second));
}

std::any aslt_visitor::visitType(SemanticsParser::TypeContext *ctx) {
  log() << "visitType" << ' ' << ctx->getText() << '\n';
  auto bits = lit_int(ctx->expr());
  return (type_t)llvm::Type::getIntNTy(context, bits);
}

std::any aslt_visitor::visitLExprVar(SemanticsParser::LExprVarContext *ctx) {
  log() << "visitLExprVar" << '\n';
  auto name = OR(ctx->METHOD(), ctx->SSYMBOL())->getText();

  if (locals.contains(name)) {
    return locals.at(name);
  } else if (name == "_R") {
    return xreg_sentinel;
  } else if (name == "PSTATE") {
    return pstate_sentinel;
  } else if (name == "_Z") {
    return vreg_sentinel;
  } else if (name == "SP_EL0") {
    return iface.get_reg(reg_t::X, 31);
  }
  assert(false && "lexprvar");
}

std::any aslt_visitor::visitLExprField(SemanticsParser::LExprFieldContext *ctx) {
  log() << "visitLExprField" << '\n';

  lexpr_t base = lexpr(ctx->lexpr());
  std::string field = ctx->SSYMBOL()->getText();

  if (base == pstate_sentinel) {
    if (field == "N") return iface.get_reg(reg_t::PSTATE, (int)pstate_t::N);
    if (field == "Z") return iface.get_reg(reg_t::PSTATE, (int)pstate_t::Z);
    if (field == "C") return iface.get_reg(reg_t::PSTATE, (int)pstate_t::C);
    if (field == "V") return iface.get_reg(reg_t::PSTATE, (int)pstate_t::V);
    assert(false && "pstate unexpect");
  }
  assert(false && "lexpr field unsup");
}

std::any aslt_visitor::visitLExprArray(SemanticsParser::LExprArrayContext *ctx) {
  log() << "visitLExprArray" << '\n';
  auto lhs = lexpr(ctx->lexpr());
  auto index = map(ctx->expr(), &aslt_visitor::lit_int);
  assert(index.size() == 1);

  if (lhs == xreg_sentinel) {
    return iface.get_reg(reg_t::X, index.at(0));
  } else if (lhs == vreg_sentinel) {
    return iface.get_reg(reg_t::V, index.at(0));
  }

  assert(false && "lexpr array unsup");
}

std::any aslt_visitor::visitExprVar(SemanticsParser::ExprVarContext *ctx) {
  log() << "visitExprVar " << ctx->getText() << '\n';
  auto name = OR(ctx->METHOD(), ctx->SSYMBOL())->getText();

  expr_t var;
  if (locals.contains(name))
    var = locals.at(name);
  else if (name == "_R")
    var = xreg_sentinel; // return X0 as a sentinel for all X registers
  else if (name == "_Z")
    var = vreg_sentinel;
  else if (name == "PSTATE")
    var = pstate_sentinel;
  else if (name == "SP_EL0")
    var = iface.get_reg(reg_t::X, 31);
  else 
    assert(false && "unsupported or undefined variable!");

  auto ptr = llvm::cast<llvm::AllocaInst>(var);
  return static_cast<expr_t>(iface.createLoad(ptr->getAllocatedType(), ptr));
}

std::any aslt_visitor::visitExprTApply(SemanticsParser::ExprTApplyContext *ctx) {
  auto name = ctx->METHOD()->getText();
  log() 
    << "visitExprTApply " 
    << std::format("{} [{} targs] ({} args)", name, ctx->targs().size(), ctx->expr().size())
    << std::endl;

  auto args = map(ctx->expr(), &aslt_visitor::expr);
  auto targctxs = map(ctx->targs(), [](auto x) { return x->expr(); });
  auto targs = map(targctxs, &aslt_visitor::lit_int);

  if (args.size() == 1) {
    auto x = args[0];
    if (name == "cvt_bool_bv.0") {
      assert(x->getType()->getIntegerBitWidth() == 1 && "size mismatch in cvt bv bool");
      return x;

    } else if (name == "not_bits.0" || name == "not_bool.0") {
      return static_cast<expr_t>(iface.createNot(x));

    } 
  } else if (args.size() == 2) {
    auto x = args[0], y = args[1];
    if (name == "SignExtend.0" && targs.size() == 2) {
      type_t finalty = llvm::Type::getIntNTy(context, targs[1]);
      assert(finalty != x->getType()); // it is undef to sext to the same size
      return static_cast<expr_t>(iface.createSExt(x, finalty));

    } else if (name == "ZeroExtend.0" && targs.size() == 2) {
      type_t finalty = llvm::Type::getIntNTy(context, targs[1]);
      assert(finalty != x->getType());
      return static_cast<expr_t>(iface.createZExt(x, finalty));

    } else if (name == "eq_bits.0") {
      return static_cast<expr_t>(iface.createICmp(llvm::CmpInst::Predicate::ICMP_EQ, x, y));

    } else if (name == "add_bits.0") {
      return static_cast<expr_t>(iface.createAdd(x, y));

    } else if (name == "sub_bits.0") {
      return static_cast<expr_t>(iface.createSub(x, y));

    } else if (name == "eor_bits.0") {
      return static_cast<expr_t>(iface.createBinop(x, y, llvm::BinaryOperator::BinaryOps::Xor));

    } else if (name == "and_bits.0" || name == "and_bool.0") {
      return static_cast<expr_t>(iface.createAnd(x, y));

    } else if (name == "or_bits.0" || name == "or_bool.0") {
      return static_cast<expr_t>(iface.createOr(x, y));

    } else if (name == "mul_bits.0") {
      return static_cast<expr_t>(iface.createMul(x, y));

    } else if (name == "slt_bits.0") {
      return static_cast<expr_t>(iface.createICmp(llvm::ICmpInst::Predicate::ICMP_SLT, x, y));

    } else if (name == "sle_bits.0") {
      return static_cast<expr_t>(iface.createICmp(llvm::ICmpInst::Predicate::ICMP_SLE, x, y));

    } else if (name == "lsl_bits.0") {
      std::tie(x, y) = unify_sizes(x, y);
      auto wd = x->getType()->getIntegerBitWidth();
      if (std::has_single_bit(wd))
        return static_cast<expr_t>(iface.createMaskedShl(x, y));
      auto max = iface.getIntConst(wd - 1, wd);
      auto ok = iface.createICmp(llvm::ICmpInst::Predicate::ICMP_ULE, y, max);
      auto shift = iface.createRawShl(x, y);
      auto zero = iface.getIntConst(0, wd);
      return static_cast<expr_t>(iface.createSelect(ok, shift, zero));

    } else if (name == "lsr_bits.0") {
      std::tie(x, y) = unify_sizes(x, y);
      auto wd = x->getType()->getIntegerBitWidth();
      if (std::has_single_bit(wd))
        return static_cast<expr_t>(iface.createMaskedLShr(x, y));
      auto max = iface.getIntConst(wd - 1, wd);
      auto ok = iface.createICmp(llvm::ICmpInst::Predicate::ICMP_ULE, y, max);
      auto shift = iface.createRawLShr(x, y);
      auto zero = iface.getIntConst(0, wd);
      return static_cast<expr_t>(iface.createSelect(ok, shift, zero));

    } else if (name == "asr_bits.0") {
      std::tie(x, y) = unify_sizes(x, y);
      auto wd = x->getType()->getIntegerBitWidth();
      if (std::has_single_bit(wd))
        return static_cast<expr_t>(iface.createMaskedAShr(x, y));
      auto max = iface.getIntConst(wd - 1, wd);
      auto ok = iface.createICmp(llvm::ICmpInst::Predicate::ICMP_ULE, y, max);
      auto shift = iface.createRawAShr(x, y);
      auto zero = iface.getIntConst(0, wd);
      return static_cast<expr_t>(iface.createSelect(ok, shift, zero));

    } else if (name == "append_bits.0") {
      auto upper = x, lower = y;

      auto upperwd = upper->getType()->getIntegerBitWidth();
      auto lowerwd = lower->getType()->getIntegerBitWidth();
      assert(upperwd > 0);
      assert (lowerwd > 0);

      auto finalty = iface.getIntTy(upperwd + lowerwd);

      upper = iface.createZExt(upper, finalty);
      upper = iface.createRawShl(upper, iface.getIntConst(lowerwd, upperwd + lowerwd));

      lower = iface.createZExt(lower, finalty);

      return static_cast<expr_t>(iface.createOr(upper, lower));

    } else if (name == "replicate_bits.0") {
      auto count = llvm::cast<llvm::ConstantInt>(y)->getSExtValue();

      auto basewd = x->getType()->getIntegerBitWidth() ;
      auto finalwd = basewd * count;
      auto finalty = iface.getIntTy(finalwd);

      auto base = iface.createZExt(x, finalty);
      expr_t ret = base;
      for (unsigned i = 1; i < count; i++) {
        auto shifted = iface.createRawShl(base, iface.getIntConst(basewd * i, finalwd));
        ret = iface.createOr(ret, shifted);
      }
      return ret;
    }
  } else if (args.size() == 3) {
    auto x = args[0], y = args[1], z = args[2];

    if (name == "Mem.read.0") {
      // Perform a read of 'size' bytes. The access byte order is reversed for a big-endian access.
      // Instruction fetches would call AArch64.MemSingle directly.
      // bits(size*8) Mem[bits(64) address, integer size, AccType acctype]

      auto size = llvm::cast<llvm::ConstantInt>(y);
      auto [ptr, offset] = ptr_expr(x);
      auto load = iface.makeLoadWithOffset(ptr, offset, size->getSExtValue());
      return static_cast<expr_t>(load);
    }
  }
  assert(false && "unsupported TAPPLY");
}

std::any aslt_visitor::visitExprSlices(SemanticsParser::ExprSlicesContext *ctx) {
  log() << "visitExprSlices" << '\n';
  auto base = expr(ctx->expr());
  auto sl = slice(ctx->slice_expr());
  // a slice is done by right shifting by the "low" value,
  // then, truncating to the "width" value
  auto lo = llvm::ConstantInt::get(base->getType(), sl.lo);
  auto wdty = llvm::Type::getIntNTy(context, sl.wd);
  auto shifted = !lo->isZeroValue() ? iface.createMaskedLShr(base, lo) : base;
  auto trunced = iface.createTrunc(shifted, wdty);
  return static_cast<expr_t>(trunced);
}

std::any aslt_visitor::visitExprField(SemanticsParser::ExprFieldContext *ctx) {
  log() << "visitExprField" << '\n';

  const static std::map<uint8_t, pstate_t> pstate_map{
    {'N', pstate_t::N}, {'Z', pstate_t::Z}, {'C', pstate_t::C}, {'V', pstate_t::V}, 
  };

  auto base = expr_var(ctx->expr());
  auto field = ctx->SSYMBOL()->getText();
  if (base == pstate_sentinel) {
    assert(field.length() == 1 && "pstate field name length unexpect");
    auto c = field.at(0);
    auto reg = iface.get_reg(reg_t::PSTATE, (unsigned)pstate_map.at(c));
    auto load = iface.createLoad(reg->getAllocatedType(), reg);
    return static_cast<expr_t>(load);
  }

  die(base, "expr field unsup");
}

std::any aslt_visitor::visitExprArray(SemanticsParser::ExprArrayContext *ctx) {
  // an array read is used for registers
  log() << "visitExprArray" << '\n';
  auto base = expr_var(ctx->base);

  assert(ctx->indices.size() == 1 && "array access has multiple indices");
  auto index = lit_int(ctx->indices.at(0));

  lexpr_t reg = nullptr;
  if (base == xreg_sentinel) {
    reg = iface.get_reg(reg_t::X, index);
  } else if (base == vreg_sentinel) {
    reg = iface.get_reg(reg_t::V, index);
  }
  assert(reg && "expr base array unsup");

  auto load = iface.createLoad(reg->getAllocatedType(), reg);
  return static_cast<expr_t>(load);
}
std::any aslt_visitor::visitExprLitInt(SemanticsParser::ExprLitIntContext *ctx) {
  log() << "visitExprLitInt >" << ctx->getText() << "<\n";
  // XXX: it is an error for LitInt to appear outside of types.
  auto i100 = llvm::Type::getIntNTy(context, 100);
  auto node = OR(ctx->DEC(), ctx->BINARY());
  return static_cast<expr_t>(llvm::ConstantInt::get(i100, node->getText(), 10));
}

std::any aslt_visitor::visitExprLitHex(SemanticsParser::ExprLitHexContext *ctx) {
  log() << "TODO visitExprLitHex" << '\n';
  assert(0);
  return super::visitExprLitHex(ctx);
}

std::any aslt_visitor::visitExprLitBits(SemanticsParser::ExprLitBitsContext *ctx) {
  log() << "visitExprLitBits" << '\n';

  auto isbit = [](char x) { return x == '1' || x == '0'; };
  auto filtered = ctx->BINARY()->getText() | std::ranges::views::filter(isbit);

  std::string s;
  std::ranges::copy(filtered, std::back_inserter(s));

  auto ty = llvm::Type::getIntNTy(context, s.length());
  return static_cast<expr_t>(llvm::ConstantInt::get(ty, s, 2));
}

std::any aslt_visitor::visitExprLitMask(SemanticsParser::ExprLitMaskContext *ctx) {
  log() << "TODO visitExprLitMask" << '\n';
  return super::visitExprLitMask(ctx);
}

std::any aslt_visitor::visitExprLitString(SemanticsParser::ExprLitStringContext *ctx) {
  log() << "TODO visitExprLitString" << '\n';
  return super::visitExprLitString(ctx);
}

std::any aslt_visitor::visitTargs(SemanticsParser::TargsContext *ctx) {
  // log() << "visitTargs" << '\n';
  return visitExpr(ctx->expr());
}

std::any aslt_visitor::visitSlice_expr(SemanticsParser::Slice_exprContext *ctx) {
  log() << "visitSlice_expr" << '\n';
  auto exprs = map(ctx->expr(), &aslt_visitor::lit_int);
  assert(exprs.size() == 2 && "surely not");
  return slice_t(exprs.at(0), exprs.at(1)); // implicit integer cast
}

std::any aslt_visitor::visitUuid(SemanticsParser::UuidContext *ctx) {
  log() << "TODO visitUuid" << '\n';
  return super::visitUuid(ctx);
}

}