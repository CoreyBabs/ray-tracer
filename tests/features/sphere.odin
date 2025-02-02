package test_features

import "core:testing"
import "core:math"
import "src:features/light"
import "src:features/shape"
import "src:features/transforms"
import "src:features/tuples"
import utils "src:utilities"

@(test)
normal_x :: proc(t: ^testing.T) {
	s := shape.default_shape()
	p := tuples.point(1, 0, 0)
	n := shape.normal_at(&s, p)

	expected_n := tuples.vector(1, 0, 0)

	testing.expect(t, tuples.tuple_equals(n, expected_n), "Normal on sphere with point on X axis is incorrect")
}

@(test)
normal_y :: proc(t: ^testing.T) {
	s := shape.default_shape()
	p := tuples.point(0, 1, 0)
	n := shape.normal_at(&s, p)

	expected_n := tuples.vector(0, 1, 0)

	testing.expect(t, tuples.tuple_equals(n, expected_n), "Normal on sphere with point on Y axis is incorrect")
}

@(test)
normal_z :: proc(t: ^testing.T) {
	s := shape.default_shape()
	p := tuples.point(0, 0, 1)
	n := shape.normal_at(&s, p)

	expected_n := tuples.vector(0, 0, 1)

	testing.expect(t, tuples.tuple_equals(n, expected_n), "Normal on sphere with point on Z axis is incorrect")
}

@(test)
normal_nonaxial :: proc(t: ^testing.T) {
	a := math.sqrt_f64(3) / 3
	s := shape.default_shape()
	p := tuples.point(a, a, a)
	n := shape.normal_at(&s, p)

	expected_n := tuples.vector(a, a, a)

	testing.expect(t, tuples.tuple_equals(n, expected_n), "Normal on sphere with nonaxial point is incorrect")
}

@(test)
normal_normalized :: proc(t: ^testing.T) {
	a := math.sqrt_f64(3) / 3
	s := shape.default_shape()
	p := tuples.point(a, a, a)
	n := shape.normal_at(&s, p)

	expected_n := tuples.normalize(tuples.vector(a, a, a))

	testing.expect(t, tuples.tuple_equals(n, expected_n), "Normal on sphere is not normalized.")
}

@(test)
normal_translated :: proc(t: ^testing.T) {
	s := shape.default_shape()
	transform := transforms.get_translation_matrix(0, 1, 0)
	shape.set_transform(&s, transform)
	p := tuples.point(0, 1.70711, -0.70711)
	n := shape.normal_at(&s, p)

	expected_n := tuples.vector(0, 0.70711, -0.70711)

	testing.expect(t, tuples.tuple_equals(n, expected_n), "Normal on translated sphere is incorrect")
}

@(test)
normal_transformed :: proc(t: ^testing.T) {
	a := math.sqrt_f64(2) / 2
	s := shape.default_shape()
	transform := transforms.get_scale_matrix(1, 0.5, 1) * transforms.get_rotation_matrix(math.PI / 5, .Z)
	shape.set_transform(&s, transform)
	p := tuples.point(0, a, -a)
	n := shape.normal_at(&s, p)

	expected_n := tuples.vector(0, 0.97014, -0.24254)

	testing.expectf(t, tuples.tuple_equals(n, expected_n), "Normal on transformed sphere is incorrect. Got %f, %f, %f, %f", n[0], n[1], n[2], n[3])
}

@(test)
glass_sphere :: proc(t: ^testing.T) {
	s := shape.glass_sphere()
	testing.expect(t, utils.matrix4_equals_f64(s.transform, utils.matrix4_identity()), "Glass sphere default transform is incorrect.")
	testing.expect(t, utils.fp_equals(s.material.transparency, 1.0), "Glass sphere transparency is incorrect.")
	testing.expect(t, utils.fp_equals(s.material.refractive_index, 1.5), "Glass sphere refractive index is incorrect.")
}
