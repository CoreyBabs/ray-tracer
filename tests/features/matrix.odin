package test_features

import "core:fmt"
import "core:math/linalg"
import "core:testing"
import utils "src:utilities"

@(test)
create_matrix :: proc(t: ^testing.T) {
	m := matrix[4, 4]f64{
		1, 2, 3, 4,
		5.5, 6.5, 7.5, 8.5,
		9, 10, 11, 12,
		13.5, 14.5, 15.5, 16.5
	}

	testing.expect(t, m[0, 0] == 1)
	testing.expect(t, m[0, 3] == 4)
	testing.expect(t, m[1, 0] == 5.5)
	testing.expect(t, m[1, 2] == 7.5)
	testing.expect(t, m[2, 2] == 11)
	testing.expect(t, m[3, 0] == 13.5)
	testing.expect(t, m[3, 2] == 15.5)
}

@(test)
create_2x2_matrix :: proc(t: ^testing.T) {
	m := matrix[2, 2]f64{
		-3, 5,
		1, -2
	}

	testing.expect(t, m[0, 0] == -3)
	testing.expect(t, m[0, 1] == 5)
	testing.expect(t, m[1, 0] == 1)
	testing.expect(t, m[1, 1] == -2)
}

@(test)
create_3x3_matrix :: proc(t: ^testing.T) {
	m := matrix[3, 3]f64{
		-3, 5, 0,
		1, -2, -7,
		0, 1, 1
	}

	testing.expect(t, m[0, 0] == -3)
	testing.expect(t, m[1, 1] == -2)
	testing.expect(t, m[2, 2] == 1)
}

@(test)
matrix_eq :: proc(t: ^testing.T) {
	m := matrix[4, 4]f64{
		1, 2, 3, 4,
		5, 6, 7, 8,
		9, 8, 7, 6,
		5, 4, 3, 2
	}

	n := matrix[4, 4]f64{
		1, 2, 3, 4,
		5, 6, 7, 8,
		9, 8, 7, 6,
		5, 4, 3, 2
	}

	testing.expect(t, m == n)
}

@(test)
matrix_neq :: proc(t: ^testing.T) {
	m := matrix[4, 4]f64{
		1, 2, 3, 4,
		5, 6, 7, 8,
		9, 8, 7, 6,
		5, 4, 3, 2
	}

	n := matrix[4, 4]f64{
		2, 3, 4, 5,
		6, 7, 8, 9,
		8, 7, 6, 5,
		4, 3, 2, 1
	}

	testing.expect(t, m != n)
}


@(test)
matrix_multiply :: proc(t: ^testing.T) {
	m := matrix[4, 4]f64{
		1, 2, 3, 4,
		5, 6, 7, 8,
		9, 8, 7, 6,
		5, 4, 3, 2
	}

	n := matrix[4, 4]f64{
		-2, 1, 2, 3,
		3, 2, 1, -1,
		4, 3, 6, 5,
		1, 2, 7, 8
	}

	result := matrix[4, 4]f64{
		20, 22, 50, 48,
		44, 54, 114, 108,
		40, 58, 110, 102,
		16, 26, 46, 42
	}

	testing.expect(t, m * n == result)
}

@(test)
matrix_multiply_by_tuple :: proc(t: ^testing.T) {
	m := matrix[4, 4]f64{
		1, 2, 3, 4,
		2, 4, 4, 2,
		8, 6, 4, 1,
		0, 0, 0, 1
	}

	n := [4]f64{1, 2 , 3, 1}

	result := [4]f64{18, 24, 33, 1}

	testing.expect(t, m * n == result)
}

@(test)
identity_matrix_multiply :: proc(t: ^testing.T) {
	identity := matrix[4, 4]f64{
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1,
	}

	m := matrix[4, 4]f64{
		0, 1, 2, 4,
		1, 2, 4, 8,
		2, 4, 8, 16,
		4, 8, 16, 32
	}

	a := [4]f64{1, 2, 3, 4}

	testing.expect(t, m * identity == m)
	testing.expect(t, identity * a == a)
}

@(test)
matrix_transpose :: proc(t: ^testing.T) {
	m := matrix[4, 4]f64{
		0, 9, 3, 0,
		9, 8, 0, 8,
		1, 8, 5, 3,
		0, 0, 5, 8
	}

	n := matrix[4, 4]f64{
		0, 9, 1, 0,
		9, 8, 8, 0,
		3, 0, 5, 5,
		0, 8, 3, 8
	}

	result := linalg.transpose(m)
	testing.expect(t, result == n)
}

