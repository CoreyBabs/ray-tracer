package test_features

import "core:math"
import "core:testing"
import "src:features/intersection"
import "src:features/light"
import "src:features/rays"
import "src:features/shape"
import "src:features/tuples"
import "src:features/transforms"
import utils "src:utilities"

@(test)
test_shape :: proc(t: ^testing.T) {
	p := shape.plane()
	s := shape.default_shape()
	shape.set_shape(&s, p)
	n1 := shape.normal_at(&s, tuples.point(0, 0, 0))
	n2 := shape.normal_at(&s, tuples.point(10, 0, -10))
	n3 := shape.normal_at(&s, tuples.point(-5, 0, 150))
	testing.expect(t, tuples.tuple_equals(n1, tuples.vector(0, 1, 0)), "Default plane is incorrect.")
	testing.expect(t, tuples.tuple_equals(n2, tuples.vector(0, 1, 0)), "Default plane is incorrect.")
	testing.expect(t, tuples.tuple_equals(n3, tuples.vector(0, 1, 0)), "Default plane is incorrect.")
}

@(test)
test_plane_parallel_intersection :: proc(t: ^testing.T) {
	p := shape.plane()
	s := shape.default_shape()
	shape.set_shape(&s, p)

	r := rays.create_ray(tuples.point(0, 10, 0), tuples.vector(0, 0, 1))
	xs := intersection.intersect(&s, &r)
	defer delete(xs)

	testing.expect(t, xs == nil, "Parallel intersection is incorrect.")
}

@(test)
test_plane_coplanar_intersection :: proc(t: ^testing.T) {
	p := shape.plane()
	s := shape.default_shape()
	shape.set_shape(&s, p)

	r := rays.create_ray(tuples.point(0, 0, 0), tuples.vector(0, 0, 1))
	xs := intersection.intersect(&s, &r)
	defer delete(xs)

	testing.expect(t, xs == nil, "Coplanar intersection is incorrect.")
}

@(test)
test_plane_intersection_above :: proc(t: ^testing.T) {
	p := shape.plane()
	s := shape.default_shape()
	shape.set_shape(&s, p)

	r := rays.create_ray(tuples.point(0, 1, 0), tuples.vector(0, -1, 0))
	xs := intersection.intersect(&s, &r)
	defer delete(xs)


	// TODO: Should check plane equality here, but I do not currently have a way to do that.
	testing.expectf(t, len(xs) == 1, "Intersection from above is incorrect. Got %v", xs)
	testing.expect(t, xs[0].t == 1, "Intersection from above is incorrect.")
}

@(test)
test_plane_intersection_below :: proc(t: ^testing.T) {
	p := shape.plane()
	s := shape.default_shape()
	shape.set_shape(&s, p)

	r := rays.create_ray(tuples.point(0, 1, 0), tuples.vector(0, -1, 0))
	xs := intersection.intersect(&s, &r)
	defer delete(xs)


	// TODO: Should check plane equality here, but I do not currently have a way to do that.
	testing.expectf(t, len(xs) == 1, "Intersection from below is incorrect. Got %v", xs)
	testing.expect(t, xs[0].t == 1, "Intersection from below is incorrect.")
}
