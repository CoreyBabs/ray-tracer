package sphere

import "core:math/linalg"
import "src:features/light"
import "src:features/rays"
import "src:features/tuples"
import utils "src:utilities"

Sphere :: struct {
	radius: f32,
	center: tuples.Tuple,
	transform: matrix[4,4]f32,
	material: light.Material
}

sphere :: proc() -> Sphere {
	return Sphere{1, tuples.point(0, 0, 0), utils.matrix4_identity(), light.material()}
}

sphere_equals :: proc(s1, s2: Sphere) -> bool {
	return s1.radius == s2.radius && tuples.tuple_equals(s1.center, s2.center)
}

set_transform :: proc(s: ^Sphere, t: matrix[4,4]f32) {
	s.transform = t
}

set_material :: proc(s: ^Sphere, m: light.Material) {
	s.material = m
}

normal_at :: proc(s: Sphere, p: tuples.Tuple) -> tuples.Tuple {
	obj_p := linalg.inverse(s.transform) * p
	n := tuples.subtract_tuples(obj_p, s.center)
	wn := linalg.transpose(linalg.inverse(s.transform)) * n
	wn.w = 0
	return tuples.normalize(wn)
}
