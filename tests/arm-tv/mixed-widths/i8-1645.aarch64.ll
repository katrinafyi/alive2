; TEST-ARGS:

target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

define i8 @f(i1 %0) {
  %2 = sext i1 %0 to i8
  ret i8 %2
}
