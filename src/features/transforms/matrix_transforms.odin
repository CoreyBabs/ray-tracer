package transforms

import "core:fmt"
import "src:features/tuples"
import "core:math"
import "core:math/linalg"
import utils "src:utilities"

RotationDir :: enum{X, Y, Z}

translate :: proc(p: tuples.Tuple, x, y, z: f32) -> tuples.Tuple {
	transform := get_translation_matrix(x, y, z)
	return transform * p
}

inverse_translate :: proc(p: tuples.Tuple, x, y, z: f32) -> tuples.Tuple {
	inv := get_translation_matrix(x, y, z, true)
	return inv * p
}

scale :: proc(p: tuples.Tuple, x, y, z: f32) -> tuples.Tuple {
	v := [3]f32{x, y, z}
	transform := linalg.matrix4_scale_f32(v)
	return transform * p
}

inverse_scale :: proc(p: tuples.Tuple, x, y, z: f32) -> tuples.Tuple {
	v := [3]f32{x, y, z}
	transform := linalg.matrix4_scale_f32(v)
	inv := linalg.inverse(transform)
	return inv * p
}

rotate_x :: proc(p: tuples.Tuple, angle: f32, inverse := false) -> tuples.Tuple {
	transform := get_rotation_matrix(angle, .X, inverse)
	return transform * p
}

rotate_y :: proc(p: tuples.Tuple, angle: f32, inverse := false) -> tuples.Tuple {
	transform := get_rotation_matrix(angle, .Y, inverse)
	return transform * p
}

rotate_z :: proc(p: tuples.Tuple, angle: f32, inverse := false) -> tuples.Tuple {
	transform := get_rotation_matrix(angle, .Z, inverse)
	return transform * p
}

shear :: proc(p: tuples.Tuple, xy, xz, yx, yz, zx, zy: f32) -> tuples.Tuple {
	transform := get_shear_matrix(xy, xz, yx, yz, zx, zy)
	return transform * p
}

get_translation_matrix :: proc(x, y, z: f32, inverse := false) -> matrix[4,4]f32 {
	v := [3]f32{x, y, z}
	transform := linalg.matrix4_translate_f32(v)
	if (inverse) {
		transform = linalg.inverse(transform)
	}

	return transform
}

get_scale_matrix :: proc(x, y, z: f32, inverse := false) -> matrix[4,4]f32 {
	v := [3]f32{x, y, z}
	transform := linalg.matrix4_scale_f32(v)
	if (inverse) {
		transform = linalg.inverse(transform)
	}

	return transform
}

get_rotation_matrix :: proc(angle: f32, dir: RotationDir, inverse := false) -> matrix[4,4]f32 {
	v := get_rotation_v(dir)
	transform := linalg.matrix4_rotate_f32(angle, v)
	if (inverse) {
		transform = linalg.inverse(transform)
	}

	return transform
}

get_shear_matrix :: proc(xy, xz, yx, yz, zx, zy: f32) -> matrix[4,4]f32 {
	transform := utils.matrix4_identity()
	
	transform[0,1] = xy
	transform[0,2] = xz
	transform[1,0] = yx
	transform[1,2] = yz
	transform[2,0] = zx
	transform[2,1] = zy
	return transform
}

@(private)
get_rotation_v :: proc(dir: RotationDir) -> [3]f32 {
	v: [3]f32
	switch dir {
		case .X:
			v = [3]f32{1, 0, 0}
		case .Y:
			v = [3]f32{0, 1, 0}
		case .Z:
			v = [3]f32{0, 0, 1}
	}

	return v
}
