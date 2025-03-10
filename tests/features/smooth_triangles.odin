package test_features

import "core:testing"
import "src:features/intersection"
import "src:features/rays"
import "src:features/shape"
import "src:features/tuples"
import utils "src:utilities"

test_triangle :: proc() -> shape.SmoothTriangle {
	p1 := tuples.point(0, 1, 0)
	p2 := tuples.point(-1, 0, 0)
	p3 := tuples.point(1, 0, 0)
	n1 := tuples.vector(0, 1, 0)
	n2 := tuples.vector(-1, 0, 0)
	n3 := tuples.vector(1, 0, 0)
	return shape.smooth_triangle(p1, p2, p3, n1, n2, n3)
}

@(test)
create_smooth_triangle :: proc(t: ^testing.T) {
	p1 := tuples.point(0, 1, 0)
	p2 := tuples.point(-1, 0, 0)
	p3 := tuples.point(1, 0, 0)
	n1 := tuples.vector(0, 1, 0)
	n2 := tuples.vector(-1, 0, 0)
	n3 := tuples.vector(1, 0, 0)
	tri := test_triangle()

	testing.expect(t, tuples.tuple_equals(tri.p1, p1), "Smooth triangle p1 is not correct.")
	testing.expect(t, tuples.tuple_equals(tri.p2, p2), "Smooth triangle p2 is not correct.")
	testing.expect(t, tuples.tuple_equals(tri.p3, p3), "Smooth triangle p3 is not correct.")
	testing.expect(t, tuples.tuple_equals(tri.n1, n1), "Smooth triangle n1 is not correct.")
	testing.expect(t, tuples.tuple_equals(tri.n2, n2), "Smooth triangle n2 is not correct.")
	testing.expect(t, tuples.tuple_equals(tri.n3, n3), "Smooth triangle n3 is not correct.")
}

@(test)
intersection_smooth_triangle :: proc(t: ^testing.T) {
	r := rays.create_ray(tuples.point(-0.2, 0.3, -2), tuples.vector(0, 0, 1))
	tri := test_triangle()
	s := shape.default_shape()
	shape.set_shape(&s, tri)

	xs := intersection.intersect(&s, &r)
	defer delete(xs)

	testing.expectf(t, utils.fp_equals(xs[0].u, 0.45), "Smooth triangle intersection u is not correct. Got %v, Expected 0.45", xs[0].u)
	testing.expectf(t, utils.fp_equals(xs[0].v, 0.25), "Smooth triangle intersection v is not correct. Got %v, Expected 0.25", xs[0].v)
}

@(test)
smooth_triangle_normal :: proc(t: ^testing.T) {
	tri := test_triangle()
	s := shape.default_shape()
	shape.set_shape(&s, tri)
	i := intersection.intersection_with_uv(1, s, 0.45, 0.25)
	n := shape.normal_at(&s, tuples.point(0, 0, 0), i.u, i.v)
	en := tuples.vector(-0.5547, 0.83205, 0)

	testing.expectf(t, tuples.tuple_equals(n, en), "Smooth triangle normal is incorrect. Got: %v, Expected: %v", n, en)
}

@(test)
smooth_triangle_precompute :: proc(t: ^testing.T) {
	tri := test_triangle()
	s := shape.default_shape()
	shape.set_shape(&s, tri)
	i := intersection.intersection_with_uv(1, s, 0.45, 0.25)
	r := rays.create_ray(tuples.point(-0.2, 0.3, -2), tuples.vector(0, 0, 1))
	xs := intersection.aggregate_intersections(i)
	defer delete(xs)

	comps := intersection.prepare_computation(&i, &r, &xs)
	en := tuples.vector(-0.5547, 0.83205, 0)

	testing.expectf(t, tuples.tuple_equals(comps.normalv, en), "Smooth triangle not being precomputed. Got: %v, Expected: %v", comps.normalv, en)
}
