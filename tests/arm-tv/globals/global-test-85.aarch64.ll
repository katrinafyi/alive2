; ModuleID = 'foo.c'
source_filename = "foo.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx13.0.0"

%struct.anon = type { i32, i32, i64, i64, i16, i16, i16, i8 }

@s = common local_unnamed_addr global %struct.anon zeroinitializer, align 8

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp uwtable willreturn
define zeroext i8 @f(i8 zeroext %0) local_unnamed_addr #0 {
  %2 = load i16, i16* getelementptr inbounds (%struct.anon, %struct.anon* @s, i64 0, i32 5), align 2
  %3 = trunc i16 %2 to i8
  %4 = add i8 %3, %0
  %5 = load i64, i64* getelementptr inbounds (%struct.anon, %struct.anon* @s, i64 0, i32 3), align 8
  %6 = trunc i64 %5 to i8
  %7 = add i8 %4, %6
  %8 = zext i8 %7 to i16
  store i16 %8, i16* getelementptr inbounds (%struct.anon, %struct.anon* @s, i64 0, i32 6), align 4
  %9 = load i32, i32* getelementptr inbounds (%struct.anon, %struct.anon* @s, i64 0, i32 1), align 4
  %10 = trunc i32 %9 to i8
  %11 = add i8 %7, %10
  store i8 %11, i8* getelementptr inbounds (%struct.anon, %struct.anon* @s, i64 0, i32 7), align 2
  %12 = load i64, i64* getelementptr inbounds (%struct.anon, %struct.anon* @s, i64 0, i32 2), align 8
  %13 = trunc i64 %12 to i8
  %14 = add i8 %11, %13
  %15 = zext i8 %14 to i16
  store i16 %15, i16* getelementptr inbounds (%struct.anon, %struct.anon* @s, i64 0, i32 6), align 4
  %16 = add i8 %10, %6
  %17 = add i8 %16, %13
  %18 = add i8 %17, %14
  %19 = zext i8 %18 to i16
  store i16 %19, i16* getelementptr inbounds (%struct.anon, %struct.anon* @s, i64 0, i32 5), align 2
  store i16 %19, i16* getelementptr inbounds (%struct.anon, %struct.anon* @s, i64 0, i32 6), align 4
  ret i8 %18
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
