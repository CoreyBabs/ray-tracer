package test_features

import "core:testing"
import "src:features/intersection"
import "src:features/rays"
import "src:features/sphere"
import "src:features/tuples"
import utils "src:utilities"


@(test)
create_intersection :: proc(t: ^testing.T) {
	s := sphere.sphere()
	i := intersection.intersection(3.5, s)

	testing.expect(t, utils.fp_equals(i.t, 3.5), "Intersection t value is not correct.")
	testing.expect(t, sphere.sphere_equals(s, i.sphere), "Intersection sphere is not correct.")
}

@(test)
multiple_intersections :: proc(t: ^testing.T) {
	s := sphere.sphere()
	i1 := intersection.intersection(1, s)
	i2 := intersection.intersection(2, s)
	xs := intersection.aggregate_intersections(i1, i2)
	defer delete(xs)

	testing.expect(t, len(xs) == 2, "Intersection aggregate does not have expected length.")
	testing.expect(t, xs[0].t == 1, "First intersection does not have correct t value.")
	testing.expect(t, xs[1].t == 2, "Second intersection does not have correct t value.")
}

@(test)
test_intersection :: proc(t: ^testing.T) {
	origin := tuples.point(0, 0, -5)
	direction := tuples.vector(0, 0, 1)
	ray := rays.create_ray(origin, direction)
	s := sphere.sphere()
	xs := intersection.intersect(s, ray)
	defer delete(xs)

	testing.expect(t, len(xs) == 2, "Intersection count does not match.")
	testing.expect(t, utils.fp_equals(xs[0].t, 4.0), "First intersection is not correct")
	testing.expect(t, utils.fp_equals(xs[1].t, 6.0), "Second intersection is not correct")
}

@(test)
test_intersection_tangent :: proc(t: ^testing.T) {
	origin := tuples.point(0, 1, -5)
	direction := tuples.vector(0, 0, 1)
	ray := rays.create_ray(origin, direction)
	s := sphere.sphere()
	xs := intersection.intersect(s, ray)
	defer delete(xs)

	testing.expect(t, len(xs) == 2, "Intersection count does not match.")
	testing.expect(t, utils.fp_equals(xs[0].t, 5.0), "First intersection is not correct")
	testing.expect(t, utils.fp_equals(xs[1].t, 5.0), "Second intersection is not correct")
}

@(test)
test_intersection_miss :: proc(t: ^testing.T) {
	origin := tuples.point(0, 2, -5)
	direction := tuples.vector(0, 0, 1)
	ray := rays.create_ray(origin, direction)
	s := sphere.sphere()
	xs := intersection.intersect(s, ray)
	defer delete(xs)

	testing.expect(t, len(xs) == 0, "Intersection count does not match.")
}

@(test)
test_intersection_inside :: proc(t: ^testing.T) {
	origin := tuples.point(0, 0, 0)
	direction := tuples.vector(0, 0, 1)
	ray := rays.create_ray(origin, direction)
	s := sphere.sphere()
	xs := intersection.intersect(s, ray)
	defer delete(xs)

	testing.expect(t, len(xs) == 2, "Intersection count does not match.")
	testing.expect(t, utils.fp_equals(xs[0].t, -1.0), "First intersection is not correct")
	testing.expect(t, utils.fp_equals(xs[1].t, 1.0), "Second intersection is not correct")
}

@(test)
test_intersection_behind :: proc(t: ^testing.T) {
	origin := tuples.point(0, 0, 5)
	direction := tuples.vector(0, 0, 1)
	ray := rays.create_ray(origin, direction)
	s := sphere.sphere()
	xs := intersection.intersect(s, ray)
	defer delete(xs)

	testing.expect(t, len(xs) == 2, "Intersection count does not match.")
	testing.expect(t, utils.fp_equals(xs[0].t, -6.0), "First intersection is not correct")
	testing.expect(t, utils.fp_equals(xs[1].t, -4.0), "Second intersection is not correct")
}

@(test)
intersection_spheres :: proc(t: ^testing.T) {
	origin := tuples.point(0, 0, -5)
	dir := tuples.vector(0, 0, 1)
	r := rays.create_ray(origin, dir)
	s := sphere.sphere()

	xs := intersection.intersect(s, r)
	defer delete(xs)

	testing.expect(t, len(xs) == 2, "Intersection count does not match.")
	testing.expect(t, sphere.sphere_equals(xs[0].sphere, s), "First intersection sphere does not match.")
	testing.expect(t, sphere.sphere_equals(xs[1].sphere, s), "Second intersection sphere does not match.")
}

@(test)
hit_test_all_positive :: proc(t: ^testing.T) {
	s := sphere.sphere()
	i1 := intersection.intersection(1, s)
	i2 := intersection.intersection(2, s)
	xs := intersection.aggregate_intersections(i1, i2)
	defer delete(xs)

	hit, found  := intersection.hit(xs)
	testing.expect(t, found, "Hit was not found.")
	testing.expect(t, intersection.intersection_equals(hit, i1), "Hit was not correct.")
}

@(test)
hit_test_some_negative :: proc(t: ^testing.T) {
	s := sphere.sphere()
	i1 := intersection.intersection(-1, s)
	i2 := intersection.intersection(1, s)
	xs := intersection.aggregate_intersections(i2, i1)
	defer delete(xs)

	hit, found := intersection.hit(xs)
	testing.expect(t, found, "Hit was not found.")
	testing.expect(t, intersection.intersection_equals(hit, i2), "Hit was not correct.")
}

@(test)
hit_test_all_negative :: proc(t: ^testing.T) {
	s := sphere.sphere()
	i1 := intersection.intersection(-2, s)
	i2 := intersection.intersection(-1, s)
	xs := intersection.aggregate_intersections(i2, i1)
	defer delete(xs)

	hit, found := intersection.hit(xs)
	testing.expect(t,  !found, "Hit was found when it should not have been.")
}

@(test)
hit_test_many :: proc(t: ^testing.T) {
	s := sphere.sphere()
	i1 := intersection.intersection(5, s)
	i2 := intersection.intersection(7, s)
	i3 := intersection.intersection(-3, s)
	i4 := intersection.intersection(2, s)
	xs := intersection.aggregate_intersections(i1, i2, i3, i4)
	defer delete(xs)

	hit, found := intersection.hit(xs)
	testing.expect(t, found, "Hit was not found.")
	testing.expect(t, intersection.intersection_equals(hit, i4), "Hit was not correct.")
}


