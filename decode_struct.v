module main

pub fn decode_struct[T](data []byte) T {
	mut res := T{}
	$for field in T.fields {
		r := get(data, field.name)
		$if field.typ is string {
			res.$(field.name) = r.value.bytestr()
		} $else $if field.typ is i8 {
			res.$(field.name) = r.process_numeric[i8]()
		} $else $if field.typ is i16 {
			res.$(field.name) = r.process_numeric[i16]()
		} $else $if field.typ is int {
			res.$(field.name) = r.process_numeric[int]()
		} $else $if field.typ is i64 {
			res.$(field.name) = r.process_numeric[i64]()
		} $else $if field.typ is u8 {
			res.$(field.name) = r.process_numeric[u8]()
		} $else $if field.typ is u16 {
			res.$(field.name) = r.process_numeric[u16]()
		} $else $if field.typ is u32 {
			res.$(field.name) = r.process_numeric[u32]()
		} $else $if field.typ is u64 {
			res.$(field.name) = r.process_numeric[u64]()
		} $else $if field.typ is bool {
			res.$(field.name) = r.value.bytestr().bool()
		} $else $if field.typ is []byte {
			res.$(field.name) = r.value
		} $else $if field.typ is $array {
			mut arr := []Value{}
			if iterate_array_decode(mut arr, r.value) != -1 {
				match determine_type(typeof(field).name) {
					'i8' {
						res.$(field.name) = unsafe { arr.map((it as Number).i8_) }
					}
					'i16' {
						res.$(field.name) = unsafe { arr.map((it as Number).i16_) }
					}
					'int' {
						res.$(field.name) = unsafe { arr.map((it as Number).int_) }
					}
					'i64' {
						res.$(field.name) = unsafe { arr.map((it as Number).i64_) }
					}
					'u8' {
						res.$(field.name) = unsafe { arr.map((it as Number).u8_) }
					}
					'u16' {
						res.$(field.name) = unsafe { arr.map((it as Number).u16_) }
					}
					'u32' {
						res.$(field.name) = unsafe { arr.map((it as Number).u32_) }
					}
					'u64' {
						res.$(field.name) = unsafe { arr.map((it as Number).u64_) }
					}
					'f32' {
						res.$(field.name) = unsafe { arr.map((it as Number).f32_) }
					}
					'f64' {
						res.$(field.name) = unsafe { arr.map((it as Number).f64_) }
					}
					'bool' {
						res.$(field.name) = arr.map(it as bool)
					}
					'string' {
						res.$(field.name) = arr.map(it as string)
					}
					else {
						println('dunno what to do')
					}
				}
			} else {
				res.$(field.name) = []u8{}
			}
		} $else $if field.typ is $map {
			mut m := map[string]Value{}

			// v_type := typeof(res.$(field.name).values())[2..]
			if iterate_object_decode(mut m, r.value) != -1 {
				match determine_type(typeof(field).name) {
					'i8' {
						mut nm := map[string]i8{}
						for k, v in m {
							nm[k] = unsafe { (v as Number).i8_ }
						}
						res.$(field.name) = nm.move()
					}
					'i16' {
						mut nm := map[string]i16{}
						for k, v in m {
							nm[k] = unsafe { (v as Number).i16_ }
						}
						res.$(field.name) = nm.move()
					}
					'int' {
						mut nm := map[string]int{}
						for k, v in m {
							nm[k] = int(v as i64)
						}
						res.$(field.name) = nm.move()
					}
					'i64' {
						mut nm := map[string]i64{}
						for k, v in m {
							nm[k] = unsafe { (v as Number).i64_ }
						}
						res.$(field.name) = nm.move()
					}
					'u8' {
						mut nm := map[string]u8{}
						for k, v in m {
							nm[k] = unsafe { (v as Number).u8_ }
						}
						res.$(field.name) = nm.move()
					}
					'u16' {
						mut nm := map[string]u16{}
						for k, v in m {
							nm[k] = unsafe { (v as Number).u16_ }
						}
						res.$(field.name) = nm.move()
					}
					'u32' {
						mut nm := map[string]u32{}
						for k, v in m {
							nm[k] = unsafe { (v as Number).u32_ }
						}
						res.$(field.name) = nm.move()
					}
					'u64' {
						mut nm := map[string]u64{}
						for k, v in m {
							nm[k] = unsafe { (v as Number).u64_ }
						}
						res.$(field.name) = nm.move()
					}
					'f32' {
						mut nm := map[string]f32{}
						for k, v in m {
							nm[k] = unsafe { (v as Number).f32_ }
						}
						res.$(field.name) = nm.move()
					}
					'f64' {
						mut nm := map[string]f64{}
						for k, v in m {
							nm[k] = unsafe { (v as Number).f64_ }
						}
						res.$(field.name) = nm.move()
					}
					'bool' {
						mut nm := map[string]bool{}
						for k, v in m {
							nm[k] = v as bool
						}
						res.$(field.name) = nm.move()
					}
					'string' {
						mut nm := map[string]string{}
						for k, v in m {
							nm[k] = v as string
						}
						res.$(field.name) = nm.move()
					}
					else {
						println('dunno what to do')
					}
				}
			} else {
				res.$(field.name) = map[string]u8{}
			}
		}
	}
	return res
}

[inline]
fn determine_type(t string) string {
	if t[0] == `[` {
		return t[2..]
	}
	return t[11..]
}
