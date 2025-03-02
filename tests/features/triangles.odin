package test_features

import "core:testing"
import "src:features/intersection"
import "src:features/rays"
import "src:features/shape"
import "src:features/tuples"
import utils "src:utilities"

@(test)
traingle :: proc(t: ^testing.T) {
	p1 := tuples.point(0, 1, 0)
	p2 := tuples.point(-1, 0, 0)
	p3 := tuples.point(1, 0, 0)
	tri := shape.triangle(p1, p2, p3)
	e1 := tuples.vector(-1, -1, 0)
	e2 := tuples.vector(1, -1, 0)
	normal := tuples.vector(0, 0, -1)

	testing.expectf(t, tuples.tuple_equals(tri.p1, p1), "Triangle p1 is not correct. Got %v, Expected: %v", tri.p1, p1)
	testing.expectf(t, tuples.tuple_equals(tri.p2, p2), "Triangle p2 is not correct. Got %v, Expected: %v", tri.p2, p2)
	testing.expectf(t, tuples.tuple_equals(tri.p3, p3), "Triangle p3 is not correct. Got %v, Expected: %v", tri.p3, p3)
	testing.expectf(t, tuples.tuple_equals(tri.e1, e1), "Triangle edge 1 is not correct. Got %v, Expected: %v", tri.e1, e1)
	testing.expectf(t, tuples.tuple_equals(tri.e2, e2), "Triangle edge 2 is not correct. Got %v, Expected: %v", tri.e2, e2)
	testing.expectf(t, tuples.tuple_equals(tri.normal, normal), "Triangle normal is not correct. Got %v, Expected: %v", tri.normal, normal)
}

@(test)
triangle_normal :: proc(t: ^testing.T) {
	tri := shape.triangle_shape(tuples.point(0, 1, 0), tuples.point(-1, 0, 0), tuples.point(1, 0, 0))
	n1 := shape.normal_at(&tri, tuples.point(0, 0.5, 0))
	n2 := shape.normal_at(&tri, tuples.point(-0.5, 0.75, 0))
	n3 := shape.normal_at(&tri, tuples.point(0.5, 0.25, 0))
	expected := tri.shape.(shape.Triangle).normal

	testing.expectf(t, tuples.tuple_equals(expected, n1), "Triangle normal is not correct. Got %v, Expected: %v", n1, expected)
	testing.expectf(t, tuples.tuple_equals(expected, n2), "Triangle normal is not correct. Got %v, Expected: %v", n2, expected)
	testing.expectf(t, tuples.tuple_equals(expected, n3), "Triangle normal is not correct. Got %v, Expected: %v", n3, expected)
}

@(test)
triangle_parallel_intersect :: proc(t: ^testing.T) {
	tri := shape.triangle_shape(tuples.point(0, 1, 0), tuples.point(-1, 0, 0), tuples.point(1, 0, 0))
	r := rays.create_ray(tuples.point(0, -1, -2), tuples.vector(0, 1, 0)) 
	xs := intersection.intersect(&tri, &r)

	testing.expect(t, xs == nil, "Parallel ray found an intersection.")
}

@(test)
triangle_miss_1 :: proc(t: ^testing.T) {
	tri := shape.triangle_shape(tuples.point(0, 1, 0), tuples.point(-1, 0, 0), tuples.point(1, 0, 0))
	r := rays.create_ray(tuples.point(1, 1, -2), tuples.vector(0, 0, 1)) 
	xs := intersection.intersect(&tri, &r)

	testing.expect(t, xs == nil, "Ray missing e2 found an intersection.")
}

@(test)
triangle_miss_2 :: proc(t: ^testing.T) {
	tri := shape.triangle_shape(tuples.point(0, 1, 0), tuples.point(-1, 0, 0), tuples.point(1, 0, 0))
	r := rays.create_ray(tuples.point(-1, 1, -2), tuples.vector(0, 0, 1)) 
	xs := intersection.intersect(&tri, &r)

	testing.expect(t, xs == nil, "Ray missing e2 found an intersection.")
}

@(test)
triangle_miss_3 :: proc(t: ^testing.T) {
	tri := shape.triangle_shape(tuples.point(0, 1, 0), tuples.point(-1, 0, 0), tuples.point(1, 0, 0))
	r := rays.create_ray(tuples.point(0, -1, -2), tuples.vector(0, 0, 1)) 
	xs := intersection.intersect(&tri, &r)

	testing.expect(t, xs == nil, "Ray missing e2 found an intersection.")
}

@(test)
triangle_hit :: proc(t: ^testing.T) {
	tri := shape.triangle_shape(tuples.point(0, 1, 0), tuples.point(-1, 0, 0), tuples.point(1, 0, 0))
	r := rays.create_ray(tuples.point(0, 0.5, -2), tuples.vector(0, 0, 1)) 
	xs := intersection.intersect(&tri, &r)
	defer delete(xs)

	testing.expectf(t, len(xs) == 1, "Triangle hit got incorrect number of intersections. Got length: %v, expected: %v", len(xs), 1)
	testing.expectf(t, utils.fp_equals(xs[0].t, 2), "Triangle intersection t value is not correct. Got: %v, expected: %v", xs[0].t, 2.0)
}
