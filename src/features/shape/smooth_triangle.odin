package shape

import "core:math"
import "src:features/tuples"
import "src:features/rays"
import utils "src:utilities"

SmoothTriangle :: struct {
	p1: tuples.Tuple,
	p2: tuples.Tuple,
	p3: tuples.Tuple,
	n1: tuples.Tuple,
	n2: tuples.Tuple,
	n3: tuples.Tuple,
	e1: tuples.Tuple,
	e2: tuples.Tuple
}

smooth_triangle :: proc(p1, p2, p3, n1, n2, n3: tuples.Tuple) -> SmoothTriangle {
	e1 := tuples.subtract_tuples(p2, p1)
	e2 := tuples.subtract_tuples(p3, p1)
	return SmoothTriangle{p1, p2, p3, n1, n2, n3, e1, e2}
}

new_smooth_triangle_shape :: proc(p1, p2, p3, n1, n2, n3: tuples.Tuple) -> ^Shape {
	s := new_shape()
	t := smooth_triangle(p1, p2, p3, n1, n2, n3)
	set_shape(s, t)
	return s
}

@(private)
smooth_triangle_equals :: proc(t1, t2: ^SmoothTriangle) -> bool {
	return tuples.tuple_equals(t1.p1, t2.p1) &&
		tuples.tuple_equals(t1.p2, t2.p2) &&
		tuples.tuple_equals(t1.p3, t2.p3) &&
		tuples.tuple_equals(t1.n1, t2.n1) &&
		tuples.tuple_equals(t1.n2, t2.n2) &&
		tuples.tuple_equals(t1.n3, t2.n3)
}

@(private)
smooth_triangle_normal_at :: proc(t: ^SmoothTriangle, p: tuples.Tuple, u, v: f64) -> tuples.Tuple {
	a := tuples.scalar_multiply(t.n2, u)
	b := tuples.scalar_multiply(t.n3, v)
	c := tuples.scalar_multiply(t.n1, 1 - u - v)
	return a + b + c
}

@(private)
smooth_triangle_intersect :: proc(s: ^Shape, r: ^rays.Ray) -> map[^Shape][]f64 {
	t := &s.shape.(SmoothTriangle)
	c := tuples.cross(r.direction, t.e2)
	d := tuples.dot(t.e1, c)

	if math.abs(d) < utils.EPS {
		return nil
	}

	f := 1 / d
	p := tuples.subtract_tuples(r.origin,  t.p1)
	oc := tuples.cross(p, t.e1)
	u, v := smooth_triangle_get_uv(t, r)
	if u < 0 || v < 0 || u + v > 1 || u > 1 {
		return nil
	}


	m := make(map[^Shape][]f64, 1, context.allocator)
	ts := make([]f64, 1, context.allocator)
	ts[0] = f * tuples.dot(t.e2, oc)
	m[s] = ts

	return m
}

smooth_triangle_get_uv :: proc(t: ^SmoothTriangle, r: ^rays.Ray) -> (f64, f64) {
	c := tuples.cross(r.direction, t.e2)
	d := tuples.dot(t.e1, c)
	f := 1 / d
	p := tuples.subtract_tuples(r.origin,  t.p1)
	oc := tuples.cross(p, t.e1)
	u := f * tuples.dot(p, c)
	v := f * tuples.dot(r.direction, oc)

	return u, v
}

