; TEST-ARGS: --disable-undef-input --disable-poison-input

define i64 @f(i64 %a) {
  ret i64 %a
}