@(test)
identity_transpose :: proc(t: ^testing.T) {
	identity := matrix[4, 4]f64{
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1,
	}

	result := linalg.transpose(identity)
	testing.expect(t, result == identity)
}

@(test)
matrix_determinant :: proc(t: ^testing.T) {
	m := matrix[2, 2]f64{
		1, 5,
		-3, 2,
	}

	result := linalg.determinant(m)
	testing.expect(t, result == 17)
}

@(test)
matrix_minor :: proc(t: ^testing.T) {
	m := matrix[3, 3]f64{
		3, 5, 0,
		2, -1, -7,
		6, -1, 5
	}

	minor := linalg.matrix_minor(m, 1, 0)
	testing.expect(t, minor == 25)
}

@(test)
matrix4_determinant :: proc(t: ^testing.T) {
	m := matrix[4, 4]f64{
		-2, -8, 3, 5,
		-3, 1, 7, 3,
		1, 2, -9, 6,
		-6, 7, 7, -9
	}

	result := linalg.determinant(m)
	testing.expect(t, result == -4071)
}


@(test)
matrix_can_invert :: proc(t: ^testing.T) {
	m := matrix[4, 4]f64{
		6, 4, 4, 4,
		5, 5, 7, 6,
		4, -9, 3, -7,
		9, 1, 7, -6
	}

	n := matrix[4, 4]f64{
		-4, 2, -2, -3,
		9, 6, 2, 6,
		0, -5, 1, -5,
		0, 0, 0, 0
	}

	testing.expect(t, utils.matrix4_can_invert(m))
	testing.expect(t, !utils.matrix4_can_invert(n))
}



@(test)
matrix_inverse :: proc(t: ^testing.T) {
	m := matrix[4, 4]f64{
		-5, 2, 6, -8,
		1, -5, 1, 8,
		7, 7, -6, -7,
		1, -3, 7, 4
	}

	expected_m := matrix[4, 4]f64{
		0.21805, 0.45113, 0.24060, -0.04511,
		-0.80827, -1.45677, -0.44361, 0.52068,
		-0.07895, -0.22368, -0.05263, 0.19737,
		-0.52256, -0.81391, -0.30075, 0.30639,
	}

	n := matrix[4, 4]f64{
		8, -5, 9, 2,
		7, 5, 6, 1,
		-6, 0, 9, 6,
		-3, 0, -9, -4
	}

	expected_n := matrix[4, 4]f64{
		 -0.15385, -0.15385, -0.28205, -0.53846,
		 -0.07692, 0.12308, 0.02564, 0.03077,
		 0.35897, 0.35897, 0.43590, 0.92308,
		 -0.69231, -0.69231, -0.76923, -1.92308,
	}


	c := matrix[4, 4]f64{
		9, 3, 0, 9,
		-5, -2, -6, -3,
		-4, 9, 6, 4,
		-7, 6, 6, 2
	}

	expected_c := matrix[4, 4]f64{
		 -0.04074, -0.07778, 0.14444, -0.22222,
		 -0.07778, 0.03333, 0.36667, -0.33333,
		 -0.02901, -0.14630, -0.10926, 0.12963,
		 0.17778, 0.06667, -0.26667, 0.33333,
	}

	result_m := linalg.inverse(m)
	result_n := linalg.inverse(n)
	result_c := linalg.inverse(c)

	testing.expect(t, utils.matrix4_equals_f64(result_m, expected_m))
	testing.expect(t, utils.matrix4_equals_f64(result_n, expected_n))
	testing.expect(t, utils.matrix4_equals_f64(result_c, expected_c))
}

@(test)
inverse_multiply :: proc(t: ^testing.T) {
	a := matrix[4,4]f64 {
		 3, -9, 7, 3,
		 3, -8, 2, -9,
		 -4, 4, 4, 1,
		 -6, 5, -1, 1,
	}

	b := matrix[4,4]f64 {
		 8, 2, 2, 2,
		 3, -1, 7, 0,
		 7, 0, 5, 4,
		 6, -2, 0, 5,	
	}

	c := a * b
	testing.expect(t, utils.matrix4_equals_f64(a, c * linalg.inverse(b)))
}

