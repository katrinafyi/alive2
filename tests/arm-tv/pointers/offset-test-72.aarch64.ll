; ModuleID = 'foo.c'
source_filename = "foo.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx13.0.0"

%struct.s = type { i64, i16, i8, i64, i32, i8, i64, i64 }

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp uwtable willreturn
define void @f(%struct.s* nocapture %0) local_unnamed_addr #0 {
  %2 = getelementptr inbounds %struct.s, %struct.s* %0, i64 0, i32 7
  %3 = load i64, i64* %2, align 8
  %4 = trunc i64 %3 to i32
  %5 = shl i64 %3, 32
  %6 = ashr exact i64 %5, 32
  store i64 %6, i64* %2, align 8
  %7 = getelementptr inbounds %struct.s, %struct.s* %0, i64 0, i32 1
  %8 = load i16, i16* %7, align 8
  %9 = zext i16 %8 to i32
  %10 = add nsw i32 %9, %4
  %11 = trunc i32 %10 to i16
  store i16 %11, i16* %7, align 8
  %12 = getelementptr inbounds %struct.s, %struct.s* %0, i64 0, i32 4
  store i32 %10, i32* %12, align 8
  %13 = getelementptr inbounds %struct.s, %struct.s* %0, i64 0, i32 5
  %14 = load i8, i8* %13, align 4
  %15 = zext i8 %14 to i32
  %16 = and i32 %10, 65535
  %17 = getelementptr inbounds %struct.s, %struct.s* %0, i64 0, i32 3
  %18 = load i64, i64* %17, align 8
  %19 = trunc i64 %18 to i32
  %20 = add i32 %16, %10
  %21 = add i32 %20, %15
  %22 = add i32 %21, %19
  %23 = trunc i32 %22 to i16
  store i16 %23, i16* %7, align 8
  %24 = sext i32 %22 to i64
  store i64 %24, i64* %2, align 8
  ret void
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
