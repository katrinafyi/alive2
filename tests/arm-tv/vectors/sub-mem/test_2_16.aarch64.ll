@a = dso_local global <2 x i16> undef, align 1
@b = dso_local global <2 x i16> undef, align 1
@c = dso_local global <2 x i16> undef, align 1

define void @vector_sub_2_16() {
    %a = load <2 x i16>, ptr @a, align 1
    %b = load <2 x i16>, ptr @b, align 1
    %d = sub <2 x i16> %a, %b
    store <2 x i16> %d, ptr @c, align 1
    ret void
}
