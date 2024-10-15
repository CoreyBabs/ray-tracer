package sphere

import "core:fmt"
import "core:math"
import "src:features/rays"
import "src:features/tuples"

Sphere :: struct {
	radius: f32,
	center: tuples.Tuple
}

sphere :: proc() -> Sphere {
	return Sphere{1, tuples.point(0, 0, 0)}
}

intersect :: proc(sphere: Sphere, ray: rays.Ray) -> []f32 {
	sphere_to_ray := tuples.subtract_tuples(ray.origin, sphere.center)

	a := tuples.dot(ray.direction, ray.direction)
	b := 2 * tuples.dot(ray.direction, sphere_to_ray)
	c := tuples.dot(sphere_to_ray, sphere_to_ray) - 1

	test := math.pow(b, 2)
	other := 4 * a * c
	discriminant := math.pow(b, 2) - (4 * a * c)

	if discriminant < 0 {
		return nil;
	}

	t1 := (-b - math.sqrt(discriminant)) / (2 * a)
	t2 := (-b + math.sqrt(discriminant)) / (2 * a)
	
	s := make([]f32, 2)
	s[0] = t1
	s[1] = t2

	return s
}
