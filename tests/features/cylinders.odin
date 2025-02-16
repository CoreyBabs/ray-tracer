package test_features

import "core:math"
import "core:testing"
import "src:features/rays"
import "src:features/shape"
import "src:features/tuples"
import utils "src:utilities"

@(test)
cylinder_miss :: proc(t: ^testing.T) {
	cyl := shape.cylinder_shape()

	origins := [3]tuples.Tuple{
		tuples.point(1, 0, 0),
		tuples.point(0, 0, 0),
		tuples.point(0, 0, -5)}
	dirs := [3]tuples.Tuple{
		tuples.vector(0, 1, 0),
		tuples.vector(0, 1, 0),
		tuples.vector(1, 1, 1)}

	for i in 0..<3 {
		dir := tuples.normalize(dirs[i])
		r := rays.create_ray(origins[i], dir)

		ts := shape.intersect(&cyl, &r)
		defer utils.free_map(&ts)
		defer delete(ts)

		testing.expectf(t, ts == nil, "ts at index %v is incorrect. Expected: nil, Got: %v", i, ts) 
	}
}

@(test)
cylinder_hit :: proc(t: ^testing.T) {
	cyl := shape.cylinder_shape()

	origins := [3]tuples.Tuple{
		tuples.point(1, 0, -5),
		tuples.point(0, 0, -5),
		tuples.point(0.5, 0, -5)}
	dirs := [3]tuples.Tuple{
		tuples.vector(0, 0, 1),
		tuples.vector(0, 0, 1),
		tuples.vector(0.1, 1, 1)}
	t1s := [3]f64{5, 4, 6.80798}
	t2s := [3]f64{5, 6, 7.08872}

	for i in 0..<3 {
		dir := tuples.normalize(dirs[i])
		r := rays.create_ray(origins[i], dir)

		ts := shape.intersect(&cyl, &r)
		defer utils.free_map(&ts)
		defer delete(ts)

		testing.expectf(t, utils.fp_equals(ts[&cyl][0], t1s[i]), "t1 at index %v is incorrect. Expected: %f, Got: %f", i, t1s[i], ts[&cyl][0]) 
		testing.expectf(t, utils.fp_equals(ts[&cyl][1], t2s[i]), "t2 at index %v is incorrect. Expected: %f, Got: %f", i, t2s[i], ts[&cyl][1]) 
	}
}

@(test)
cylinder_normal :: proc(t: ^testing.T) {
	c := shape.cylinder_shape()
	
	points := [4]tuples.Tuple{
		tuples.point(1, 0, 0),
		tuples.point(0, 5, -1),
		tuples.point(0, -2, 1),
		tuples.point(-1, 1, 0),
	}
	normals := [4]tuples.Tuple{
		tuples.vector(1, 0, 0),
		tuples.vector(0, 0, -1),
		tuples.vector(0, 0, 1),
		tuples.vector(-1, 0, 0),
	}

	for i in 0..<4 {
		normal := shape.normal_at(&c, points[i])
		testing.expectf(t, tuples.tuple_equals(normal, normals[i]), "normals are not correct at index %v. Expected: %v, Got: %v", i, normals[i], normal) 
	}
}

@(test)
default_cylinder :: proc(t: ^testing.T) {
	cyl := shape.default_cylinder()

	testing.expectf(t, math.is_inf_f64(cyl.min, -1), "Default cylinder min value is not -infinity. Got %f", cyl.min)
	testing.expectf(t, math.is_inf_f64(cyl.max, 1), "Default cylinder max value is not infinity. Got %f", cyl.max)
}

@(test)
truncated_cylinder :: proc(t: ^testing.T) {
	s := shape.default_shape()
	cyl := shape.cylinder(1, 2)
	shape.set_shape(&s, cyl)

	origins := [6]tuples.Tuple{
		tuples.point(0, 1.5, 0),
		tuples.point(0, 3, -5),
		tuples.point(0, 0, -5),
		tuples.point(0, 2, -5),
		tuples.point(0, 1, -5),
		tuples.point(0, 1.5, -2)}
	dirs := [6]tuples.Tuple{
		tuples.vector(0.1, 1, 0),
		tuples.vector(0, 0, 1),
		tuples.vector(0, 0, 1),
		tuples.vector(0, 0, 1),
		tuples.vector(0, 0, 1),
		tuples.vector(0, 0, 1)}

	for i in 0..<6 {
		ex := i == 5 ? 2 : 0

		dir := tuples.normalize(dirs[i])
		r := rays.create_ray(origins[i], dir)

		ts := shape.intersect(&s, &r)
		defer utils.free_map(&ts)
		defer delete(ts)
		
		testing.expectf(t, len(ts[&s]) == ex, "Count of t values is incorrect at %v, Got %v, Expected %v", i, len(ts[&s]), ex)
	}
}

@(test)
closed_cylinder :: proc(t: ^testing.T) {
	cyl := shape.default_cylinder()
	testing.expect(t, !cyl.closed, "Default cylinder is not closed")
}

@(test)
closed_cylinder_intersection :: proc(t: ^testing.T) {
	s := shape.default_shape()
	cyl := shape.cylinder(1, 2, true)
	shape.set_shape(&s, cyl)

	origins := [5]tuples.Tuple{
		tuples.point(0, 3, 0),
		tuples.point(0, 3, -2),
		tuples.point(0, 4, -2),
		tuples.point(0, 0, -2),
		tuples.point(0, -1, -2)}
	dirs := [5]tuples.Tuple{
		tuples.vector(0, -1, 0),
		tuples.vector(0, -1, 2),
		tuples.vector(0, -1, 1),
		tuples.vector(0, 1, 2),
		tuples.vector(0, 1, 1)}

	for i in 0..<5 {
		dir := tuples.normalize(dirs[i])
		r := rays.create_ray(origins[i], dir)

		ts := shape.intersect(&s, &r)
		defer utils.free_map(&ts)
		defer delete(ts)
		
		testing.expectf(t, len(ts[&s]) == 2, "Count of t values is incorrect at %v, Got %v, Expected %v", i, len(ts[&s]), 2)
	}
}

@(test)
closed_cylinder_normal :: proc(t: ^testing.T) {
	s := shape.default_shape()
	cyl := shape.cylinder(1, 2, true)
	shape.set_shape(&s, cyl)
	
	points := [6]tuples.Tuple{
		tuples.point(0, 1, 0),
		tuples.point(0.5, 1, 0),
		tuples.point(0, 1, 0.5),
		tuples.point(0, 2, 0),
		tuples.point(0.5, 2, 0),
		tuples.point(0, 2, 0.5),
	}
	normals := [6]tuples.Tuple{
		tuples.vector(0, -1, 0),
		tuples.vector(0, -1, 0),
		tuples.vector(0, -1, 0),
		tuples.vector(0, 1, 0),
		tuples.vector(0, 1, 0),
		tuples.vector(0, 1, 0),
	}

	for i in 0..<6 {
		normal := shape.normal_at(&s, points[i])
		testing.expectf(t, tuples.tuple_equals(normal, normals[i]), "normals are not correct at index %v. Expected: %v, Got: %v", i, normals[i], normal) 
	}
}
