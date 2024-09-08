package transforms

import "core:fmt"
import "src:features/tuples"
import "core:math"
import "core:math/linalg"
import utils "src:utilities"

translate :: proc(p: tuples.Tuple, x, y, z: f32) -> tuples.Tuple {
	v := [3]f32{x, y, z}
	transform := linalg.matrix4_translate_f32(v)
	return transform * p
}

inverse_translate :: proc(p: tuples.Tuple, x, y, z: f32) -> tuples.Tuple {
	v := [3]f32{x, y, z}
	transform := linalg.matrix4_translate_f32(v)
	inv := linalg.inverse(transform)
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
	v := [3]f32{1, 0, 0}
	transform := linalg.matrix4_rotate_f32(angle, v)

	if inverse {
		transform = linalg.inverse(transform)
	}

	return transform * p
}

rotate_y :: proc(p: tuples.Tuple, angle: f32, inverse := false) -> tuples.Tuple {
	v := [3]f32{0, 1, 0}
	transform := linalg.matrix4_rotate_f32(angle, v)

	if inverse {
		transform = linalg.inverse(transform)
	}

	return transform * p
}

rotate_z :: proc(p: tuples.Tuple, angle: f32, inverse := false) -> tuples.Tuple {
	v := [3]f32{0, 0, 1}
	transform := linalg.matrix4_rotate_f32(angle, v)

	if inverse {
		transform = linalg.inverse(transform)
	}

	return transform * p
}

shear :: proc(p: tuples.Tuple, xy, xz, yx, yz, zx, zy: f32) -> tuples.Tuple {
	transform := utils.matrix4_identity()
	
	transform[0,1] = xy
	transform[0,2] = xz
	transform[1,0] = yx
	transform[1,2] = yz
	transform[2,0] = zx
	transform[2,1] = zy

	return transform * p
}
