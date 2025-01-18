package shape

import "core:math/linalg"
import "src:features/light"
import "src:features/rays"
import "src:features/tuples"
import utils "src:utilities"

ShapeType :: union {
	Sphere,
	Plane,
}

Shape :: struct {
	transform: matrix[4,4]f64,
	material: light.Material,
	shape: ShapeType,
	ray: rays.Ray
}

default_shape :: proc() -> Shape {
	return Shape{utils.matrix4_identity(), light.material(), sphere(), rays.Ray{}}
}

set_transform :: proc(s: ^Shape, t: matrix[4,4]f64) {
	s.transform = t
}

set_material :: proc(s: ^Shape, m: light.Material) {
	s.material = m
}

set_shape :: proc(s: ^Shape, st: ShapeType) {
	s.shape = st
}

normal_at :: proc(s: ^Shape, p: tuples.Tuple) -> tuples.Tuple {
	obj_p := linalg.inverse(s.transform) * p
	shape_normal: tuples.Tuple
	switch &t in s.shape {
	case Sphere:
		shape_normal = sphere_normal_at(&t, obj_p)
	case Plane:
		shape_normal = plane_normal_at(&t, obj_p)
	case:
		panic("Unknown shape type.")
	}

	wn := linalg.transpose(linalg.inverse(s.transform)) * shape_normal
	wn.w = 0
	return tuples.normalize(wn)
}

intersect :: proc(s: ^Shape, ray: rays.Ray) -> []f64 {
	s.ray = ray
	switch &t in s.shape {
	case Sphere:
		return sphere_intersect(&t, &s.ray)
	case Plane:
		return plane_intersect(&t, &s.ray)
	case:
		panic("Unknown shape type.")
	}
}

shape_equals :: proc(s1, s2: ^Shape) -> bool {
	if type_of(s1.shape) != type_of(s2.shape) {
		return false
	}

	switch &t in s1.shape {
	case Sphere:
		return sphere_equals(&s1.shape.(Sphere), &s2.shape.(Sphere))
	case Plane:
		return plane_equals(&s1.shape.(Plane), &s2.shape.(Plane))
	case:
		panic("Unknown shape type.")
	}
}
