; ModuleID = 'foo.c'
source_filename = "foo.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx13.0.0"

%struct.anon = type { i32, i8, i16, i16, i32, i64, i32, i8 }

@s = common local_unnamed_addr global %struct.anon zeroinitializer, align 8

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp uwtable willreturn
define signext i16 @f(i16 signext %0) local_unnamed_addr #0 {
  %2 = trunc i16 %0 to i8
  store i8 %2, i8* getelementptr inbounds (%struct.anon, %struct.anon* @s, i64 0, i32 7), align 4
  %3 = load i32, i32* getelementptr inbounds (%struct.anon, %struct.anon* @s, i64 0, i32 4), align 4
  %4 = trunc i32 %3 to i16
  %5 = add i16 %4, %0
  %6 = load i16, i16* getelementptr inbounds (%struct.anon, %struct.anon* @s, i64 0, i32 2), align 2
  %7 = add i16 %5, %6
  %8 = load i16, i16* getelementptr inbounds (%struct.anon, %struct.anon* @s, i64 0, i32 3), align 8
  %9 = add i16 %7, %8
  %10 = trunc i16 %9 to i8
  store i8 %10, i8* getelementptr inbounds (%struct.anon, %struct.anon* @s, i64 0, i32 1), align 4
  %11 = sext i8 %10 to i16
  %12 = add i16 %9, %11
  %13 = trunc i16 %12 to i8
  store i8 %13, i8* getelementptr inbounds (%struct.anon, %struct.anon* @s, i64 0, i32 7), align 4
  store i8 %13, i8* getelementptr inbounds (%struct.anon, %struct.anon* @s, i64 0, i32 1), align 4
  %14 = add i16 %12, %6
  %15 = sext i8 %13 to i16
  %16 = add i16 %14, %15
  %17 = sext i16 %16 to i32
  store i32 %17, i32* getelementptr inbounds (%struct.anon, %struct.anon* @s, i64 0, i32 4), align 4
  %18 = load i64, i64* getelementptr inbounds (%struct.anon, %struct.anon* @s, i64 0, i32 5), align 8
  %19 = trunc i64 %18 to i16
  %20 = add i16 %16, %19
  ret i16 %20
}

attributes #0 = { mustprogress nofree norecurse nosync nounwind ssp uwtable willreturn "frame-pointer"="non-leaf" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7, !8}
!llvm.ident = !{!9}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 13, i32 1]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 1, !"branch-target-enforcement", i32 0}
!3 = !{i32 1, !"sign-return-address", i32 0}
!4 = !{i32 1, !"sign-return-address-all", i32 0}
!5 = !{i32 1, !"sign-return-address-with-bkey", i32 0}
!6 = !{i32 7, !"PIC Level", i32 2}
!7 = !{i32 7, !"uwtable", i32 1}
!8 = !{i32 7, !"frame-pointer", i32 1}
!9 = !{!"Apple clang version 14.0.0 (clang-1400.0.29.202)"}
