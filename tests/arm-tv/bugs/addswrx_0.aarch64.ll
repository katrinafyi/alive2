; TEST-ARGS: --global-isel

target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

define i8 @f(i8 %0) {
  %2 = sub nuw nsw i8 127, %0
  %3 = call i8 @llvm.usub.sat.i8(i8 0, i8 %2)
  ret i8 %3
}

; Function Attrs: nocallback nofree nosync nounwind readnone speculatable willreturn
declare i8 @llvm.usub.sat.i8(i8, i8) #0

attributes #0 = { nocallback nofree nosync nounwind readnone speculatable willreturn }