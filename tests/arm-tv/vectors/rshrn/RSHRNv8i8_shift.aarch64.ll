define <8 x i8> @f(<8 x i16> %0) {
  %2 = add <8 x i16> %0, <i16 16, i16 16, i16 16, i16 16, i16 16, i16 16, i16 16, i16 16>
  %3 = lshr <8 x i16> %2, <i16 5, i16 5, i16 5, i16 5, i16 5, i16 5, i16 5, i16 5>
  %4 = trunc <8 x i16> %3 to <8 x i8>
  ret <8 x i8> %4
}