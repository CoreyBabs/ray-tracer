package test_features

import "core:testing"
import "src:features/rays"
import "src:features/transforms"
import "src:features/tuples"

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
ray_translate :: proc(t: ^testing.T) {
	origin := tuples.point(1, 2, 3)
	direction := tuples.vector(0, 1, 0)
	ray := rays.create_ray(origin, direction)

	transform := transforms.get_translation_matrix(3, 4, 5)
	r2 := rays.transform(ray, transform)

	expected_origin := tuples.point(4, 6, 8)
	expected_direction := tuples.vector(0, 1, 0)

	testing.expect(t, tuples.tuple_equals(r2.origin, expected_origin), "Translated ray origin is incorrect.")
	testing.expect(t, tuples.tuple_equals(r2.direction, expected_direction), "Translated ray direction is incorrect.")
}

@(test)
ray_scale :: proc(t: ^testing.T) {
	origin := tuples.point(1, 2, 3)
	direction := tuples.vector(0, 1, 0)
	ray := rays.create_ray(origin, direction)

	transform := transforms.get_scale_matrix(2, 3, 4)
	r2 := rays.transform(ray, transform)

	expected_origin := tuples.point(2, 6, 12)
	expected_direction := tuples.vector(0, 3, 0)

	testing.expect(t, tuples.tuple_equals(r2.origin, expected_origin), "Scaled ray origin is incorrect.")
	testing.expect(t, tuples.tuple_equals(r2.direction, expected_direction), "Scaled ray direction is incorrect.")
}
