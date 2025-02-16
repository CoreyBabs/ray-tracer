package utilities

import "core:math"
import "core:math/linalg"

EPS : f64 : 0.00001

fp_equals :: proc(a, b: f64) -> bool {
	return f64(math.abs(a - b)) < EPS
}

fp_zero :: proc(a: f64) -> bool {
	return f64(math.abs(a)) < EPS
}

matrix4_equals_f64 :: proc(a, b: matrix[4,4]f64) -> bool {
	c := a - b
	for e in linalg.matrix_flatten(c) {
		if !fp_zero(e) {
			return false
		}
	}
	return true
}

matrix4_can_invert :: proc(a: matrix[4,4]f64) -> bool {
	return linalg.determinant(a) != 0
}

matrix4_identity :: proc() -> matrix[4,4]f64 {
	identity := matrix[4, 4]f64{
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1,
	}

	return identity
}

free_map :: proc(m: ^map[$T]$N) {
	for k, v in m {
		delete(v)
	}
}
