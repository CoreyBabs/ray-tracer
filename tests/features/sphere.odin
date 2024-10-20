package test_features

import "core:testing"
import "core:math"
import "src:features/light"
import "src:features/sphere"
import "src:features/transforms"
import "src:features/tuples"
import utils "src:utilities"

@(test)
sphere_default_transform :: proc(t: ^testing.T) {
	s := sphere.sphere()
	testing.expect(t, utils.matrix4_equals_f32(s.transform, utils.matrix4_identity()), "Default Sphere transform is incorrect.")
}

@(test)
sphere_change_transform :: proc(t: ^testing.T) {
	s := sphere.sphere()
	translate := transforms.get_translation_matrix(2, 3, 4)
	sphere.set_transform(&s, translate)

	testing.expect(t, utils.matrix4_equals_f32(s.transform, translate), "Sphere transform is incorrect.")
}

@(test)
normal_x :: proc(t: ^testing.T) {
	s := sphere.sphere()
	p := tuples.point(1, 0, 0)
	n := sphere.normal_at(&s, p)

	expected_n := tuples.vector(1, 0, 0)

	testing.expect(t, tuples.tuple_equals(n, expected_n), "Normal on sphere with point on X axis is incorrect")
}

@(test)
normal_y :: proc(t: ^testing.T) {
	s := sphere.sphere()
	p := tuples.point(0, 1, 0)
	n := sphere.normal_at(&s, p)

	expected_n := tuples.vector(0, 1, 0)

	testing.expect(t, tuples.tuple_equals(n, expected_n), "Normal on sphere with point on Y axis is incorrect")
}

@(test)
normal_z :: proc(t: ^testing.T) {
	s := sphere.sphere()
	p := tuples.point(0, 0, 1)
	n := sphere.normal_at(&s, p)

	expected_n := tuples.vector(0, 0, 1)

	testing.expect(t, tuples.tuple_equals(n, expected_n), "Normal on sphere with point on Z axis is incorrect")
}

@(test)
normal_nonaxial :: proc(t: ^testing.T) {
	a := math.sqrt_f32(3) / 3
	s := sphere.sphere()
	p := tuples.point(a, a, a)
	n := sphere.normal_at(&s, p)

	expected_n := tuples.vector(a, a, a)

	testing.expect(t, tuples.tuple_equals(n, expected_n), "Normal on sphere with nonaxial point is incorrect")
}

@(test)
normal_normalized :: proc(t: ^testing.T) {
	a := math.sqrt_f32(3) / 3
	s := sphere.sphere()
	p := tuples.point(a, a, a)
	n := sphere.normal_at(&s, p)

	expected_n := tuples.normalize(tuples.vector(a, a, a))

	testing.expect(t, tuples.tuple_equals(n, expected_n), "Normal on sphere is not normalized.")
}

@(test)
normal_translated :: proc(t: ^testing.T) {
	s := sphere.sphere()
	transform := transforms.get_translation_matrix(0, 1, 0)
	sphere.set_transform(&s, transform)
	p := tuples.point(0, 1.70711, -0.70711)
	n := sphere.normal_at(&s, p)

	expected_n := tuples.vector(0, 0.70711, -0.70711)

	testing.expect(t, tuples.tuple_equals(n, expected_n), "Normal on translated sphere is incorrect")
}

@(test)
normal_transformed :: proc(t: ^testing.T) {
	a := math.sqrt_f32(2) / 2
	s := sphere.sphere()
	transform := transforms.get_scale_matrix(1, 0.5, 1) * transforms.get_rotation_matrix(math.PI / 5, .Z)
	sphere.set_transform(&s, transform)
	p := tuples.point(0, a, -a)
	n := sphere.normal_at(&s, p)

	expected_n := tuples.vector(0, 0.97014, -0.24254)

	testing.expectf(t, tuples.tuple_equals(n, expected_n), "Normal on transformed sphere is incorrect. Got %f, %f, %f, %f", n[0], n[1], n[2], n[3])
}

@(test)
sphere_default_material :: proc(t: ^testing.T) {
	s := sphere.sphere()

	testing.expect(t, light.material_equals(s.material, light.material()), "Sphere default material is incorrect.")
}

@(test)
sphere_material :: proc(t: ^testing.T) {
	s := sphere.sphere()
	m := light.material(1.0)
	sphere.set_material(&s, m)

	testing.expect(t, light.material_equals(s.material, m), "Sphere material is incorrect.")
	testing.expect(t, utils.fp_equals(s.material.ambient, 1.0), "Sphere material is incorrect.")
}
