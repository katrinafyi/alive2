@a = dso_local global <1 x i8> undef, align 1
@b = dso_local global <1 x i8> undef, align 1
@c = dso_local global <1 x i8> undef, align 1

define void @vector_add() {
    %a = load <1 x i8>, ptr @a, align 1
    %b = load <1 x i8>, ptr @b, align 1
    %d = add <1 x i8> %a, %b
    store <1 x i8> %d, ptr @c, align 1
    ret void
}