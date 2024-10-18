package sphere

import "src:features/rays"
import "src:features/tuples"

Sphere :: struct {
	radius: f32,
	center: tuples.Tuple
}

sphere :: proc() -> Sphere {
	return Sphere{1, tuples.point(0, 0, 0)}
}

sphere_equals :: proc(s1, s2: Sphere) -> bool {
	return s1.radius == s2.radius && tuples.tuple_equals(s1.center, s2.center)
}
