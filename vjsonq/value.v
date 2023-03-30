module vjsonq

pub union Number {
	i8_  i8
	i16_ i16
	int_ int
	i64_ i64
	u8_  u8
	u16_ u16
	u32_ u32
	u64_ u64
	f32_ f32
	f64_ f64
}

pub type Value = Number
	| []Value
	| bool
	| f32
	| f64
	| i16
	| i64
	| i8
	| int
	| map[string]Value
	| string
	| u16
	| u32
	| u64
	| u8

pub fn (v Value) i8() i8 {
	match v {
		i8 {
			return v
		}
		i16, int, i64, u8, u16, u32, u64, f32, f64, bool {
			return i8(v)
		}
		string {
			return v.i8()
		}
		else {
			return 0
		}
	}
}

// i16 - TODO
pub fn (v Value) i16() i16 {
	match v {
		i16 {
			return v
		}
		i8, int, i64, u8, u16, u32, u64, f32, f64, bool {
			return i16(v)
		}
		string {
			return v.i16()
		}
		else {
			return 0
		}
	}
}

// int uses `Any` as an integer.
pub fn (v Value) int() int {
	match v {
		int {
			return v
		}
		i8, i16, i64, u8, u16, u32, u64, f32, f64, bool {
			return int(v)
		}
		string {
			return v.int()
		}
		else {
			return 0
		}
	}
}

// i64 uses `Any` as a 64-bit integer.
pub fn (v Value) i64() i64 {
	match v {
		i64 {
			return v
		}
		i8, i16, int, u8, u16, u32, u64, f32, f64, bool {
			return i64(v)
		}
		string {
			return v.i64()
		}
		else {
			return 0
		}
	}
}

// u64 uses `Any` as a 64-bit unsigned integer.
pub fn (v Value) u64() u64 {
	match v {
		u64 {
			return v
		}
		u8, u16, u32, i8, i16, int, i64, f32, f64, bool {
			return u64(v)
		}
		string {
			return v.u64()
		}
		else {
			return 0
		}
	}
}

// f32 uses `Any` as a 32-bit vloat.
pub fn (v Value) f32() f32 {
	match v {
		f32 {
			return v
		}
		bool, i8, i16, int, i64, u8, u16, u32, u64, f64 {
			return f32(v)
		}
		string {
			return v.f32()
		}
		else {
			return 0.0
		}
	}
}

// f64 uses `Any` as a 64-bit vloat.
pub fn (v Value) f64() f64 {
	match v {
		f64 {
			return v
		}
		i8, i16, int, i64, u8, u16, u32, u64, f32 {
			return f64(v)
		}
		string {
			return v.f64()
		}
		else {
			return 0.0
		}
	}
}

// bool uses `Any` as a bool.
pub fn (v Value) bool() bool {
	match v {
		bool {
			return v
		}
		string {
			if v == 'false' {
				return false
			}
			if v == 'true' {
				return true
			}
			if v.len > 0 {
				return v != '0' && v != '0.0'
			} else {
				return false
			}
		}
		i8, i16, int, i64 {
			return i64(v) != 0
		}
		u8, u16, u32, u64 {
			return u64(v) != 0
		}
		f32, f64 {
			return f64(v) != 0.0
		}
		else {
			return false
		}
	}
}

// to_time uses `Any` as a time.Time.
// pub fn (v Value) to_time() !time.Time {
// 	match v {
// 		time.Time {
// 			return v
// 		}
// 		i64 {
// 			return time.unix(v)
// 		}
// 		string {
// 			if v.len == 10 && v[4] == `-` && v[7] == `-` {
// 				// just a date in the format `2001-01-01`
// 				return time.parse_iso8601(v)!
// 			}
// 			is_rfc3339 := v.len == 24 && v[23] == `Z` && v[10] == `T`
// 			if is_rfc3339 {
// 				return time.parse_rfc3339(v)!
// 			}
// 			mut is_unix_timestamp := true
// 			for c in v {
// 				if c == `-` || (c >= `0` && c <= `9`) {
// 					continue
// 				}
// 				is_unix_timestamp = false
// 				break
// 			}
// 			if is_unix_timestamp {
// 				return time.unix(v.i64())
// 			}

// 			// TODO - parse_iso8601
// 			// TODO - parse_rfc2822
// 			return time.parse(v)!
// 		}
// 		else {
// 			return error('not a time value: ${v} of type: ${v.type_name()}')
// 		}
// 	}
// }
