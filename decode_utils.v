module main

import time

fn (r Result) decode_number[T]() T {
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
