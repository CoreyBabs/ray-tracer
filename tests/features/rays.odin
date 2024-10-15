package test_features

import "core:testing"
import "src:features/rays"
import "src:features/sphere"
import "src:features/tuples"
import "core:fmt"
import utils "src:utilities"

@(test)
create_ray :: proc(t: ^testing.T) {
	origin := tuples.point(1, 2, 3)
	direction := tuples.vector(4, 5, 6)
	ray := rays.create_ray(origin, direction)
	
	testing.expect(t, tuples.tuple_equals(origin, ray.origin), "Ray origin is incorrect.")
	testing.expect(t, tuples.tuple_equals(direction, ray.direction), "Ray direction is incorrect.")
}

@(test)
ray_position :: proc(t: ^testing.T) {
	origin := tuples.point(2, 3, 4)
	direction := tuples.vector(1, 0, 0)
	ray := rays.create_ray(origin, direction)

	testing.expect(t, tuples.tuple_equals(rays.position(ray, 0), tuples.point(2, 3, 4)), "Ray position is incorrect.")
	testing.expect(t, tuples.tuple_equals(rays.position(ray, 1), tuples.point(3, 3, 4)), "Ray position is incorrect.")
	testing.expect(t, tuples.tuple_equals(rays.position(ray, -1), tuples.point(1, 3, 4)), "Ray position is incorrect.")
	testing.expect(t, tuples.tuple_equals(rays.position(ray, 2.5), tuples.point(4.5, 3, 4)), "Ray position is incorrect.")
}

@(test)
test_intersection :: proc(t: ^testing.T) {
	origin := tuples.point(0, 0, -5)
	direction := tuples.vector(0, 0, 1)
	ray := rays.create_ray(origin, direction)
	s := sphere.sphere()
	xs := sphere.intersect(s, ray)
	defer delete(xs)

	// fmt.println(xs)
	// fmt.println(xs[0])
	// fmt.println(xs[1])

	testing.expect(t, len(xs) == 2, "Intersection count does not match.")
	testing.expect(t, utils.fp_equals(xs[0], 4.0), "First intersection is not correct")
	testing.expect(t, utils.fp_equals(xs[1], 6.0), "Second intersection is not correct")
}

@(test)
test_intersection_tangent :: proc(t: ^testing.T) {
	origin := tuples.point(0, 1, -5)
	direction := tuples.vector(0, 0, 1)
	ray := rays.create_ray(origin, direction)
	s := sphere.sphere()
	xs := sphere.intersect(s, ray)
	defer delete(xs)

	testing.expect(t, len(xs) == 2, "Intersection count does not match.")
	testing.expect(t, utils.fp_equals(xs[0], 5.0), "First intersection is not correct")
	testing.expect(t, utils.fp_equals(xs[1], 5.0), "Second intersection is not correct")
}

@(test)
test_intersection_miss :: proc(t: ^testing.T) {
	origin := tuples.point(0, 2, -5)
	direction := tuples.vector(0, 0, 1)
	ray := rays.create_ray(origin, direction)
	s := sphere.sphere()
	xs := sphere.intersect(s, ray)
	defer delete(xs)

	testing.expect(t, len(xs) == 0, "Intersection count does not match.")
}

@(test)
test_intersection_inside :: proc(t: ^testing.T) {
	origin := tuples.point(0, 0, 0)
	direction := tuples.vector(0, 0, 1)
	ray := rays.create_ray(origin, direction)
	s := sphere.sphere()
	xs := sphere.intersect(s, ray)
	defer delete(xs)

	testing.expect(t, len(xs) == 2, "Intersection count does not match.")
	testing.expect(t, utils.fp_equals(xs[0], -1.0), "First intersection is not correct")
	testing.expect(t, utils.fp_equals(xs[1], 1.0), "Second intersection is not correct")
}

@(test)
test_intersection_behind :: proc(t: ^testing.T) {
	origin := tuples.point(0, 0, 5)
	direction := tuples.vector(0, 0, 1)
	ray := rays.create_ray(origin, direction)
	s := sphere.sphere()
	xs := sphere.intersect(s, ray)
	defer delete(xs)

	testing.expect(t, len(xs) == 2, "Intersection count does not match.")
	testing.expect(t, utils.fp_equals(xs[0], -6.0), "First intersection is not correct")
	testing.expect(t, utils.fp_equals(xs[1], -4.0), "Second intersection is not correct")
}
