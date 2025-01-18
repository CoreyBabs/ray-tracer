package shape

import "core:math"
import "core:math/linalg"
import "src:features/light"
import "src:features/rays"
import "src:features/tuples"
import utils "src:utilities"

Sphere :: struct {
	radius: f64,
	center: tuples.Tuple,
}

sphere :: proc() -> Sphere {
	return Sphere{1, tuples.point(0, 0, 0)}
}

sphere_equals :: proc(s1, s2: ^Sphere) -> bool {
	return s1.radius == s2.radius && tuples.tuple_equals(s1.center, s2.center)
}


@(private)
sphere_normal_at :: proc(s: ^Sphere, p: tuples.Tuple) -> tuples.Tuple {
	return tuples.subtract_tuples(p, s.center)
}

@(private)
sphere_intersect :: proc(s: ^Sphere, ray: ^rays.Ray) -> []f64 {
	sphere_to_ray := tuples.subtract_tuples(ray.origin, s.center)

	a := tuples.dot(ray.direction, ray.direction)
	b := 2 * tuples.dot(ray.direction, sphere_to_ray)
	c := tuples.dot(sphere_to_ray, sphere_to_ray) - 1

	test := math.pow(b, 2)
	other := 4 * a * c
	discriminant := math.pow(b, 2) - (4 * a * c)
	if discriminant < 0 {
		return nil
	} 

	t1 := (-b - math.sqrt(discriminant)) / (2 * a)
	t2 := (-b + math.sqrt(discriminant)) / (2 * a)
	
	ts := make([]f64, 2, context.allocator)
	ts[0] = t1
	ts[1] = t2
	return ts
}
