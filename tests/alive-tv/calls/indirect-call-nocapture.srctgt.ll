define void @src(ptr captures(none) %0, ptr %1) {
  call void %1(ptr %0)
  ret void
}

define void @tgt(ptr %0, ptr %1) {
  call void %1(ptr %0)
  ret void
}
