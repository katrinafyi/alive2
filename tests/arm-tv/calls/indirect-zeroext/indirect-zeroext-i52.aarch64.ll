define i52 @f(ptr %0, i32 %z) {
  %2 = tail call zeroext i52 %0(i32 %z)
  ret i52 %2
}
