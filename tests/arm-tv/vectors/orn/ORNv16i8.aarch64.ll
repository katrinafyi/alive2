define <8 x i16> @f(<8 x i16> %0, <8 x i16> %1, <8 x i16> %2) {
  %4 = xor <8 x i16> %2, <i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1>
  %5 = or <8 x i16> %1, %4
  ret <8 x i16> %5
}
