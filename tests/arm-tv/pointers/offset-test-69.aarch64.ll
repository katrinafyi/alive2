; ModuleID = 'foo.c'
source_filename = "foo.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx13.0.0"

%struct.s = type { i16, i8, i16, i8, i64, i16, i8, i32 }

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp uwtable willreturn
define void @f(%struct.s* nocapture %0) local_unnamed_addr #0 {
  %2 = getelementptr inbounds %struct.s, %struct.s* %0, i64 0, i32 7
  store i32 0, i32* %2, align 4
  %3 = getelementptr inbounds %struct.s, %struct.s* %0, i64 0, i32 2
  %4 = load i16, i16* %3, align 4
  %5 = sext i16 %4 to i32
  %6 = getelementptr inbounds %struct.s, %struct.s* %0, i64 0, i32 3
  %7 = load i8, i8* %6, align 2
  %8 = sext i8 %7 to i32
  %9 = add nsw i32 %8, %5
  store i32 %9, i32* %2, align 4
  %10 = trunc i32 %9 to i8
  store i8 %10, i8* %6, align 2
  %11 = getelementptr inbounds %struct.s, %struct.s* %0, i64 0, i32 1
  store i8 %10, i8* %11, align 2
  %12 = sext i32 %9 to i64
  %13 = getelementptr inbounds %struct.s, %struct.s* %0, i64 0, i32 4
  store i64 %12, i64* %13, align 8
  %14 = getelementptr inbounds %struct.s, %struct.s* %0, i64 0, i32 6
  store i8 %10, i8* %14, align 2
  %15 = getelementptr inbounds %struct.s, %struct.s* %0, i64 0, i32 0
  %16 = load i16, i16* %15, align 8
  %17 = sext i16 %16 to i32
  %18 = shl nsw i32 %17, 1
  %19 = add nsw i32 %18, %9
  %20 = getelementptr inbounds %struct.s, %struct.s* %0, i64 0, i32 5
  %21 = load i16, i16* %20, align 8
  %22 = zext i16 %21 to i32
  %23 = add nsw i32 %19, %22
  %24 = trunc i32 %23 to i8
  store i8 %24, i8* %14, align 2
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
