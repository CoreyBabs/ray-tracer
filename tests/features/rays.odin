package test_features

import "core:testing"
import "src:features/rays"
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
