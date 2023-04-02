module vjsonq

// type Map = map[string]Result | map[string]Value

// ObjectEach iterates over the key-value pairs of a JSON object, invoking a given callback for each such entry
[direct_array_access]
fn iterate_object_decode(mut m map[string]Value, data []byte) int {
	mut offset := 0
	mut off := 0

	// Descend to the desired key, if requested
	// if keys.len > 0 {
	// 	off = search_keys(data, ...keys)
	// 	if off == -1 {
	// 		return -1
	// 	} else {
	// 		offset = off
	// 	}
	// }

	// Validate and skip past opening brace
	off = next_token(data[offset..])
	if off == -1 {
		// println('20')
		return -1
	} else {
		offset += off

		// println(data[offset].ascii_str())
		if data[offset] != `{` {
			// println('25')
			return -1
		} else {
			offset++
		}
	}

	// Skip to the first token inside the object, or stop if we find the ending brace
	off = next_token(data[offset..])
	if off == -1 {
		// println('35')
		return -1
	} else {
		offset += off
		if data[offset] == `}` {
			return 0
		}
	}

	// Loop pre-condition: data[offset] points to what should be either the next entry`s key, or the closing brace (if it`s anything else, the JSON is malformed)
	for offset < data.len {
		// Step 1: find the next key
		mut key := []u8{}

		// Check what the the next token is: start of string, end of object, or something else (error)
		match data[offset] {
			`"` {
				offset++
			}
			`}` {
				// println('54')
				return -1
			}
			else {}
		}

		// Find the end of the key string
		mut key_escaped := false
		mut esc := false
		off, esc = string_end(data[offset..])
		if off == -1 {
			// println('65')
			return -1
		} else {
			key, key_escaped = data[offset..offset + off - 1], esc
			offset += off
		}

		// Unescape the string if needed
		if key_escaped {
			mut stackbuf := [64]u8{} // stack-allocated array for allocation-free unescaping of small strings
			key_unescaped, err := unescape(key, stackbuf)
			if !err {
				// println('77')
				return -1
			} else {
				key = key_unescaped.clone()
			}
		}

		// Step 2: skip the colon
		off = next_token(data[offset..])
		if off == -1 {
			// println('87')
			return -1
		} else {
			offset += off

			if data[offset] != `:` {
				// println('92')
				return -1
			} else {
				offset++
			}
		}

		// Step 3: find the associated value, then invoke the callback
		v, t, _, o, e := get_(data[offset..])
		if e != ErrorType.no_error {
			// println('103')
			return -1
		} else {
			// err0 := callback(key, value, value_type, offset + off0)
			if t != .non_existant {
				match t {
					.str {
						m[key.bytestr()] = Value(v.bytestr())
					}
					// .num {
					// 	m[key.bytestr()] = Value(v.bytestr().f64())
					// }
					// .num {
					// 	if `.` in v {
					// 		m[key.bytestr()] = Value(Number{
					// 			f64_: v.bytestr().f64()
					// 		})
					// 	} else {
					// 		m[key.bytestr()] = Value(Number{
					// 			i64_: v.bytestr().i64()
					// 		})
					// 	}
					// }
					// .num {
					// 	if `.` in v {
					// 		m[key.bytestr()] = Value(v.bytestr().f64())
					// 	} else {
					// 		m[key.bytestr()] = Value(v.bytestr().i64())
					// 	}
					// }
					.num {
						m[key.bytestr()] = Value(bytes_to_number(v))
					}
					.boolean {
						// m[key.bytestr()] = Value(v.bytestr().bool())
						m[key.bytestr()] = Value(v[0] == `t`)
					}
					.null {
						m[key.bytestr()] = Value(v.bytestr())
					}
					.arr {
						mut arr := []Value{}
						if iterate_array_decode(mut arr, v) == -1 {
							m[key.bytestr()] = Value('malformed array error')
						} else {
							m[key.bytestr()] = Value(arr)
						}
					}
					.obj {
						mut m0 := map[string]Value{}
						if iterate_object_decode(mut m0, v) == -1 {
							m[key.bytestr()] = Value('malformed map')
						} else {
							m[key.bytestr()] = Value(m0)
						}
					}
					else {}
				}

				// cb(v, t, offset+o-len(v), e)
			}
		}
		offset += o

		// 		func(key []byte, value []byte, dataType jsonparser.ValueType, offset int) error {
		//         fmt.Printf("Key: '%s'\n Value: '%s'\n Type: %s\n", string(key), string(value), dataType)
		// 	return nil
		// },
		// callback func(key []byte, value []byte, dataType ValueType, offset int) error,

		// if err0 != ErrorType.no_error{ // Invoke the callback here!
		// 	return -1
		// } else {
		// 	offset += off0
		// }
		// }

		// Step 4: skip over the next comma to the following token, or stop if we hit the ending brace
		off = next_token(data[offset..])
		if off == -1 {
			// println('159')
			return -1
		} else {
			offset += off
			match data[offset] {
				`}` {
					// println(data[offset].ascii_str())
					// println('165')
					return offset
				}
				`,` {
					offset++
				}
				else {
					// println('169')
					return -1
				}
			}
		}

		// Skip to the next token after the comma
		off = next_token(data[offset..])
		if off == -1 {
			// println('176')
			return -1
		} else {
			offset += off
		}
	}

	return offset // we shouldn`t get here; it`s expected that we will return via finding the ending brace
}

