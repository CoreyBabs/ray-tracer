package shape

import "core:math"
import "src:features/tuples"
import "src:features/rays"
import utils "src:utilities"

Triangle :: struct {
	p1: tuples.Tuple,
	p2: tuples.Tuple,
	p3: tuples.Tuple,
	e1: tuples.Tuple,
	e2: tuples.Tuple,
	normal: tuples.Tuple,
}

triangle :: proc(p1, p2, p3: tuples.Tuple) -> Triangle {
	e1 := tuples.subtract_tuples(p2, p1)
	e2 := tuples.subtract_tuples(p3, p1)
	normal := tuples.normalize(tuples.cross(e2, e1))
	return Triangle{p1, p2, p3, e1, e2, normal}
}

triangle_shape :: proc(p1, p2, p3: tuples.Tuple) -> Shape {
	s := default_shape()
	t := triangle(p1, p2, p3)
	set_shape(&s, t)
	return s
}

new_triangle_shape :: proc(p1, p2, p3: tuples.Tuple) -> ^Shape {
	s := new_shape()
	t := triangle(p1, p2, p3)
	set_shape(s, t)
	return s
}

@(private)
triangle_equals :: proc(t1, t2: ^Triangle) -> bool {
	return tuples.tuple_equals(t1.p1, t2.p1) &&
		tuples.tuple_equals(t1.p2, t2.p2) &&
		tuples.tuple_equals(t1.p3, t2.p3)
}

@(private)
triangle_normal_at :: proc(t: ^Triangle, p: tuples.Tuple) -> tuples.Tuple {
	return t.normal
}

@(private)
triangle_intersect :: proc(s: ^Shape, r: ^rays.Ray) -> map[^Shape][]f64 {
	t := &s.shape.(Triangle)
	c := tuples.cross(r.direction, t.e2)
	d := tuples.dot(t.e1, c)

	if math.abs(d) < utils.EPS {
		return nil
	}

	f := 1 / d
	p := tuples.subtract_tuples(r.origin,  t.p1)
	u := f * tuples.dot(p, c)
	oc := tuples.cross(p, t.e1)
	v := f * tuples.dot(r.direction, oc)
	
	if u < 0 || v < 0 || u + v > 1 || u > 1 {
		return nil
	}


	m := make(map[^Shape][]f64, 1, context.allocator)
	ts := make([]f64, 1, context.allocator)
	ts[0] = f * tuples.dot(t.e2, oc)
	m[s] = ts

	return m
}
