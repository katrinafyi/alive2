define void @test_arg_v2i64(<2 x i64> %0, ptr %1) {
  store <2 x i64> %0, ptr %1, align 16, !nontemporal !0
  ret void
}

!0 = !{i32 1}
