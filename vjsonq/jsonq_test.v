module vjsonq

// remove pretty print
fn strip_ws(s string) string {
	mut str := []u8{}
	for c in s {
		if !is_whitespace[c] {
			str << c
		}
	}
	return str.bytestr()
}

// Test get function
fn test_get_text() {
	res := get(vjsonq.databytes, 'text')
	assert res.value.bytestr() == 'Hello World!'
}

fn test_get_bool() {
	res := get(vjsonq.databytes, 'boolean')
	assert res.value.bytestr() == 'false'
}

fn test_get_number() {
	res := get(vjsonq.databytes, 'float')
	assert res.value.bytestr() == '12345.12345'
}

fn test_get_time() {
	res := get(vjsonq.databytes, 'time')
	assert res.value.bytestr() == '2012-04-23T18:25:43.511Z'
}

fn test_get_date() {
	res := get(vjsonq.databytes, 'date')
	assert res.value.bytestr() == '2023-03-29 11:12:00'
}

fn test_get_array() {
	res := get(vjsonq.databytes, 'array')
	assert strip_ws(res.value.bytestr()) == '[1,2,3,4,5,6,7]'
}

fn test_get_object() {
	res := get(vjsonq.databytes, 'object')
	assert strip_ws(res.value.bytestr()) == '{"a":1,"b":"string","c":[1,2,3,4]}'
}

fn test_get_array_element() {
	res := get(vjsonq.databytes, 'array', '[3]')
	assert strip_ws(res.value.bytestr()) == '4'
}

fn test_get_object_field() {
	res := get(vjsonq.databytes, 'object', 'b')
	assert strip_ws(res.value.bytestr()) == 'string'
}

fn test_get_object_field_array() {
	res := get(vjsonq.databytes, 'object', 'c')
	assert strip_ws(res.value.bytestr()) == '[1,2,3,4]'
}

const databytes = r'{
	"text": "Hello World!",
	"boolean": false,
	"time": "2012-04-23T18:25:43.511Z",
	"date": "2023-03-29 11:12:00",
	"float": 12345.12345,
	"object": {
		"a": 1,
		"b": "string",
		"c": [
			1,
			2,
			3,
			4
		]
	},
	"array": [
		1,
		2,
		3,
		4,
		5,
		6,
		7
	],
	"string_array": [
		"a",
		"b",
		"c",
		null,
		false,
		[
			1,
			2,
			3
		]
	],
	"mixed_array": [
		"a",
		1234,
		false,
		[
			1,
			2.65,
			"a",
			false,
			{
				"a": {
					"B": "sexy",
					"C": [
						1,
						2,
						3
					]
				}
			}
		]
	],
	"object_int": {
		"a": 1,
		"b": 2,
		"c": [
			1,
			2,
			3
		],
		"d": {
			"a": 4,
			"b": 5
		},
		"e": {
			"a": "a1",
			"b": "a2"
		},
		"f": "2023-03-29 11:12:00",
		"g": [
			"2012-04-23T18:25:43.511Z",
			"2012-04-23T18:25:43.511Z",
			"2012-04-23T18:25:43.511Z"
		]
	},
	"object_mixed": {
		"a": "1",
		"b": 2
	},
	"deep_nest": {
		"a": {
			"b": {
				"c": 12345,
				"d": "str",
				"f": [
					1,
					2,
					3,
					4
				]
			},
			"e": "str2"
		}
	},
	"time_arr": [
		"2012-04-23T18:25:43.511Z",
		"2012-04-23T18:25:43.511Z",
		"2012-04-23T18:25:43.511Z"
	]
}'.bytes()
