; TEST-ARGS:

target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

define i64 @f(i64 %0) {
  %2 = shl i64 %0, -3258921464105135905
  ret i64 %2
}
