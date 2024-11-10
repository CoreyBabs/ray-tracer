package test_features

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:testing"
import "src:features/transforms"
import "src:features/tuples"
import utils "src:utilities"

@(test)
translate :: proc(t: ^testing.T) {
	p := tuples.point(-3, 4, 5)
	expected := tuples.point(2, 1, 7)
	result := transforms.translate(p, 5, -3, 2)
	testing.expect(t, result == expected)

	result = transforms.inverse_translate(p, 5, -3, 2)
	expected = tuples.point(-8, 7, 3)
	testing.expect(t, tuples.tuple_equals(expected, result))
}

@(test)
scale :: proc(t: ^testing.T) {
	p := tuples.point(-4, 6, 8)
	expected := tuples.point(-8, 18, 32)
	result := transforms.scale(p, 2, 3, 4)
	testing.expect(t, tuples.tuple_equals(result, expected))

	v := tuples.vector(-4, 6, 8)
	expected = tuples.vector(-8, 18, 32)
	result = transforms.scale(v, 2, 3, 4)
	testing.expect(t, tuples.tuple_equals(result, expected))

	result = transforms.inverse_scale(v, 2, 3, 4)
	expected = tuples.vector(-2, 2, 2)
	testing.expect(t, tuples.tuple_equals(result, expected))
	
	p = tuples.point(2, 3, 4)
	result = transforms.scale(p, -1, 1, 1)
	expected = tuples.point(-2, 3, 4)
	testing.expect(t, tuples.tuple_equals(result, expected))
}

@(test)
rotation_x :: proc(t: ^testing.T) {
	p := tuples.point(0, 1, 0)
	result := transforms.rotate_x(p, math.PI / 4)
	expected := tuples.point(0, math.sqrt_f64(2) / 2, math.sqrt_f64(2) / 2)
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)

	result = transforms.rotate_x(p, math.PI / 2)
	expected = tuples.point(0, 0, 1)
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)

	result = transforms.rotate_x(p, math.PI / 4, true)
	expected = tuples.point(0, math.sqrt_f64(2) / 2, -(math.sqrt_f64(2) / 2))
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)
}


@(test)
rotation_y :: proc(t: ^testing.T) {
	p := tuples.point(0, 0, 1)
	result := transforms.rotate_y(p, math.PI / 4)
	expected := tuples.point(math.sqrt_f64(2) / 2, 0, math.sqrt_f64(2) / 2)
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)

	result = transforms.rotate_y(p, math.PI / 2)
	expected = tuples.point(1, 0, 0)
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)
}

@(test)
rotation_z :: proc(t: ^testing.T) {
	p := tuples.point(0, 1, 0)
	result := transforms.rotate_z(p, math.PI / 4)
	expected := tuples.point(-math.sqrt_f64(2) / 2, math.sqrt_f64(2) / 2, 0)
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)

	result = transforms.rotate_z(p, math.PI / 2)
	expected = tuples.point(-1, 0, 0)
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)
}

@(test)
shear :: proc(t: ^testing.T) {
	p := tuples.point(2, 3, 4)
	result := transforms.shear(p, 1, 0, 0, 0, 0, 0)
	expected := tuples.point(5, 3, 4)
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)

	result = transforms.shear(p, 0, 1, 0, 0, 0, 0)
	expected = tuples.point(6, 3, 4)
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)

	result = transforms.shear(p, 0, 0, 1, 0, 0, 0)
	expected = tuples.point(2, 5, 4)
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)

	result = transforms.shear(p, 0, 0, 0, 1, 0, 0)
	expected = tuples.point(2, 7, 4)
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)

	result = transforms.shear(p, 0, 0, 0, 0, 1, 0)
	expected = tuples.point(2, 3, 6)
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)

	result = transforms.shear(p, 0, 0, 0, 0, 0, 1)
	expected = tuples.point(2, 3, 7)
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)
}

@(test)
chaining_transforms :: proc(t: ^testing.T) {
	p := tuples.point(1, 0, 1)
	result := transforms.rotate_x(p, math.PI / 2)
	expected := tuples.point(1, -1, 0)
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)

	result = transforms.scale(result, 5, 5, 5)
	expected = tuples.point(5, -5, 0)
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)

	result = transforms.translate(result, 10, 5, 7)
	expected = tuples.point(15, 0, 7)
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)
}

@(test)
default_orientation :: proc(t: ^testing.T) {
	from := tuples.point(0, 0, 0)
	to := tuples.point(0, 0, -1)
	up := tuples.vector(0, 1, 0)

	view := transforms.get_view_transform(from, to, up)

	testing.expect(t, utils.matrix4_equals_f64(view, utils.matrix4_identity()), "Default orientation was not the identity matrix.")
}

@(test)
view_positive_z :: proc(t: ^testing.T) {
	from := tuples.point(0, 0, 0)
	to := tuples.point(0, 0, 1)
	up := tuples.vector(0, 1, 0)

	view := transforms.get_view_transform(from, to, up)
	expected := transforms.get_scale_matrix(-1, 1, -1)

	testing.expect(t, utils.matrix4_equals_f64(view, expected), "Positive z view is incorrect.")
}

@(test)
view_moves_world :: proc(t: ^testing.T) {
	from := tuples.point(0, 0, 8)
	to := tuples.point(0, 0, 0)
	up := tuples.vector(0, 1, 0)

	view := transforms.get_view_transform(from, to, up)
	expected := transforms.get_translation_matrix(0, 0, -8)

	testing.expect(t, utils.matrix4_equals_f64(view, expected), "View moves world transform is incorrect.")

}

@(test)
arbitrary_view :: proc(t: ^testing.T) {
	from := tuples.point(1, 3, 2)
	to := tuples.point(4, -2, 8)
	up := tuples.vector(1, 1, 0)

	view := transforms.get_view_transform(from, to, up)
	expected := matrix[4, 4]f64{
		-0.50709, 0.50709, 0.67612, -2.36643,
		0.76772, 0.60609, 0.12122, -2.82843,
		-0.35857, 0.59761, -0.71714, 0,
		0, 0, 0, 1,
	}

	testing.expectf(t, utils.matrix4_equals_f64(view, expected), "Arbitrary view is incorrect. Got: %v", view)

}
