package test_features

import "core:math"
import "core:testing"
import "src:features/light"
import "src:features/shape"
import "src:features/tuples"
import "src:features/transforms"
import utils "src:utilities"

@(test)
shape_default_transform :: proc(t: ^testing.T) {
	s := shape.default_shape()
	testing.expect(t, utils.matrix4_equals_f64(s.transform, utils.matrix4_identity()), "Default shape transform is incorrect.")
}

@(test)
shape_change_transform :: proc(t: ^testing.T) {
	s := shape.default_shape()
	translate := transforms.get_translation_matrix(2, 3, 4)
	shape.set_transform(&s, translate)

	testing.expect(t, utils.matrix4_equals_f64(s.transform, translate), "shape transform is incorrect.")
}

@(test)
shape_default_material :: proc(t: ^testing.T) {
	s := shape.default_shape()
	m := light.material()

	testing.expect(t, light.material_equals(&s.material, &m), "shape default material is incorrect.")
}

@(test)
shape_material :: proc(t: ^testing.T) {
	s := shape.default_shape()
	m := light.material(1.0)
	shape.set_material(&s, m)

	testing.expect(t, light.material_equals(&s.material, &m), "shape material is incorrect.")
	testing.expect(t, utils.fp_equals(s.material.ambient, 1.0), "shape material is incorrect.")
}

@(test)
shape_normal_translated :: proc(t: ^testing.T) {
	s := shape.default_shape()
	transform := transforms.get_translation_matrix(0, 1, 0)
	shape.set_transform(&s, transform)
	p := tuples.point(0, 1.70711, -0.70711)
	n := shape.normal_at(&s, p)

	expected_n := tuples.vector(0, 0.70711, -0.70711)

	testing.expect(t, tuples.tuple_equals(n, expected_n), "Normal on translated shape is incorrect")
}

@(test)
shape_normal_transformed :: proc(t: ^testing.T) {
	a := math.sqrt_f64(2) / 2
	s := shape.default_shape()
	transform := transforms.get_scale_matrix(1, 0.5, 1) * transforms.get_rotation_matrix(math.PI / 5, .Z)
	shape.set_transform(&s, transform)
	p := tuples.point(0, a, -a)
	n := shape.normal_at(&s, p)

	expected_n := tuples.vector(0, 0.97014, -0.24254)

	testing.expectf(t, tuples.tuple_equals(n, expected_n), "Normal on transformed shape is incorrect. Got %f, %f, %f, %f", n[0], n[1], n[2], n[3])
}

