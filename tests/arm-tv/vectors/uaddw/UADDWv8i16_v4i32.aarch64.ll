define <4 x i32> @f(<4 x i32> %0, <8 x i16> %1) {
  %3 = shufflevector <8 x i16> %1, <8 x i16> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %4 = zext <4 x i16> %3 to <4 x i32>
  %5 = add <4 x i32> %4, %0
  ret <4 x i32> %5
}