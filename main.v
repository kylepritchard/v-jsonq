module main

// import os
import time
import json
import x.json2
import vjsonq

struct Obj {
	a int
	b int
	c []int
	d map[string]i8
	e map[string]string
	f time.Time
	g []time.Time
}

struct Message {
mut:
	id      int
	b       bool
	method  string
	message string
	params  map[string]string
	arr_int []int
	arr_fl  []f32
}

fn main() {
	// jsun := os.read_file('data.json')!
	raw := '{"id": 123, "b": false, "method": "push", "message": "will it work?", "params": {"param1" : "a", "param2": "b"}, "arr_int": [1,2,3,4,5], "arr_fl":[1.0, 2.1, 3.2]}'

	// b := jsun.bytes()
	b := raw.bytes()

	// b := os.read_file('large-file.json')!.bytes()
	mut sw := time.new_stopwatch()

	// _ := vjsonq.get(b, 'deep_nest', 'a', 'b', 'f', '[2]')

	// // res := get(b, 'float')
	// // 	'[1]')
	// // x, _, _, e := get(b, 'items', '[2]')
	// // println('time: ${sw.elapsed().microseconds()}us')
	// // println(res.decode[f64]())
	// // sw.restart()
	// // a, _ := get(b, 'text').decode[string]()

	// // println('time: ${sw.elapsed().microseconds()}us')
	// // println(a)
	// sw.restart()

	// // z, _ := get(b, 'mixed_array').decode_array()

	// // println('time: ${sw.elapsed().microseconds()}us')
	// // println(z)
	// // num := z[1].int()
	// // println(num)
	// x := vjsonq.get(b, 'object_int').decode[Obj]()
	// println(sw.elapsed())
	// println(x)

	// a := vjsonq.get_all(b, [['text'], ['object', 'c', '[2]']])
	// println(a)
	// for each in a {
	// 	// println(each.value.bytestr())
	// 	println(each.decode[string]())
	// }

	// t := vjsonq.get(b, 'time').decode[time.Time]()
	// println(t)

	// d := vjsonq.get(b, 'date').decode[time.Time]()
	// println(d)
	// sw.restart()
	mut x := Message{}

	// for _ in 0 .. 1000 {
	// y := vjsonq.get(b)
	// println(sw.elapsed())
	sw.restart()

	for _ in 0 .. 1000 {
		x = vjsonq.get(b).decode[Message]()
	}

	// x = vjsonq.get(b).decode[Message]()
	println(sw.elapsed())
	println(x)

	// sw.restart()
	// for _ in 0 .. 1000 {
	// 	x = vjsonq.get(b).decode[Message]()
	// }
	// // x = vjsonq.get(b).decode[Message]()
	// println(sw.elapsed())
	// println(x)

	// sw.restart()
	// for _ in 0 .. 1000 {
	// 	x = vjsonq.get(b).decode[message]()
	// }
	// // x = vjsonq.get(b).decode[message]()
	// println(sw.elapsed())
	// println(x)
	sw.restart()
	for _ in 0 .. 1000 {
		_ := json.decode(Message, raw)!
	}
	println(sw.elapsed())

	// println(y)
	sw.restart()
	for _ in 0 .. 1000 {
		_ := json2.decode[Message](raw)!
	}
	println(sw.elapsed())

	sw.restart()
	mut d := vjsonq.Result{}
	for _ in 0 .. 1000 {
		d = vjsonq.get(b, 'params', 'param2')
	}
	println(sw.elapsed())
	println(d.value.bytestr())
}
