declare <8 x i16> @g(<8 x i16>, <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16>, <8 x i16>)

define <8 x i16> @f() {
  %x = call <8 x i16> @g(<8 x i16> <i16 2, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>,
       	       	     	<8 x i16> <i16 1, i16 2, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>,
			<8 x i16> <i16 1, i16 1, i16 2, i16 1, i16 1, i16 1, i16 1, i16 1>,
			<8 x i16> <i16 1, i16 1, i16 1, i16 2, i16 1, i16 1, i16 1, i16 1>,
			<8 x i16> <i16 1, i16 1, i16 1, i16 1, i16 2, i16 1, i16 1, i16 1>,
			<8 x i16> <i16 1, i16 1, i16 1, i16 1, i16 1, i16 2, i16 1, i16 1>,
			<8 x i16> <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 2, i16 1>,
			<8 x i16> <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 2>,
			<8 x i16> <i16 3, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>,
			<8 x i16> <i16 1, i16 3, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>,
			<8 x i16> <i16 1, i16 1, i16 3, i16 1, i16 1, i16 1, i16 1, i16 1>,
			<8 x i16> <i16 1, i16 1, i16 1, i16 3, i16 1, i16 1, i16 1, i16 1>,
			<8 x i16> <i16 1, i16 1, i16 1, i16 1, i16 3, i16 1, i16 1, i16 1>,
			<8 x i16> <i16 1, i16 1, i16 1, i16 1, i16 1, i16 3, i16 1, i16 1>,
			<8 x i16> <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 3, i16 1>)
  ret <8 x i16> %x
}