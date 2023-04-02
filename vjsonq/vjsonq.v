module vjsonq

pub fn get(data []byte, keys ...string) Result {
	a, b, _, d, e := get_(data, ...keys)
	return Result{
		value: a
		vtype: b
		offset: d
		error: e
	}
}

[direct_array_access]
fn get_(data []byte, keys ...string) ([]byte, ValueType, int, int, ErrorType) {
	mut offset := 0
	if keys.len > 0 {
		offset = search_keys(data, ...keys)
		if offset == -1 {
			return []byte{}, ValueType.non_existant, offset, -1, ErrorType.json
		}
	}

	n0 := next_token(data[offset..])
	if n0 == -1 {
		return []byte{}, ValueType.non_existant, offset, -1, ErrorType.json
	}

	offset += n0

	mut value, datatype, endoffset, err := get_type(data, offset)
	if err != .no_error {
		return value, datatype, offset, endoffset, err
	}

	// Strip quotes from string values
	if datatype == .str {
		value = value[1..value.len - 1]
	}

	return value[..value.len], datatype, offset, endoffset, ErrorType.no_error
}

pub fn get_all(data []byte, queries [][]string) []Result {
	mut results := []Result{}
	for q in queries {
		results << get(data, ...q)
	}

	return results
}

// //searchKeys
[direct_array_access]
fn search_keys(data []byte, keys ...string) int {
	mut key_level := 0
	mut level := 0
	mut i := 0
	ln := data.len
	lk := keys.len
	mut last_matched := true

	if lk == 0 {
		return 0
	}

	stackbuf := [64]u8{}

	for i < ln {
		// print('${i} ==> ')
		// println(data[i].ascii_str())
		match true {
			is_whitespace[data[i]] {}
			data[i] == `"` {
				i++
				key_begin := i

				str_end, key_escaped := string_end(data[i..])

				// println('string_end, ${str_end} - ${data[i..i + str_end].bytestr()}')
				if str_end == -1 {
					println('line 94')
					return -1
				}
				i += str_end
				key_end := i - 1
				value_offset := next_token(data[i..])

				// println(value_offset)
				if value_offset == -1 {
					println('line 102')
					return -1
				}

				i += value_offset

				if data[i] == `:` {
					// println('a colon')
					if level < 1 {
						println('line 110')
						return -1
					}

					key := data[key_begin..key_end]

					mut key_unesc := []byte{}

					if !key_escaped {
						key_unesc = key.clone()
					} else {
						ku, ok := unescape(key, stackbuf)
						if !ok {
							println('line 123')
							return -1
						} else {
							key_unesc = ku.clone()
						}
					}

					if level <= keys.len {
						// if equal_str(key_unesc, keys[level - 1]) {
						if bytes_equal(key_unesc, keys[level - 1].bytes()) {
							last_matched = true

							if key_level == level - 1 {
								key_level++

								if key_level == lk {
									return i + 1
								}
							}
						} else {
							last_matched = false
						}
					} else {
						println('line 145')
						return -1
					}
				} else {
					i--
				}
			} // end `"`
			data[i] == `{` {
				if !last_matched {
					end := block_end(data[i..], `{`, `}`)

					// println(' 160 block_end, ${end}')
					if end == -1 {
						println('line 156')
						return -1
					}
					i += end - 1
				} else {
					level++
				}
			} // end `{`
			data[i] == `[` {
				if key_level == level && keys[level][0] == `[` {
					key_len := keys[level].len
					if key_len < 3 || keys[level][0] != `[` || keys[level][key_len - 1] != `]` {
						println('line 168')
						return -1
					}
					a_idx := keys[level][1..key_len - 1].int()
					mut cur_idx := 0
					mut value_found := []byte{}
					mut value_offset := 0

					cur_i := i

					cur_idx, value_found, value_offset, _ = iterate_array(data[i..], cur_idx,
						a_idx, cur_i)

					// println(value_found)
					if value_found.len == 0 {
						println('line 203')
						return -1
					} else {
						// println('searching sub index')
						sub_index := search_keys(value_found, ...keys[level + 1..])
						if sub_index < 0 {
							println('line 208')
							return -1
						}
						return i + value_offset + sub_index
					}
				} else {
					array_skip := block_end(data[i..], `[`, `]`)
					if array_skip == -1 {
						println('line 216')
						return -1
					} else {
						i += array_skip - 1
					}
				}
			} // end `[`
			data[i] == `:` {
				println('line 224')
				return -1
			}
			else {}
		}
		i++
	} // end for i < ln
	println('line 231')
	return -1
}

