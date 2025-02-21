package shape

import "core:math/linalg"
import "core:slice"
import "src:features/light"
import "src:features/rays"
import "src:features/tuples"
import utils "src:utilities"

ShapeType :: union {
	Sphere,
	Plane,
	Cube,
	Cylinder,
	Cone,
	Group,
}

Shape :: struct {
	transform: matrix[4,4]f64,
	material: light.Material,
	shape: ShapeType,
	ray: rays.Ray,
	parent: ^Shape
}

default_shape :: proc() -> Shape {
	return Shape{utils.matrix4_identity(), light.material(), sphere(), rays.Ray{}, nil}
}

new_shape :: proc() -> ^Shape {
	ptr := new(Shape)
	ptr.transform = utils.matrix4_identity()
	ptr.material = light.material()
	ptr.shape = sphere()
	ptr.ray = rays.Ray{}
	ptr.parent = nil

	return ptr
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

set_parent :: proc(s, g: ^Shape) {
	s.parent = g
}

normal_at :: proc(s: ^Shape, p: tuples.Tuple) -> tuples.Tuple {
	obj_p := world_to_object(s, p)
	shape_normal: tuples.Tuple
	switch &t in s.shape {
	case Sphere:
		shape_normal = sphere_normal_at(&t, obj_p)
	case Plane:
		shape_normal = plane_normal_at(&t, obj_p)
	case Cube:
		shape_normal = cube_normal_at(&t, obj_p)
	case Cylinder:
		shape_normal = cylinder_normal_at(&t, obj_p)
	case Cone:
		shape_normal = cone_normal_at(&t, obj_p)
	case Group:
		shape_normal = group_normal_at(&t, obj_p)
	case:
		panic("Unknown shape type.")
	}

	n := normal_to_world(s, shape_normal)
	return n
}

intersect :: proc(s: ^Shape, ray: ^rays.Ray) -> map[^Shape][]f64 {
	// This might be a problem in the future with groups and transforming the ray too many times
	transformed_ray := rays.transform(ray, linalg.inverse(s.transform))
	s.ray = transformed_ray
	switch &t in s.shape {
	case Sphere:
		return sphere_intersect(s, &s.ray)
	case Plane:
		return plane_intersect(s, &s.ray)
	case Cube:
		return cube_intersect(s, &s.ray)
	case Cylinder:
		return cylinder_intersect(s, &s.ray)
	case Cone:
		return cone_intersect(s, &s.ray)
	case Group:
		return group_intersect(s, &s.ray)
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
	case Cylinder:
		return cylinder_equals(&s1.shape.(Cylinder), &s2.shape.(Cylinder))
	case Cone:
		return cone_equals(&s1.shape.(Cone), &s2.shape.(Cone))
	case Group:
		return group_equals(&s1.shape.(Group), &s2.shape.(Group))
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

world_to_object :: proc(s: ^Shape, p: tuples.Tuple) -> tuples.Tuple {
	point := p
	if s.parent != nil {
		point = world_to_object(s.parent, point)
	}

	return linalg.inverse(s.transform) * point
}

normal_to_world :: proc(s: ^Shape, v: tuples.Tuple) -> tuples.Tuple {
	n := linalg.transpose(linalg.inverse(s.transform)) * v 

	n.w = 0
	n = tuples.normalize(n)

	if s.parent != nil {
		n = normal_to_world(s.parent, n) 
	}

	return n
}
