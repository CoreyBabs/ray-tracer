package shape

import "core:math/linalg"
import "src:features/light"
import "src:features/rays"
import "src:features/tuples"
import utils "src:utilities"

ShapeType :: union {
	Sphere,
	Plane,
	Cube,
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
	case Cube:
		shape_normal = cube_normal_at(&t, obj_p)
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
	case Cube:
		return cube_intersect(&t, &s.ray)
	case:
		panic("Unknown shape type. %v")
	}
}

shape_equals :: proc(s1, s2: ^Shape) -> bool {
	if type_of(s1.shape) != type_of(s2.shape) {
		return false
	}

	if !utils.matrix4_equals_f64(s1.transform, s2.transform) {
		return false
	}

	if !light.material_equals(&s1.material, &s2.material) {
		return false
	}

	switch &t in s1.shape {
	case Sphere:
		return sphere_equals(&s1.shape.(Sphere), &s2.shape.(Sphere))
	case Plane:
		return plane_equals(&s1.shape.(Plane), &s2.shape.(Plane))
	case Cube:
		return cube_equals(&s1.shape.(Cube), &s2.shape.(Cube))
	case:
		panic("Unknown shape type.")
	}
}

shape_search :: proc(shapes: ^[dynamic]^Shape, value: ^Shape) -> (int, bool) {
	for &x, i in shapes {
		if shape_equals(&x^, value) {
			return i, true
		}
	}

	return -1, false
}
