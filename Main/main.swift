import BigInt

func string() {
  let p = PerformanceTests()
  p.test_string_fromRadix8()
  p.test_string_fromRadix10()
  p.test_string_fromRadix16()
  p.test_string_toRadix8()
  p.test_string_toRadix10()
  p.test_string_toRadix16()
}

func equatable_comparable() {
  let p = PerformanceTests()
  p.test_equatable_int()
  p.test_equatable_big()
  p.test_comparable_int()
  p.test_comparable_big()
}

func unary() {
  let p = PerformanceTests()
  p.test_unary_plus_int()
  p.test_unary_plus_big()
  p.test_unary_minus_int()
  p.test_unary_minus_big()
  p.test_unary_invert_int()
  p.test_unary_invert_big()
}

func add_sub() {
  let p = PerformanceTests()
  p.test_binary_add_int()
  p.test_binary_add_int_inout()
  p.test_binary_add_big()
  p.test_binary_add_big_inout()
  p.test_binary_sub_int()
  p.test_binary_sub_int_inout()
  p.test_binary_sub_big()
  p.test_binary_sub_big_inout()
}

func mul() {
  let p = PerformanceTests()
  p.test_binary_mul_int()
  p.test_binary_mul_int_inout()
  p.test_binary_mul_big()
  p.test_binary_mul_big_inout()
}

func div_mod() {
  let p = PerformanceTests()
  p.test_binary_div_int()
  p.test_binary_div_int_inout()
  p.test_binary_div_big()
  p.test_binary_div_big_inout()
  p.test_binary_mod_int()
  p.test_binary_mod_int_inout()
  p.test_binary_mod_big()
  p.test_binary_mod_big_inout()
}

func and_or_xor() {
  let p = PerformanceTests()
  p.test_binary_and_int()
  p.test_binary_and_int_inout()
  p.test_binary_and_big()
  p.test_binary_and_big_inout()
  p.test_binary_or_int()
  p.test_binary_or_int_inout()
  p.test_binary_or_big()
  p.test_binary_or_big_inout()
  p.test_binary_xor_int()
  p.test_binary_xor_int_inout()
  p.test_binary_xor_big()
  p.test_binary_xor_big_inout()
}

func shift() {
  let p = PerformanceTests()
  p.test_shiftLeft_int()
  p.test_shiftLeft_int_inout()
  p.test_shiftLeft_big()
  p.test_shiftLeft_big_inout()
  p.test_shiftRight_int()
  p.test_shiftRight_int_inout()
  p.test_shiftRight_big()
  p.test_shiftRight_big_inout()
}

func pi() {
  let p = PerformanceTests()
  p.test_pi_500()
  p.test_pi_1000()
  p.test_pi_5000()
}

//  string()
//  equatable_comparable()
//  unary()
//  add_sub()
//  mul()
//  div_mod()
//and_or_xor()
//  shift()
pi()
