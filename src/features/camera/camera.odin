package camera

import "core:math"
import "core:math/linalg"
import "src:features/canvas"
import "src:features/rays"
import "src:features/tuples"
import "src:features/world"
import utils "src:utilities"

Camera :: struct {
	hsize: int,
	vsize: int,
	fov: f32,
	half_width: f32,
	half_height: f32,
	pixel_size: f32,
	transform: matrix[4,4]f32
}

camera :: proc(hsize, vsize: int, fov: f32) -> Camera {
	half_view := math.tan_f32(fov / 2)
	aspect: f32 = f32(hsize) / f32(vsize)

	half_width: f32 = 0
	half_height: f32 = 0
	if aspect >= 1 {
		half_width = half_view
		half_height = half_view / f32(aspect)
	}
	else {
		half_height = half_view
		half_width = half_view * f32(aspect)
	}

	pixel_size := (half_width * 2) / f32(hsize)

	return Camera{hsize, vsize, fov, half_width, half_height, pixel_size, utils.matrix4_identity()}
}

set_transform :: proc(c: ^Camera, t: matrix[4,4]f32) {
	c.transform = t
}

ray_for_pixel :: proc(c: ^Camera, x, y: int) -> rays.Ray {
	xoffset := (f32(x) + 0.5) * c.pixel_size
	yoffset := (f32(y) + 0.5) * c.pixel_size

	world_x := c.half_width - xoffset
	world_y := c.half_height - yoffset

	pixel := linalg.inverse(c.transform) * tuples.point(world_x, world_y, -1)
	origin := linalg.inverse(c.transform) * tuples.point(0, 0, 0)
	direction := tuples.normalize(pixel - origin)

	return rays.create_ray(origin, direction)
}

render :: proc(c: ^Camera, w: ^world.World) -> canvas.Canvas {
	image := canvas.canvas(c.hsize, c.vsize)

	for y := 0; y < c.vsize - 1; y += 1 {
		for x := 0; x < c.hsize - 1; x += 1 {
			ray := ray_for_pixel(c, x, y)
			color := world.color_at(w, &ray)
			canvas.write_pixel(&image, x, y, color)
		}
	}

	return image
}
