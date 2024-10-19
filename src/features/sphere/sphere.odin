package sphere

import "src:features/rays"
import "src:features/tuples"
import utils "src:utilities"

Sphere :: struct {
	radius: f32,
	center: tuples.Tuple,
	transform: matrix[4,4]f32
}

sphere :: proc() -> Sphere {
	return Sphere{1, tuples.point(0, 0, 0), utils.matrix4_identity()}
}

sphere_equals :: proc(s1, s2: Sphere) -> bool {
	return s1.radius == s2.radius && tuples.tuple_equals(s1.center, s2.center)
}

set_transform :: proc(s: ^Sphere, t: matrix[4,4]f32) {
	s.transform = t
}
