define i47 @f(ptr %0, i32 %z) {
  %2 = tail call zeroext i47 %0(i32 %z)
  ret i47 %2
}