[direct_array_access]
fn iterate_object_decode_results(mut m map[string]Result, data []byte) int {
	mut offset := 0
	mut off := 0

	// Descend to the desired key, if requested
	// if keys.len > 0 {
	// 	off = search_keys(data, ...keys)
	// 	if off == -1 {
	// 		return -1
	// 	} else {
	// 		offset = off
	// 	}
	// }

	// Validate and skip past opening brace
	off = next_token(data[offset..])
	if off == -1 {
		// println('20')
		return -1
	} else {
		offset += off

		// println(data[offset].ascii_str())
		if data[offset] != `{` {
			// println('25')
			return -1
		} else {
			offset++
		}
	}

	// Skip to the first token inside the object, or stop if we find the ending brace
	off = next_token(data[offset..])
	if off == -1 {
		// println('35')
		return -1
	} else {
		offset += off
		if data[offset] == `}` {
			return 0
		}
	}

	// Loop pre-condition: data[offset] points to what should be either the next entry`s key, or the closing brace (if it`s anything else, the JSON is malformed)
	for offset < data.len {
		// Step 1: find the next key
		mut key := []u8{}

		// Check what the the next token is: start of string, end of object, or something else (error)
		match data[offset] {
			`"` {
				offset++
			}
			`}` {
				// println('54')
				return -1
			}
			else {}
		}

		// Find the end of the key string
		mut key_escaped := false
		mut esc := false
		off, esc = string_end(data[offset..])
		if off == -1 {
			// println('65')
			return -1
		} else {
			key, key_escaped = data[offset..offset + off - 1], esc
			offset += off
		}

		// Unescape the string if needed
		if key_escaped {
			mut stackbuf := [64]u8{} // stack-allocated array for allocation-free unescaping of small strings
			key_unescaped, err := unescape(key, stackbuf)
			if !err {
				// println('77')
				return -1
			} else {
				key = key_unescaped.clone()
			}
		}

		// Step 2: skip the colon
		off = next_token(data[offset..])
		if off == -1 {
			// println('87')
			return -1
		} else {
			offset += off

			if data[offset] != `:` {
				// println('92')
				return -1
			} else {
				offset++
			}
		}

		// Step 3: find the associated value, then invoke the callback
		v, t, _, o, e := get_(data[offset..])
		if e != ErrorType.no_error {
			// println('103')
			return -1
		} else {
			// err0 := callback(key, value, value_type, offset + off0)
			m[key.bytestr()] = Result{
				value: v
				vtype: t
			}

			// if t != .non_existant {
			// 	match t {
			// 		.str {
			// 			m[key.bytestr()] = Value(v.bytestr())
			// 		}
			// 		// .num {
			// 		// 	m[key.bytestr()] = Value(v.bytestr().f64())
			// 		// }
			// 		.num {
			// 			if `.` in v {
			// 				m[key.bytestr()] = Value(Number{
			// 					f64_: v.bytestr().f64()
			// 				})
			// 			} else {
			// 				m[key.bytestr()] = Value(Number{
			// 					i64_: v.bytestr().i64()
			// 				})
			// 			}
			// 		}
			// 		// .num {
			// 		// 	if `.` in v {
			// 		// 		m[key.bytestr()] = Value(v.bytestr().f64())
			// 		// 	} else {
			// 		// 		m[key.bytestr()] = Value(v.bytestr().i64())
			// 		// 	}
			// 		// }
			// 		.boolean {
			// 			m[key.bytestr()] = Value(v.bytestr().bool())
			// 		}
			// 		.null {
			// 			m[key.bytestr()] = Value(v.bytestr())
			// 		}
			// 		.arr {
			// 			mut arr := []Value{}
			// 			if iterate_array_decode(mut arr, v) == -1 {
			// 				m[key.bytestr()] = Value('malformed array error')
			// 			} else {
			// 				m[key.bytestr()] = Value(arr)
			// 			}
			// 		}
			// 		.obj {
			// 			mut m0 := map[string]Value{}
			// 			if iterate_object_decode(mut m0, v) == -1 {
			// 				m[key.bytestr()] = Value('malformed map')
			// 			} else {
			// 				m[key.bytestr()] = Value(m0)
			// 			}
			// 		}
			// 		else {}
			// 	}
			// 	// cb(v, t, offset+o-len(v), e)
			// }
		}
		offset += o

		// 		func(key []byte, value []byte, dataType jsonparser.ValueType, offset int) error {
		//         fmt.Printf("Key: '%s'\n Value: '%s'\n Type: %s\n", string(key), string(value), dataType)
		// 	return nil
		// },
		// callback func(key []byte, value []byte, dataType ValueType, offset int) error,

		// if err0 != ErrorType.no_error{ // Invoke the callback here!
		// 	return -1
		// } else {
		// 	offset += off0
		// }
		// }

		// Step 4: skip over the next comma to the following token, or stop if we hit the ending brace
		off = next_token(data[offset..])
		if off == -1 {
			// println('159')
			return -1
		} else {
			offset += off
			match data[offset] {
				`}` {
					// println(data[offset].ascii_str())
					// println('165')
					return offset
				}
				`,` {
					offset++
				}
				else {
					// println('169')
					return -1
				}
			}
		}

		// Skip to the next token after the comma
		off = next_token(data[offset..])
		if off == -1 {
			// println('176')
			return -1
		} else {
			offset += off
		}
	}

	return offset // we shouldn`t get here; it`s expected that we will return via finding the ending brace
}
