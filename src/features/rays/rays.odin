package rays

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

