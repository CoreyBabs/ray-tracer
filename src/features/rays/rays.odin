package rays

import "src:features/transforms"
import "src:features/tuples"

Ray :: struct {
	origin: tuples.Tuple,
	direction: tuples.Tuple
}

create_ray :: proc(origin, direction: tuples.Tuple) -> Ray {
	return Ray{origin, direction}
}

position :: proc(ray: Ray, t: f32) -> tuples.Tuple {
	velocity := tuples.scalar_multiply(ray.direction, t)
	return tuples.add_tuples(ray.origin, velocity)
}

transform :: proc(ray: Ray, transform: matrix[4, 4]f32) -> Ray {
	origin := transform * ray.origin
	direction := transform * ray.direction
	return Ray{origin, direction}
}
