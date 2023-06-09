module vjsonq

import time

[direct_array_access]
pub fn decode_struct[T](data []byte) T {
	mut res := T{}

	// mut offset := 0
	mut sm := map[string]Result{}

	// mut sw := time.new_stopwatch()
	iterate_object_decode_results(mut sm, data)

	// println('Time to parse to a map ${sw.elapsed()}')

	// println(sm)
	$for field in T.fields {
		// println(data[offset..].bytestr())
		// r := get(data, field.name)
		$if field.typ is string {
			// sw.restart()
			res.$(field.name) = sm[field.name].value.bytestr()

			// println('Time to set string ${sw.elapsed()}')
		} $else $if field.typ is i8 {
			res.$(field.name) = sm[field.name].decode_number[i8]()
		} $else $if field.typ is i16 {
			res.$(field.name) = sm[field.name].decode_number[i16]()
		} $else $if field.typ is int {
			// sw.restart()
			res.$(field.name) = sm[field.name].decode_number[int]()

			// println('Time to set an int ${sw.elapsed()}')
		} $else $if field.typ is i64 {
			res.$(field.name) = sm[field.name].decode_number[i64]()
		} $else $if field.typ is u8 {
			res.$(field.name) = sm[field.name].decode_number[u8]()
		} $else $if field.typ is u16 {
			res.$(field.name) = sm[field.name].decode_number[u16]()
		} $else $if field.typ is u32 {
			res.$(field.name) = sm[field.name].decode_number[u32]()
		} $else $if field.typ is u64 {
			res.$(field.name) = sm[field.name].decode_number[u64]()
		} $else $if field.typ is bool {
			res.$(field.name) = sm[field.name].value.bytestr().bool()
		} $else $if field.typ is []byte {
			res.$(field.name) = sm[field.name].value
		} $else $if field.typ is time.Time {
			res.$(field.name) = sm[field.name].decode_time()
		} $else $if field.typ is $array {
			mut arr := []Value{}
			if iterate_array_decode(mut arr, sm[field.name].value) != -1 {
				match determine_type(typeof(field).name) {
					'i8' {
						res.$(field.name) = arr.map(i8(it as f64))
					}
					'i16' {
						res.$(field.name) = arr.map(i16(it as f64))
					}
					'int' {
						res.$(field.name) = arr.map(int(it as f64))
					}
					'i64' {
						res.$(field.name) = arr.map(i64(it as f64))
					}
					'u8' {
						res.$(field.name) = arr.map(u8(it as f64))
					}
					'u16' {
						res.$(field.name) = arr.map(u16(it as f64))
					}
					'u32' {
						res.$(field.name) = arr.map(u32(it as f64))
					}
					'u64' {
						res.$(field.name) = arr.map(u64(it as f64))
					}
					'f32' {
						res.$(field.name) = arr.map(f32(it as f64))
					}
					'f64' {
						res.$(field.name) = arr.map((it as f64))
					}
					'bool' {
						res.$(field.name) = arr.map(it as bool)
					}
					'string' {
						res.$(field.name) = arr.map(it as string)
					}
					'time.Time' {
						res.$(field.name) = arr.map(decode_time(it as string))
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
			if iterate_object_decode(mut m, sm[field.name].value) != -1 {
				match determine_type(typeof(field).name) {
					'i8' {
						mut nm := map[string]i8{}
						for k, v in m {
							nm[k] = i8(v as f64)
						}
						res.$(field.name) = nm.move()
					}
					'i16' {
						mut nm := map[string]i16{}
						for k, v in m {
							nm[k] = i16(v as f64)
						}
						res.$(field.name) = nm.move()
					}
					'int' {
						mut nm := map[string]int{}
						for k, v in m {
							nm[k] = int(v as f64)
						}
						res.$(field.name) = nm.move()
					}
					'i64' {
						mut nm := map[string]i64{}
						for k, v in m {
							nm[k] = i64(v as f64)
						}
						res.$(field.name) = nm.move()
					}
					'u8' {
						mut nm := map[string]u8{}
						for k, v in m {
							nm[k] = u8(v as f64)
						}
						res.$(field.name) = nm.move()
					}
					'u16' {
						mut nm := map[string]u16{}
						for k, v in m {
							nm[k] = u16(v as f64)
						}
						res.$(field.name) = nm.move()
					}
					'u32' {
						mut nm := map[string]u32{}
						for k, v in m {
							nm[k] = u32(v as f64)
						}
						res.$(field.name) = nm.move()
					}
					'u64' {
						mut nm := map[string]u64{}
						for k, v in m {
							nm[k] = u64(v as f64)
						}
						res.$(field.name) = nm.move()
					}
					'f32' {
						mut nm := map[string]f32{}
						for k, v in m {
							nm[k] = f32(v as f64)
						}
						res.$(field.name) = nm.move()
					}
					'f64' {
						mut nm := map[string]f64{}
						for k, v in m {
							nm[k] = v as f64
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
					'time.Time' {
						mut nm := map[string]time.Time{}
						for k, v in m {
							nm[k] = decode_time(v as string)
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
