package intersection

import "src:features/rays"
import "src:features/shape"
import "src:features/tuples"
import utils "src:utilities"

Precompute :: struct {
	t: f64,
	object: shape.Shape,
	point: tuples.Tuple,
	eyev: tuples.Tuple,
	normalv: tuples.Tuple,
	inside: bool,
	over_point: tuples.Tuple,
	reflectv: tuples.Tuple
}

prepare_computation :: proc(intersection: ^Intersection, ray: ^rays.Ray) -> Precompute {
	point := rays.position(ray, intersection.t)
	eyev := -ray.direction
	inside, normalv := is_inside(shape.normal_at(&intersection.shape, point), eyev)
	over_point := point + tuples.scalar_multiply(normalv, utils.EPS)
	reflectv := tuples.reflect(ray.direction, normalv)
	return Precompute{intersection.t, intersection.shape, point, eyev, normalv, inside, over_point, reflectv}
}

@(private)
is_inside :: proc(n, e: tuples.Tuple) -> (bool, tuples.Tuple) {
	dot := tuples.dot(n, e)
	if dot < 0 {
		return true, -n
	}

	return false, n
}
