define i17 @f(ptr %0, i32 %z) {
  %2 = tail call zeroext i17 %0(i32 %z)
  ret i17 %2
}