define i19 @f(ptr %0, i32 %z) {
  %2 = tail call signext i19 %0(i32 %z)
  ret i19 %2
}