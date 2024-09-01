package test_features

import "core:math"
import "core:testing"
import "src:features"

@(test)
is_point :: proc(t: ^testing.T) {
	tuple := [4]f32{4.3, -4.2, 3.1, 1.0}
	testing.expect(t, features.is_point(tuple), "tuple is not a point")
	testing.expect(t, !features.is_vector(tuple), "tuple is a vector")
}

@(test)
is_vector :: proc(t: ^testing.T) {
	tuple := [4]f32{4.3, -4.2, 3.1, 0.0} 
	testing.expect(t, features.is_vector(tuple), "tuple is not a vector")
	testing.expect(t, !features.is_point(tuple), "tuple is a point")
}

@(test)
create_point :: proc(t: ^testing.T) {
	tuple := features.point(4, -4, 3)
	result := tuple == [4]f32{4, -4, 3, 1} 
	testing.expect(t, result, "created point does not match expected value.")
}

@(test)
create_vector :: proc(t: ^testing.T) {
	tuple := features.vector(4, -4, 3)
	result := tuple == [4]f32{4, -4, 3, 0} 
	testing.expect(t, result, "created vector does not match expected value.")
}

@(test)
floating_point_comparison :: proc(t: ^testing.T) {
	testing.expect(t, features.fp_equals(1.2345, 1.2345), "floats are considered not equal")
	testing.expect(t, features.fp_equals(1.000001, 1.0), "close floats are considered not equal")
	testing.expect(t, !features.fp_equals(1.1, 1.0), "far floats are equal")
}

@(test)
add_vector_and_point :: proc(t: ^testing.T) {
	vector := features.vector(3, -2, 5)
	point := features.point(-2, 3, 1)
	result := features.add_tuples(vector, point)
	testing.expect(t, result == [4]f32{1, 1, 6, 1}, "addition was not correct")
}

@(test)
subtract_point_and_point :: proc(t: ^testing.T) {
	p1 := features.point(3, 2, 1)
	p2 := features.point(5, 6, 7)
	result := features.subtract_tuples(p1, p2)
	testing.expect(t, result == [4]f32{-2, -4, -6, 0}, "subtraction was not correct")
}

@(test)
subtract_vector_and_point :: proc(t: ^testing.T) {
	p1 := features.point(3, 2, 1)
	v1 := features.vector(5, 6, 7)
	result := features.subtract_tuples(p1, v1)
	testing.expect(t, result == [4]f32{-2, -4, -6, 1}, "subtraction was not correct")
}

@(test)
subtract_vector_and_vector :: proc(t: ^testing.T) {
	v1 := features.vector(3, 2, 1)
	v2 := features.vector(5, 6, 7)
	result := features.subtract_tuples(v1, v2)
	testing.expect(t, result == [4]f32{-2, -4, -6, 0}, "subtraction was not correct")
}

@(test)
negate_vector :: proc(t: ^testing.T) {
	v1 := features.vector(1, -2, 3)
	v2 := [4]f32{1, -2, 3, -4}
	nv1 := [4]f32{-1, 2, -3, 0}
	nv2 := [4]f32{-1, 2, -3, 4}
	testing.expect(t, features.negate_tuple(v1) == nv1, "negated tuple was not correct")
	testing.expect(t, features.negate_tuple(v2) == nv2, "negated tuple was not correct")
}

@(test)
multiply_vector_by_scalar :: proc(t: ^testing.T) {
	v1 := [4]f32{1, -2, 3, -4}
	expected := [4]f32{3.5, -7, 10.5, -14}
	testing.expect(t, features.scalar_multiply(v1, 3.5) == expected, "Scalar multiply failed")

	v2 := [4]f32{1, -2, 3, -4}
	expected = [4]f32{0.5, -1, 1.5, -2}
	testing.expect(t, features.scalar_multiply(v2, 0.5) == expected, "Scalar multiply failed")
}

@(test)
divide_vector_by_scalar :: proc(t: ^testing.T) {
	v2 := [4]f32{1, -2, 3, -4}
	expected := [4]f32{0.5, -1, 1.5, -2}
	testing.expect(t, features.scalar_divide(v2, 2) == expected, "Scalar division failed")
}

@(test)
magnitude_of_vector :: proc(t: ^testing.T) {
	v1 := features.vector(1, 0, 0)
	expected : f32 = 1
	testing.expect(t, features.magnitude(v1) == expected, "magnitude of 1 failed")

	v1 = features.vector(0, 1, 0)
	expected = 1
	testing.expect(t, features.magnitude(v1) == expected, "magnitude of 1 failed")

	v1 = features.vector(0, 0, 1)
	expected = 1
	testing.expect(t, features.magnitude(v1) == expected, "magnitude of 1 failed")

	v1 = features.vector(1, 2, 3)
	expected = math.sqrt_f32(14)
	mag := features.magnitude(v1)
	testing.expectf(t, mag == expected, "magniutude of sqrt of 14 failed. Expected %f, got %f", expected, mag)

	v1 = features.vector(-1, -2, -3)
	expected = math.sqrt_f32(14)
	mag = features.magnitude(v1)
	testing.expectf(t, mag == expected, "magniutude of sqrt of 14 failed. Expected %f, got %f", expected, mag)
}

@(test)
normalize_vector :: proc(t: ^testing.T) {
	v1 := features.vector(4, 0, 0)
	expected := features.vector(1, 0, 0)
	norm := features.normalize(v1)
	testing.expect(t, norm == expected, "norm failed")

	v1 = features.vector(1, 2, 3)
	expected = features.vector(1 / math.sqrt_f32(14), 2 / math.sqrt_f32(14), 3 / math.sqrt_f32(14))
	norm = features.normalize(v1)
	mag := features.magnitude(norm)
	em : f32 = 1
	testing.expect(t, norm == expected, "norm failed")
	testing.expectf(t, features.fp_equals(em, mag), "norm magnitude failed, expected %f, got %f", em, mag)

}

@(test)
dot_product :: proc(t: ^testing.T) {
	v1 := features.vector(1, 2, 3)
	v2 := features.vector(2, 3, 4)
	result := features.dot(v1, v2)
	expected : f32 = 20
	testing.expect(t, result == expected)
}

@(test)
cross_product :: proc(t: ^testing.T) {
	v1 := features.vector(1, 2, 3)
	v2 := features.vector(2, 3, 4)
	result := features.cross(v1, v2)
	reverse := features.cross(v2, v1)
	expected := features.vector(-1, 2, -1)
	reverse_expected := features.vector(1, -2, 1)
	testing.expect(t, features.tuple_equals(result, expected))
	testing.expect(t, features.tuple_equals(reverse, reverse_expected))
}