// //next_token
[direct_array_access]
fn next_token(data []byte) int {
	mut i := 0
	for i < data.len {
		match true {
			is_whitespace[data[i]] {}
			else {
				return i
			}
		}
		i++
	}
	return 0 //???
}

// //get_type
[direct_array_access]
fn get_type(data []byte, offset int) ([]byte, ValueType, int, ErrorType) {
	mut datatype := ValueType.unknown
	mut endoffset := offset

	// if string value
	if data[offset] == `"` {
		datatype = .str
		idx, _ := string_end(data[offset + 1..])
		if idx != -1 {
			endoffset += idx + 1
		} else {
			return []byte{}, datatype, offset, ErrorType.malformed_string
		}
	} else if data[offset] == `[` { // if array value
		datatype = .arr

		// break label, for stopping nested loops
		endoffset = block_end(data[offset..], `[`, `]`)

		if endoffset == -1 {
			return []byte{}, datatype, offset, ErrorType.malformed_array
		}

		endoffset += offset
	} else if data[offset] == `{` { // if object value
		datatype = .obj

		// break label, for stopping nested loops
		endoffset = block_end(data[offset..], `{`, `}`)

		if endoffset == -1 {
			return []byte{}, datatype, offset, ErrorType.malformed_object
		}

		endoffset += offset
	} else {
		// Number, Boolean or None
		end := token_end(data[endoffset..])

		if end == -1 {
			return []byte{}, datatype, offset, ErrorType.malformed_value
		}

		value := data[offset..endoffset + end]

		match true {
			data[offset] == `t` || data[offset] == `f` { // true or false
				if bytes_equal(value, true_literal) || bytes_equal(value, false_literal) {
					datatype = .boolean
				} else {
					return []byte{}, ValueType.unknown, offset, ErrorType.unknown_value
				}
			}
			data[offset] == `u` || data[offset] == `n` { // undefined or null
				if bytes_equal(value, null_literal) {
					datatype = ValueType.null
				} else {
					return []byte{}, ValueType.unknown, offset, ErrorType.unknown_value
				}
			}
			is_number[data[offset]] { // number 0-9 or -
				datatype = .num
			}
			else {
				return []byte{}, ValueType.unknown, offset, ErrorType.unknown_value
			}
		}

		endoffset += end
	}
	return data[offset..endoffset], datatype, endoffset, ErrorType.no_error
}

// string_end

// Tries to find the end of string
// Support if string contains escaped quote symbols.
fn old_string_end(data []byte) (int, bool) {
	mut escaped := false
	for i, c in data {
		if c == `"` {
			if !escaped {
				return i + 1, false
			} else {
				mut j := i - 1
				for {
					if j < 0 || data[j] != `\\` {
						return i + 1, true // even number of backslashes
					}
					j--
					if j < 0 || data[j] != `\\` {
						break // odd number of backslashes
					}
					j--
				}
			}
		} else if c == `\\` {
			escaped = true
		}
	}

	return -1, escaped
}

