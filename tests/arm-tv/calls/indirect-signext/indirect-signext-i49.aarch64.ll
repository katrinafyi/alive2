define i49 @f(ptr %0, i32 %z) {
  %2 = tail call signext i49 %0(i32 %z)
  ret i49 %2
}
