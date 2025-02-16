package test_features

import "core:testing"
import "src:features/rays"
import "src:features/shape"
import "src:features/tuples"
import utils "src:utilities"

@(test)
cube_intersection :: proc(t: ^testing.T) {
	c := shape.cube_shape()
	
	origins := [7]tuples.Tuple{
		tuples.point(5, 0.5, 0),
		tuples.point(-5, 0.5, 0),
		tuples.point(0.5, 5, 0),
		tuples.point(0.5, -5, 0),
		tuples.point(0.5, 0, 5),
		tuples.point(0.5, 0, -5),
		tuples.point(0, 0.5, 0)}
	dirs := [7]tuples.Tuple{
		tuples.vector(-1, 0, 0),
		tuples.vector(1, 0, 0),
		tuples.vector(0, -1, 0),
		tuples.vector(0, 1, 0),
		tuples.vector(0, 0, -1),
		tuples.vector(0, 0, 1),
		tuples.vector(0, 0, 1)}
	t1s := [7]f64{4, 4, 4, 4, 4, 4, -1}
	t2s := [7]f64{6, 6, 6, 6, 6, 6, 1}

	for i in 0..<7 {
		r := rays.create_ray(origins[i], dirs[i])
		xs := shape.intersect(&c, &r)
		defer delete(xs)

		testing.expectf(t, utils.fp_equals(xs[&c][0], t1s[i]), "t1 at index %v is incorrect. Expected: %f, Got: %f", i, t1s[i], xs[&c][0]) 
		testing.expectf(t, utils.fp_equals(xs[&c][1], t2s[i]), "t2 at index %v is incorrect. Expected: %f, Got: %f", i, t2s[i], xs[&c][1]) 
	}
}

@(test)
cube_miss :: proc(t: ^testing.T) {
	c := shape.cube_shape()
	
	origins := [6]tuples.Tuple{
		tuples.point(-2, 0, 0),
		tuples.point(0, -2, 0),
		tuples.point(0, 0, -2),
		tuples.point(2, 0, 2),
		tuples.point(0, 2, 2),
		tuples.point(2, 2, 0),
	}
	dirs := [6]tuples.Tuple{
		tuples.vector(0.2673, 0.5347, 0.8018),
		tuples.vector(0.8018, 0.2673, 0.5345),
		tuples.vector(0.5345, 0.8018, 0.2673),
		tuples.vector(0, 0, -1),
		tuples.vector(0, -1, 0),
		tuples.vector(-1, 0, 0)
	}

	for i in 0..<6 {
		r := rays.create_ray(origins[i], dirs[i])
		xs := shape.intersect(&c, &r)
		defer delete(xs)

		testing.expectf(t, xs == nil, "xs are not nil at index %v is incorrect. Got: %v", i, xs) 
	}
}

@(test)
cube_normal :: proc(t: ^testing.T) {
	c := shape.cube_shape()
	
	points := [8]tuples.Tuple{
		tuples.point(1, 0.5, -0.8),
		tuples.point(-1, -0.2, 0.9),
		tuples.point(-0.4, 1, -0.1),
		tuples.point(0.3, -1, -0.7),
		tuples.point(-0.6, 0.3, 1),
		tuples.point(0.4, 0.4, -1),
		tuples.point(1, 1, 1),
		tuples.point(-1, -1, -1),
	}
	normals := [8]tuples.Tuple{
		tuples.vector(1, 0, 0),
		tuples.vector(-1, 0, 0),
		tuples.vector(0, 1, 0),
		tuples.vector(0, -1, 0),
		tuples.vector(0, 0, 1),
		tuples.vector(0, 0, -1),
		tuples.vector(1, 0, 0),
		tuples.vector(-1, 0, 0),
	}

	for i in 0..<8 {
		normal := shape.normal_at(&c, points[i])
		testing.expectf(t, tuples.tuple_equals(normal, normals[i]), "normals are not correct at index %v. Expected: %v, Got: %v", i, normals[i], normal) 
	}
}
