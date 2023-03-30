module main

import os
import time
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

fn main() {
	jsun := os.read_file('data.json')!

	b := jsun.bytes()

	// b := os.read_file('large-file.json')!.bytes()
	mut sw := time.new_stopwatch()
	_ := vjsonq.get(b, 'deep_nest', 'a', 'b', 'f', '[2]')

	// res := get(b, 'float')
	// 	'[1]')
	// x, _, _, e := get(b, 'items', '[2]')
	// println('time: ${sw.elapsed().microseconds()}us')
	// println(res.decode[f64]())
	// sw.restart()
	// a, _ := get(b, 'text').decode[string]()

	// println('time: ${sw.elapsed().microseconds()}us')
	// println(a)
	sw.restart()

	// z, _ := get(b, 'mixed_array').decode_array()

	// println('time: ${sw.elapsed().microseconds()}us')
	// println(z)
	// num := z[1].int()
	// println(num)
	x := vjsonq.get(b, 'object_int').decode[Obj]()
	println(sw.elapsed())
	println(x)

	a := vjsonq.get_all(b, [['text'], ['object', 'c', '[2]']])
	println(a)
	for each in a {
		// println(each.value.bytestr())
		println(each.decode[string]())
	}

	t := vjsonq.get(b, 'time').decode[time.Time]()
	println(t)

	d := vjsonq.get(b, 'date').decode[time.Time]()
	println(d)
}
