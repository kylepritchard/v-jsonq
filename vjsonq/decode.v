module vjsonq

import time

pub fn (r Result) decode[T]() T {
	if r.value.len != 0 {
		$if T in [$int, $float] {
			return r.process_numeric[T]()
		} $else $if T is string {
			return r.value.bytestr()
		} $else $if T is $array {
			$compile_error('Use decode_array() for array fields')
		} $else $if T is $struct {
			$if T is time.Time {
				return r.decode_time()
			} $else {
				return decode_struct[T](r.value)
			}
			// panic('a struct ahhhhhhhhh!')
		}
	}
	return T{}
}

// pub fn (r Result) decode_array() ([]Value, bool) {
// 	// $for attribute in Method.attributes {
// 	// 	if attribute.name == 'typ' {
// 	// 		println('type')
// 	// 	}
// 	// }
// 	mut ret := []Value{}
// 	if iterate_array_decode(mut ret, r.value) == -1 {
// 		return []Value{}, false
// 	}
// 	return ret, true
// }

fn (r Result) process_numeric[T]() T {
	mut val := T{}
	if r.vtype != .num {
		return val
	}
	value := r.value.bytestr()
	$if T.typ is i8 {
		val = value.i8()
	} $else $if T.typ is i16 {
		val = value.i16()
	} $else $if T.typ is int {
		val = value.int()
	} $else $if T.typ is i64 {
		val = value.i64()
	} $else $if T.typ is u8 {
		val = value.u8()
	} $else $if T.typ is u16 {
		val = value.u16()
	} $else $if T.typ is u32 {
		val = value.u32()
	} $else $if T.typ is u64 {
		val = value.u64()
	} $else $if T.typ is f32 {
		val = value.f32()
	} $else $if T.typ is f64 {
		val = value.f64()
	}
	return val
}

// fn (r Result) decode_time() time.Time {
// 	str := r.value.bytestr()
// 	if t := time.parse(str) {
// 		return t
// 	} else if t := time.parse_iso8601(str) {
// 		return t
// 	} else if t := time.parse_rfc3339(str) {
// 		return t
// 	} else if t := time.parse_rfc2822(str) {
// 		return t
// 	}

// 	return time.parse('1970-1-1 00:00:00') or { return time.now() }
// }

// fn check_if_time(data []byte) bool {
// 	mut sw := time.new_stopwatch()
// 	str := data#[1..-1].bytestr()
// 	if _ := time.parse(str) {
// 		println(sw.elapsed())
// 		return true
// 	} else if _ := time.parse_iso8601(str) {
// 		println(sw.elapsed())
// 		return true
// 	} else if _ := time.parse_rfc3339(str) {
// 		println(sw.elapsed())
// 		return true
// 	} else if _ := time.parse_rfc2822(str) {
// 		println(sw.elapsed())
// 		return true
// 	}
// 	println(sw.elapsed())
// 	return false
// }

// pub fn (r Result) decode_array() ([]Value, bool) {
// 	mut ret := []Value{}
// 	if iterate_array_decode(mut ret, r.value) == -1 {
// 		return []Value{}, false
// 	}
// 	return ret, true
// }

// fn process_numeric[T](data []byte) T {
// 	mut val := T{}
// 	value := data.bytestr()
// 	$if T.typ is i8 {
// 		val = value.i8()
// 	} $else $if T.typ is i16 {
// 		val = value.i16()
// 	} $else $if T.typ is int {
// 		val = value.int()
// 	} $else $if T.typ is i64 {
// 		val = value.i64()
// 	} $else $if T.typ is u8 {
// 		val = value.u8()
// 	} $else $if T.typ is u16 {
// 		val = value.u16()
// 	} $else $if T.typ is u32 {
// 		val = value.u32()
// 	} $else $if T.typ is u64 {
// 		val = value.u64()
// 	} $else $if T.typ is f32 {
// 		val = value.f32()
// 	} $else $if T.typ is f64 {
// 		val = value.f64()
// 	}
// 	return val
// }

// fn process_array[T](data []byte) T {
// 	// println(data)
// 	return T{}
// }

// ArrayEach is used when iterating arrays, accepts a callback function with the same return arguments as `Get`.
// fn iterate_array_decode(mut ret []Value, data []byte) int {
// 	// println('iteratte array')
// 	if data.len == 0 {
// 		return -1
// 	}

// 	next := next_token(data)
// 	if next == -1 {
// 		return -1
// 	}

// 	mut offset := next + 1

// 	n0 := next_token(data[offset..])
// 	if n0 == -1 {
// 		return offset
// 	}

// 	offset += n0

// 	if data[offset] == `]` {
// 		return offset
// 	}

// 	for true {
// 		v, t, _, o, e := get_(data[offset..])

// 		if e != ErrorType.no_error {
// 			return -1
// 		}

// 		if o == 0 {
// 			break
// 		}

// 		if t != .non_existant {
// 			match t {
// 				.str {
// 					ret << Value(v.bytestr())
// 				}
// 				.num {
// 					if `.` in v {
// 						ret << Value(Number{
// 							f64_: v.bytestr().f64()
// 						})
// 					} else {
// 						ret << Value(Number{
// 							i64_: v.bytestr().i64()
// 						})
// 					}
// 				}
// 				// .num {
// 				// 	if `.` in v {
// 				// 		ret << Value(v.bytestr().f64())
// 				// 	} else {
// 				// 		ret << Value(v.bytestr().i64())
// 				// 	}
// 				// }
// 				.boolean {
// 					ret << Value(v.bytestr().bool())
// 				}
// 				.null {
// 					ret << Value(v.bytestr())
// 				}
// 				.arr {
// 					mut arr := []Value{}
// 					if iterate_array_decode(mut arr, v) == -1 {
// 						ret << Value('malformed array error')
// 					} else {
// 						ret << Value(arr)
// 					}
// 				}
// 				.obj {
// 					mut m := map[string]Value{}
// 					if iterate_object_decode(mut m, v) == -1 {
// 						ret << Value('malformed map')
// 					} else {
// 						ret << Value(m)
// 					}
// 				}
// 				else {}
// 			}
// 			// cb(v, t, offset+o-len(v), e)
// 		}

// 		if e != .no_error {
// 			break
// 		}

// 		offset += o

// 		skip_to_token := next_token(data[offset..])
// 		if skip_to_token == -1 {
// 			return offset
// 		}
// 		offset += skip_to_token

// 		if data[offset] == `]` {
// 			break
// 		}

// 		if data[offset] != `,` {
// 			return offset
// 		}

// 		offset++
// 	}

// 	return offset
// }
