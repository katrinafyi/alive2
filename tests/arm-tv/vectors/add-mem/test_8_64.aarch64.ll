@a = dso_local global <8 x i64> undef, align 1
@b = dso_local global <8 x i64> undef, align 1
@c = dso_local global <8 x i64> undef, align 1

define void @vector_add_8_64() {
    %a = load <8 x i64>, ptr @a, align 1
    %b = load <8 x i64>, ptr @b, align 1
    %d = add <8 x i64> %a, %b
    store <8 x i64> %d, ptr @c, align 1
    ret void
}
