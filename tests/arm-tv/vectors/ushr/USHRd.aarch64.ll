define <1 x i64> @f(<2 x i32> %0) {
  %2 = and <2 x i32> %0, <i32 -1073741825, i32 -1073741825>
  %3 = bitcast <2 x i32> %2 to <1 x i64>
  %4 = lshr <1 x i64> %3, <i64 63>
  %5 = ashr <1 x i64> %3, <i64 62>
  %6 = or <1 x i64> %4, %5
  ret <1 x i64> %6
}