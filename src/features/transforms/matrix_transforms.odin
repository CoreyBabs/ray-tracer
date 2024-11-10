package transforms

import "core:fmt"
import "src:features/tuples"
import "core:math"
import "core:math/linalg"
import utils "src:utilities"

RotationDir :: enum{X, Y, Z}

translate :: proc(p: tuples.Tuple, x, y, z: f64) -> tuples.Tuple {
	transform := get_translation_matrix(x, y, z)
	return transform * p
}

inverse_translate :: proc(p: tuples.Tuple, x, y, z: f64) -> tuples.Tuple {
	inv := get_translation_matrix(x, y, z, true)
	return inv * p
}

scale :: proc(p: tuples.Tuple, x, y, z: f64) -> tuples.Tuple {
	v := [3]f64{x, y, z}
	transform := linalg.matrix4_scale_f64(v)
	return transform * p
}

inverse_scale :: proc(p: tuples.Tuple, x, y, z: f64) -> tuples.Tuple {
	v := [3]f64{x, y, z}
	transform := linalg.matrix4_scale_f64(v)
	inv := linalg.inverse(transform)
	return inv * p
}

rotate_x :: proc(p: tuples.Tuple, angle: f64, inverse := false) -> tuples.Tuple {
	transform := get_rotation_matrix(angle, .X, inverse)
	return transform * p
}

rotate_y :: proc(p: tuples.Tuple, angle: f64, inverse := false) -> tuples.Tuple {
	transform := get_rotation_matrix(angle, .Y, inverse)
	return transform * p
}

rotate_z :: proc(p: tuples.Tuple, angle: f64, inverse := false) -> tuples.Tuple {
	transform := get_rotation_matrix(angle, .Z, inverse)
	return transform * p
}

shear :: proc(p: tuples.Tuple, xy, xz, yx, yz, zx, zy: f64) -> tuples.Tuple {
	transform := get_shear_matrix(xy, xz, yx, yz, zx, zy)
	return transform * p
}

get_translation_matrix :: proc(x, y, z: f64, inverse := false) -> matrix[4,4]f64 {
	v := [3]f64{x, y, z}
	transform := linalg.matrix4_translate_f64(v)
	if (inverse) {
		transform = linalg.inverse(transform)
	}

	return transform
}

get_scale_matrix :: proc(x, y, z: f64, inverse := false) -> matrix[4,4]f64 {
	v := [3]f64{x, y, z}
	transform := linalg.matrix4_scale_f64(v)
	if (inverse) {
		transform = linalg.inverse(transform)
	}

	return transform
}

get_rotation_matrix :: proc(angle: f64, dir: RotationDir, inverse := false) -> matrix[4,4]f64 {
	v := get_rotation_v(dir)
	transform := linalg.matrix4_rotate_f64(angle, v)
	if (inverse) {
		transform = linalg.inverse(transform)
	}

	return transform
}

get_shear_matrix :: proc(xy, xz, yx, yz, zx, zy: f64) -> matrix[4,4]f64 {
	transform := utils.matrix4_identity()
	
	transform[0,1] = xy
	transform[0,2] = xz
	transform[1,0] = yx
	transform[1,2] = yz
	transform[2,0] = zx
	transform[2,1] = zy
	return transform
}

get_view_transform :: proc(from, to, up: tuples.Tuple) -> matrix[4,4]f64 {
	// upn := tuples.normalize(up)
	// return linalg.matrix4_look_at_f64(from.xyz, to.xyz, upn.xyz) * get_translation_matrix(-from.x, -from.y, -from.z)
	f := tuples.normalize(to - from)
	upn := tuples.normalize(up)
	left := tuples.cross(f, upn)
	true_up := tuples.cross(left, f)

	orientation := matrix[4,4]f64{
		left.x, left.y, left.z, 0,
		true_up.x, true_up.y, true_up.z, 0,
		-f.x, -f.y, -f.z, 0,
		0, 0, 0, 1
	}

	return orientation * get_translation_matrix(-from.x, -from.y, -from.z)
}

@(private)
get_rotation_v :: proc(dir: RotationDir) -> [3]f64 {
	v: [3]f64
	switch dir {
		case .X:
			v = [3]f64{1, 0, 0}
		case .Y:
			v = [3]f64{0, 1, 0}
		case .Z:
			v = [3]f64{0, 0, 1}
	}

	return v
}