[direct_array_access]
fn string_end(data []byte) (int, bool) {
	mut escaped := false
	mut i := 0
	for {
		for i < data.len - 7 {
			// data_slice := data[i..i + 4]
			if string_end[data[i]] {
				unsafe {
					goto tok
				}
			}
			i++
			if string_end[data[i]] {
				unsafe {
					goto tok
				}
			}
			i++
			if string_end[data[i]] {
				unsafe {
					goto tok
				}
			}
			i++
			if string_end[data[i]] {
				unsafe {
					goto tok
				}
			}
			i++
			if string_end[data[i]] {
				unsafe {
					goto tok
				}
			}
			i++
			if string_end[data[i]] {
				unsafe {
					goto tok
				}
			}
			i++
			if string_end[data[i]] {
				unsafe {
					goto tok
				}
			}
			i++
			if string_end[data[i]] {
				unsafe {
					goto tok
				}
			}
			i++
		}

		// remaining
		for i < data.len {
			if string_end[data[i]] {
				unsafe {
					goto tok
				}
			}
			i++
		}

		break

		// goto
		tok:
		{
			if data[i] == `"` {
				// println('a quote')
				if !escaped {
					return i + 1, false
				} else {
					mut j := i - 1
					for {
						if j < 0 || data[j] != `\\` {
							return i + 1, true // even number of backslashes
						}
						j--
						if j < 0 || data[j] != `\\` {
							break // odd number of backslashes
						}
						j--
					}
				}
			} else if data[i] == `\\` {
				escaped = true
			}
			i++
		}
	}

	return -1, escaped
}

// Find end of the data structure, array or object.
// For array openSym and closeSym will be '[' and ']', for object '{' and '}'
fn old_block_end(data []byte, openSym byte, closeSym byte) int {
	mut level := 0
	mut i := 0
	ln := data.len

	for i < ln {
		match data[i] {
			`"` { // If inside string, skip it
				se, _ := string_end(data[i + 1..])
				if se == -1 {
					return -1
				}
				i += se
			}
			openSym { // If open symbol, increase level
				level++
			}
			closeSym { // If close symbol, increase level
				level--

				// If we have returned to the original level, we're done
				if level == 0 {
					return i + 1
				}
			}
			else {}
		}
		i++
	}

	return -1
}

[direct_array_access]
fn block_end(data []byte, openSym byte, closeSym byte) int {
	// println(data.bytestr())
	mut level := 0
	mut i := 0

	// ln := data.len
	mut x := [256]bool{}
	x[`"`] = true
	if openSym == `{` {
		x[`{`], x[`}`] = true, true
	} else {
		x[`[`], x[`]`] = true, true
	}

	for {
		for i < data.len - 7 {
			// block := data[i..i + 8]
			if x[data[i]] {
				unsafe {
					goto check
				}
			}
			i++
			if x[data[i]] {
				unsafe {
					goto check
				}
			}
			i++
			if x[data[i]] {
				unsafe {
					goto check
				}
			}
			i++
			if x[data[i]] {
				unsafe {
					goto check
				}
			}
			i++
			if x[data[i]] {
				unsafe {
					goto check
				}
			}
			i++
			if x[data[i]] {
				unsafe {
					goto check
				}
			}
			i++
			if x[data[i]] {
				unsafe {
					goto check
				}
			}
			i++
			if x[data[i]] {
				unsafe {
					goto check
				}
			}
			i++
		}

		// remaining
		for i < data.len {
			// println('loop: ${i}, ${ln}')
			if x[data[i]] {
				unsafe {
					goto check
				}
			}
			i++
		}

		// escape the main for loop
		break

		check:
		{
			// redo - returning zero
			if data[i] == `"` { // If inside string, skip it
				se, _ := string_end(data[i + 1..])
				if se == -1 {
					return -1
				}
				i += se
			} else if data[i] == openSym { // If open symbol, increase level
				level++
			} else if data[i] == closeSym { // If close symbol, increase level
				level--

				// If we have returned to the original level, we're done
				if level == 0 {
					return i + 1
				}
			}
			i++
		}
	}
	return -1
}

// unescape
fn unescape(i []byte, o [64]u8) ([]byte, bool) {
	return []byte{}, false
}

// token_end
fn old_token_end(data []byte) int {
	for i, c in data {
		match true {
			is_token_end[c] {
				return i
			}
			else {}
		}
	}
	return data.len
}

[direct_array_access]
fn token_end(data []byte) int {
	mut i := 0

	for {
		for i < data.len - 7 {
			if is_token_end[data[i]] {
				return i
			}
			i++
			if is_token_end[data[i]] {
				return i
			}
			i++
			if is_token_end[data[i]] {
				return i
			}
			i++
			if is_token_end[data[i]] {
				return i
			}
			i++
			if is_token_end[data[i]] {
				return i
			}
			i++
			if is_token_end[data[i]] {
				return i
			}
			i++
			if is_token_end[data[i]] {
				return i
			}
			i++
			if is_token_end[data[i]] {
				return i
			}
			i++
		}

		for i < data.len {
			if is_token_end[data[i]] {
				return i
			}
			i++
		}

		break
	}
	return data.len
}

