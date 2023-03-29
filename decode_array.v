module main

pub fn (r Result) decode_array() ([]Value, bool) {
	mut ret := []Value{}
	if iterate_array_decode(mut ret, r.value) == -1 {
		return []Value{}, false
	}
	return ret, true
}

fn iterate_array_decode(mut ret []Value, data []byte) int {
	// println('iteratte array')
	if data.len == 0 {
		return -1
	}

	next := next_token(data)
	if next == -1 {
		return -1
	}

	mut offset := next + 1

	n0 := next_token(data[offset..])
	if n0 == -1 {
		return offset
	}

	offset += n0

	if data[offset] == `]` {
		return offset
	}

	for true {
		v, t, _, o, e := get_(data[offset..])

		if e != ErrorType.no_error {
			return -1
		}

		if o == 0 {
			break
		}

		if t != .non_existant {
			match t {
				.str {
					ret << Value(v.bytestr())
				}
				.num {
					if `.` in v {
						ret << Value(Number{
							f64_: v.bytestr().f64()
						})
					} else {
						ret << Value(Number{
							i64_: v.bytestr().i64()
						})
					}
				}
				.boolean {
					ret << Value(v.bytestr().bool())
				}
				.null {
					ret << Value(v.bytestr())
				}
				.arr {
					mut arr := []Value{}
					if iterate_array_decode(mut arr, v) == -1 {
						ret << Value('malformed array error')
					} else {
						ret << Value(arr)
					}
				}
				.obj {
					mut m := map[string]Value{}
					if iterate_object_decode(mut m, v) == -1 {
						ret << Value('malformed map')
					} else {
						ret << Value(m)
					}
				}
				else {}
			}

			// cb(v, t, offset+o-len(v), e)
		}

		if e != .no_error {
			break
		}

		offset += o

		skip_to_token := next_token(data[offset..])
		if skip_to_token == -1 {
			return offset
		}
		offset += skip_to_token

		if data[offset] == `]` {
			break
		}

		if data[offset] != `,` {
			return offset
		}

		offset++
	}

	return offset
}
