package test_features

import "core:math"
import "core:testing"
import "src:features/rays"
import "src:features/shape"
import "src:features/tuples"
import utils "src:utilities"

@(test)
cone_intersection :: proc(t: ^testing.T) {
	s := shape.cone_shape()

	origins := [3]tuples.Tuple{
		tuples.point(0, 0, -5),
		tuples.point(0, 0, -5),
		tuples.point(1, 1, -5)}
	dirs := [3]tuples.Tuple{
		tuples.vector(0, 0, 1),
		tuples.vector(1, 1, 1),
		tuples.vector(-0.5, -1, 1)}
	t1s := [3]f64{5, 8.66025, 4.55006}
	t2s := [3]f64{5, 8.66025, 49.44994}

	for i in 0..<3 {
		dir := tuples.normalize(dirs[i])
		r := rays.create_ray(origins[i], dir)

		ts := shape.intersect(&s, r)
		defer delete(ts)

		testing.expectf(t, len(ts) == 2, "cone intersection does not have 2 t values. ts: %v", ts)
		testing.expectf(t, utils.fp_equals(ts[0], t1s[i]), "t1 at index %v is incorrect. Expected: %f, Got: %f", i, t1s[i], ts[0]) 
		testing.expectf(t, utils.fp_equals(ts[1], t2s[i]), "t2 at index %v is incorrect. Expected: %f, Got: %f", i, t2s[i], ts[1]) 
	}
}

@(test)
cone_parallel :: proc(t: ^testing.T) {
	s := shape.cone_shape()

	dir := tuples.normalize(tuples.vector(0, 1, 1))
	r := rays.create_ray(tuples.point(0, 0, -1), dir)

	ts := shape.intersect(&s, r)
	defer delete(ts)

	testing.expectf(t, len(ts) == 1, "parallel cone intersection does not have 1 t values. ts: %v", ts)
	testing.expectf(t, utils.fp_equals(ts[0], 0.35355), "t value for parallel intersection is incorrect. Expected: %f, Got: %f", 0.35355, ts[0]) 
}

@(test)
cone_caps :: proc(t: ^testing.T) {
	s := shape.default_shape()
	c := shape.cone(-0.5, 0.5, true)
	shape.set_shape(&s, c)

	origins := [3]tuples.Tuple{
		tuples.point(0, 0, -5),
		tuples.point(0, 0, -0.25),
		tuples.point(0, 0, -0.25)}
	dirs := [3]tuples.Tuple{
		tuples.vector(0, 1, 0),
		tuples.vector(0, 1, 1),
		tuples.vector(0, 1, 0)}

	for i in 0..<3 {
		dir := tuples.normalize(dirs[i])
		r := rays.create_ray(origins[i], dir)

		ts := shape.intersect(&s, r)
		defer delete(ts)
		
		testing.expectf(t, len(ts) == i * 2, "Count of t values is incorrect at %v, Got %v, Expected %v", i, len(ts), i * 2)
	}
}

@(test)
cone_normal :: proc(t: ^testing.T) {
	s := shape.cone_shape()

	points := [3]tuples.Tuple{
		tuples.point(0, 0, 0),
		tuples.point(1, 1, 1),
		tuples.point(-1, -1, 0),
	}
	normals := [3]tuples.Tuple{
		tuples.vector(0, 0, 0),
		tuples.vector(0.5, -math.sqrt_f64(2)/2, 0.5),
		tuples.vector(-math.sqrt_f64(2)/2, math.sqrt_f64(2)/2, 0),
	}

	for i in 0..<3 {
		normal := shape.normal_at(&s, points[i])
		testing.expectf(t, tuples.tuple_equals(normal, normals[i]), "normals are not correct at index %v. Expected: %v, Got: %v", i, normals[i], normal) 
	}
}
