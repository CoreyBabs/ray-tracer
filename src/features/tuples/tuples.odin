package tuples

import "core:math"

Tuple :: [4]f32

EPS :: 0.00001

is_point :: proc(t: Tuple) -> bool {
	return t.w == 1.0
}

is_vector :: proc(t: Tuple) -> bool {
	return t.w == 0.0
}

point :: proc(x, y, z: f32) -> Tuple {
	return [4]f32{x, y, z, 1.0}
}

vector :: proc(x, y, z: f32) -> Tuple {
	return [4]f32{x, y, z, 0.0}
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

scalar_multiply :: proc(a: Tuple, scalar: f32) -> Tuple {
	return a * scalar
}

scalar_divide :: proc(a: Tuple, scalar: f32) -> Tuple {
	return a / scalar
}

magnitude :: proc(a: Tuple) -> f32 {
	vx := a.x * a.x
	vy := a.y * a.y
	vz := a.z * a.z
	vw := a.w * a.w
	sum := vx + vy + vz + vw
	return math.sqrt_f32(sum)
}

normalize :: proc(a: Tuple) -> Tuple {
	mag := magnitude(a)
	return scalar_divide(a, mag)
}

dot :: proc(a, b: Tuple) -> f32 {
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

tuple_equals :: proc(a, b: Tuple) -> bool {
	return fp_equals(a.x, b.x) && fp_equals(a.y, b.y) && fp_equals(a.z, b.z) && fp_equals(a.w, b.w)
}
/*
Book recommends doing this manually, but not sure if this is needed in odin
This should also probably be moved to a utility package or something like that
as it does not really belong with tuples
*/
fp_equals :: proc(a, b: f32) -> bool {
	return math.abs(a - b) < EPS
}
