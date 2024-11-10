package intersection

import "src:features/rays"
import "src:features/sphere"
import "src:features/tuples"
import utils "src:utilities"

Precompute :: struct {
	t: f64,
	object: sphere.Sphere,
	point: tuples.Tuple,
	eyev: tuples.Tuple,
	normalv: tuples.Tuple,
	inside: bool,
	over_point: tuples.Tuple
}

prepare_computation :: proc(intersection: ^Intersection, ray: ^rays.Ray) -> Precompute {
	point := rays.position(ray, intersection.t)
	eyev := -ray.direction
	inside, normalv := is_inside(sphere.normal_at(&intersection.sphere, point), eyev)
	over_point := point + tuples.scalar_multiply(normalv, utils.EPS)
	return Precompute{intersection.t, intersection.sphere, point, eyev, normalv, inside, over_point}
}

@(private)
is_inside :: proc(n, e: tuples.Tuple) -> (bool, tuples.Tuple) {
	dot := tuples.dot(n, e)
	if dot < 0 {
		return true, -n
	}

	return false, n
}
