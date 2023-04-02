module vjsonq

import time
import math

fn (r Result) decode_number[T]() T {
	mut val := T{}
	if r.vtype != .num {
		return val
	}
	converted := bytes_to_number(r.value)
	$if T.typ is i8 {
		val = i8(converted)
	} $else $if T.typ is i16 {
		val = i16(converted)
	} $else $if T.typ is int {
		val = int(converted)
	} $else $if T.typ is i64 {
		val = i64(converted)
	} $else $if T.typ is u8 {
		val = u8(converted)
	} $else $if T.typ is u16 {
		val = u16(converted)
	} $else $if T.typ is u32 {
		val = u32(converted)
	} $else $if T.typ is u64 {
		val = u64(converted)
	} $else $if T.typ is f32 {
		val = f32(converted)
	} $else $if T.typ is f64 {
		val = f64(converted)
	}
	return val
}

// [inline]
fn bytes_to_number(num []u8) f64 {
	mut result := f64(0.0)
	mut frac := f64(0.0)
	mut i := 0
	mut negative := false
	if i == 0 && num[i] == `-` {
		negative = true
		i++
	}
	for i < num.len {
		if num[i] == `.` {
			i++
			unsafe {
				goto frac
			}
		}
		result = result * 10 + (num[i] - 48)
		i++
	}
	unsafe {
		goto end
	}
	frac:
	// println('doing frac')
	decimal_places := num.len - i

	// println(dec_l)
	for i < num.len {
		frac = frac * 10 + (num[i] - 48)
		i++
	}
	frac = frac / math.pow(10, decimal_places)

	end:
	result += frac
	if negative {
		result *= -1
	}
	return result
}

fn (r Result) decode_time() time.Time {
	str := r.value.bytestr()
	if t := time.parse(str) {
		return t
	} else if t := time.parse_iso8601(str) {
		return t
	} else if t := time.parse_rfc3339(str) {
		return t
	} else if t := time.parse_rfc2822(str) {
		return t
	}

	return time.parse('1970-1-1 00:00:00') or { return time.now() }
}

fn decode_time(str string) time.Time {
	if t := time.parse(str) {
		return t
	} else if t := time.parse_iso8601(str) {
		return t
	} else if t := time.parse_rfc3339(str) {
		return t
	} else if t := time.parse_rfc2822(str) {
		return t
	}

	return time.parse('1970-1-1 00:00:00') or { return time.now() }
}
