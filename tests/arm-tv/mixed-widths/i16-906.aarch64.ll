; TEST-ARGS:

target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

define i16 @f(i16 %0, i16 %1) {
  %3 = call i16 @llvm.fshr.i16(i16 %0, i16 -32768, i16 %1)
  ret i16 %3
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare i16 @llvm.fshr.i16(i16, i16, i16) #0

attributes #0 = { nofree nosync nounwind readnone speculatable willreturn }