// fn find_token_start(data []byte, token byte) int {
// 	mut i := data.len - 1
// 	for i >= 0 {
// 		match data[i] {
// 			token {
// 				return i
// 			}
// 			`[`, `{` {
// 				return 0
// 			}
// 			else {}
// 		}
// 		i--
// 	}

// 	return 0
// }

// cur_idx, value_found, value_offset := array_each(data[i..], cur_idx int)

// ArrayEach is used when iterating arrays, accepts a callback function with the same return arguments as `Get`.
[direct_array_access]
fn iterate_array(data []byte, cur_idx_rx int, a_idx int, cur_i int, keys ...string) (int, []byte, int, ErrorType) {
	mut cur_idx := cur_idx_rx
	if data.len == 0 {
		return cur_idx, []byte{}, 0, ErrorType.malformed_object
	}

	next := next_token(data)
	if next == -1 {
		return cur_idx, []byte{}, 0, ErrorType.malformed_object
	}

	mut offset := next + 1

	if keys.len > 0 {
		// println/('array_each search keys')
		offset = search_keys(data, ...keys)

		if offset == -1 {
			// println('line 464 ${offset}')
			return cur_idx, []byte{}, 0, ErrorType.key_path_not_found
		}

		// Go to closest value
		n0 := next_token(data[offset..])
		if n0 == -1 {
			return cur_idx, []byte{}, 0, ErrorType.malformed_json
		}

		offset += n0

		if data[offset] != `[` {
			return cur_idx, []byte{}, 0, ErrorType.malformed_array
		}

		offset++
	}

	n0 := next_token(data[offset..])
	if n0 == -1 {
		return cur_idx, []byte{}, 0, ErrorType.malformed_json
	}

	offset += n0

	if data[offset] == `]` {
		return cur_idx, []byte{}, 0, ErrorType.no_error
	}

	mut value_found := []byte{}
	mut value_offset := 0

	for true {
		v, t, _, o, e := get_(data[offset..])

		if e != .no_error {
			return cur_idx, []byte{}, 0, e
		}

		if o == 0 {
			break
		}

		if t != .non_existant {
			// println('cb called ${cur_idx} ${a_idx}')
			if cur_idx == a_idx {
				// println('they are equal')
				value_found = v.clone()
				value_offset = offset + o - v.len
				if t == .str {
					value_offset -= 2
					value_found = data[(cur_i + value_offset)..(cur_i + value_offset + v.len + 2)]
				}
			}
			cur_idx++
		}
		offset += o

		// cb := fn [data, mut curr_idx_ref, a_idx, mut value_found_ref, mut value_offset_ref, cur_i] (value []byte, value_type ValueType, offset int, err ErrorType) {
		// 				println('cb called')
		// 				if *curr_idx_ref == a_idx {
		// 					println(value)
		// 					unsafe {
		// 						*value_found_ref = value.clone()
		// 						*value_offset_ref = offset
		// 						if value_type == .str {
		// 							*value_offset_ref -= 2
		// 							*value_found_ref = data[cur_i..][(cur_i + *value_offset_ref)..(
		// 								cur_i + *value_offset_ref + value.len + 2)]
		// 						}
		// 					}
		// 				}
		// 				*curr_idx_ref++
		// 			}
		if e != .no_error {
			break
		}

		skip_to_token := next_token(data[offset..])

		// println('skip_to_token ===> ${skip_to_token}')
		if skip_to_token == -1 {
			return cur_idx, []byte{}, 0, ErrorType.malformed_array
		}
		offset += skip_to_token

		if data[offset] == `]` {
			// println('data[offset] == ]')
			// println(value_found[0..10])
			break
		}

		if data[offset] != `,` {
			// println('data[offset] == ,')
			return cur_idx, []byte{}, 0, ErrorType.malformed_array
		}

		offset++
	}

	return cur_idx, value_found, value_offset, ErrorType.no_error
}
