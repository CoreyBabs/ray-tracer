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

	// v := [3]f32{5, -3, 2}
	// transform := linalg.matrix4_translate_f32(v)
	// inv := linalg.inverse(transform)
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
	expected := tuples.point(0, math.sqrt_f32(2) / 2, math.sqrt_f32(2) / 2)
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)

	result = transforms.rotate_x(p, math.PI / 2)
	expected = tuples.point(0, 0, 1)
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)

	result = transforms.rotate_x(p, math.PI / 4, true)
	expected = tuples.point(0, math.sqrt_f32(2) / 2, -(math.sqrt_f32(2) / 2))
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)
}


@(test)
rotation_y :: proc(t: ^testing.T) {
	p := tuples.point(0, 0, 1)
	result := transforms.rotate_y(p, math.PI / 4)
	expected := tuples.point(math.sqrt_f32(2) / 2, 0, math.sqrt_f32(2) / 2)
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)

	result = transforms.rotate_y(p, math.PI / 2)
	expected = tuples.point(1, 0, 0)
	testing.expectf(t, tuples.tuple_equals(result, expected), "got %v, expected %v", result, expected)
}

@(test)
rotation_z :: proc(t: ^testing.T) {
	p := tuples.point(0, 1, 0)
	result := transforms.rotate_z(p, math.PI / 4)
	expected := tuples.point(-math.sqrt_f32(2) / 2, math.sqrt_f32(2) / 2, 0)
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
