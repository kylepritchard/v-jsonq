module vjsonq

pub struct Result {
	offset int
	error  ErrorType
pub:
	value []byte
	vtype ValueType
}

enum ValueType {
	non_existant
	str
	num
	obj
	arr
	boolean
	null
	time
	unknown
}

enum ErrorType {
	no_error
	error
	key_path_not_found
	malformed_json
	malformed_string
	malformed_array
	malformed_object
	malformed_value
	unknown_value
	json
}
