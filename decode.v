module main

import time

// Generic function to decode the data query Result to a particular type
pub fn (r Result) decode[T]() T {
	if r.value.len != 0 {
		$if T in [$int, $float] {
			return r.decode_number[T]()
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
		}
	}
	return T{}
}
