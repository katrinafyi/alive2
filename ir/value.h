#pragma once

// Copyright (c) 2018-present The Alive2 Authors.
// Distributed under the MIT license that can be found in the LICENSE file.

#include "ir/state.h"
#include "ir/type.h"
#include "smt/expr.h"
#include <memory>
#include <ostream>
#include <string>

namespace smt { class Model; }

namespace IR {

class Value {
  std::unique_ptr<Type> type;
  std::string name;

protected:
  Value(std::unique_ptr<Type> &&type, std::string &&name,
        bool mk_unique_name = false);

  static std::string fresh_id();

public:
  unsigned bits() const { return type->bits(); }
  const std::string& getName() const { return name; }
  const Type& getType() const { return *type.get(); }
  Type& getWType() { return *type.get(); }

  virtual void print(std::ostream &os) const = 0;
  virtual StateValue toSMT(State &s) const = 0;
  virtual smt::expr getTypeConstraints() const = 0;
  virtual void fixupTypes(const smt::Model &m);
  virtual ~Value();

  static void reset_gbl_id();

  friend std::ostream& operator<<(std::ostream &os, const Value &val);
};


class IntConst final : public Value {
  int64_t val;

public:
  IntConst(std::unique_ptr<Type> &&type, int64_t val);
  void print(std::ostream &os) const override;
  StateValue toSMT(State &s) const override;
  smt::expr getTypeConstraints() const override;
};


class UndefValue final : public Value {
public:
  UndefValue(std::unique_ptr<Type> &&type);
  void print(std::ostream &os) const override;
  StateValue toSMT(State &s) const override;
  smt::expr getTypeConstraints() const override;

  static std::string getFreshName();
};


class PoisonValue final : public Value {
public:
  PoisonValue(std::unique_ptr<Type> &&type);
  void print(std::ostream &os) const override;
  StateValue toSMT(State &s) const override;
  smt::expr getTypeConstraints() const override;
};


class Input final : public Value {
public:
  Input(std::unique_ptr<Type> &&type, std::string &&name) :
    Value(std::move(type), std::move(name)) {}
  void print(std::ostream &os) const override;
  StateValue toSMT(State &s) const override;
  smt::expr getTypeConstraints() const override;
};

}
