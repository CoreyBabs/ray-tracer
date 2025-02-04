package tuples

import "core:math"
import utils "src:utilities"

Tuple :: [4]f64

is_point :: proc(t: Tuple) -> bool {
	return t.w == 1.0
}

is_vector :: proc(t: Tuple) -> bool {
	return t.w == 0.0
}

point :: proc(x, y, z: f64) -> Tuple {
	return [4]f64{x, y, z, 1.0}
}

vector :: proc(x, y, z: f64) -> Tuple {
	return [4]f64{x, y, z, 0.0}
}

add_tuples :: proc(a, b: Tuple) -> Tuple {
	return a + b
}

subtract_tuples :: proc(a, b: Tuple) -> Tuple {
	return a - b
}

negate_tuple :: proc(a: Tuple) -> Tuple {
	zero := vector(0, 0, 0)
	return subtract_tuples(zero, a)
}

scalar_multiply :: proc(a: Tuple, scalar: f64) -> Tuple {
	return a * scalar
}

scalar_divide :: proc(a: Tuple, scalar: f64) -> Tuple {
	if utils.fp_zero(scalar) {
		return 0
	}

	return a / scalar
}

magnitude :: proc(a: Tuple) -> f64 {
	vx := a.x * a.x
	vy := a.y * a.y
	vz := a.z * a.z
	vw := a.w * a.w
	sum := vx + vy + vz + vw
	return math.sqrt_f64(sum)
}

normalize :: proc(a: Tuple) -> Tuple {
	mag := magnitude(a)
	return scalar_divide(a, mag)
}

dot :: proc(a, b: Tuple) -> f64 {
	return a.x * b.x +
	a.y * b.y +
	a.z * b.z +
	a.w * b.w
}

cross :: proc(a, b: Tuple) -> Tuple {
	x := a.y * b.z - a.z * b.y
	y := a.z * b.x - a.x * b.z
	z := a.x * b.y - a.y * b.x
	return vector(x, y, z)
}

reflect :: proc(v, n: Tuple) -> Tuple {
	return v - n * 2 * dot(v, n)
}

tuple_equals :: proc(a, b: Tuple) -> bool {
	return utils.fp_equals(a.x, b.x) && utils.fp_equals(a.y, b.y) && utils.fp_equals(a.z, b.z) && utils.fp_equals(a.w, b.w)
}
