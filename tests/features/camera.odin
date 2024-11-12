package test_features

import "core:testing"
import "core:math"
import "src:features/camera"
import "src:features/canvas"
import "src:features/intersection"
import "src:features/light"
import "src:features/rays"
import "src:features/shape"
import "src:features/tuples"
import "src:features/transforms"
import "src:features/world"
import utils "src:utilities"

@(test)
create_camera :: proc(t: ^testing.T) {
	c := camera.camera(160, 120, math.PI / 2)

	testing.expect(t, c.hsize == 160, "Camera width is incorrect.")
	testing.expect(t, c.vsize == 120, "Camera height is incorrect.")
	testing.expect(t, c.fov == math.PI / 2, "Camera fov is incorrect.")
	testing.expect(t, utils.matrix4_equals_f64(c.transform, utils.matrix4_identity()), "Camera transform is incorrect.")
}

@(test)
horizontal_aspect :: proc(t: ^testing.T) {
	c := camera.camera(200, 125, math.PI / 2)

	testing.expect(t, utils.fp_equals(c.pixel_size, 0.01), "Pixel size for horizontal aspect ration is incorrect.")
}

@(test)
vertical_aspect :: proc(t: ^testing.T) {
	c := camera.camera(125, 200, math.PI / 2)

	testing.expect(t, utils.fp_equals(c.pixel_size, 0.01), "Pixel size for vertical aspect ration is incorrect.")
}

@(test)
camera_center_ray :: proc(t: ^testing.T) {
	c := camera.camera(201, 101, math.PI / 2)
	r := camera.ray_for_pixel(&c, 100, 50)
	
	testing.expect(t, tuples.tuple_equals(r.origin, tuples.point(0, 0, 0)), "Ray through center of the canvas is incorrect.")
	testing.expect(t, tuples.tuple_equals(r.direction, tuples.vector(0, 0, -1)), "Ray through center of the canvas is incorrect.")
}

@(test)
camera_corner_ray :: proc(t: ^testing.T) {
	c := camera.camera(201, 101, math.PI / 2)
	r := camera.ray_for_pixel(&c, 0, 0)
	
	testing.expect(t, tuples.tuple_equals(r.origin, tuples.point(0, 0, 0)), "Ray through corner of the canvas is incorrect.")
	testing.expect(t, tuples.tuple_equals(r.direction, tuples.vector(0.66519, 0.33259, -0.66851)), "Ray through corner of the canvas is incorrect.")
}

@(test)
camera_transformed_ray :: proc(t: ^testing.T) {
	c := camera.camera(201, 101, math.PI / 2)
	transform := transforms.get_rotation_matrix(math.PI / 4, .Y) * transforms.get_translation_matrix(0, -2, 5)
	camera.set_transform(&c, transform)
	r := camera.ray_for_pixel(&c, 100, 50)
	
	testing.expectf(
		t,
		tuples.tuple_equals(r.origin, tuples.point(0, 2, -5)),
		"Ray origin from translated camera is incorrect. Got: %v",
		r.origin)
	testing.expectf(
		t,
		tuples.tuple_equals(r.direction, tuples.vector(math.sqrt_f64(2) / 2, 0, -math.sqrt_f64(2) / 2)),
		"Ray direction from translated camera is incorrect. Got: %v",
		r.direction)
}

@(test)
render_world_with_camera :: proc(t: ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	c := camera.camera(11, 11, math.PI / 2)
	from := tuples.point(0, 0, -5)
	to := tuples.point(0, 0, 0)
	up := tuples.vector(0, 1, 0)
	view := transforms.get_view_transform(from, to, up)
	camera.set_transform(&c, view)
	image := camera.render(&c, &w)
	defer canvas.free_canvas(&image)

	color := canvas.get_pixel(&image, 5, 5)
	testing.expect(t, tuples.color_equals(color, tuples.color(0.38066, 0.47583, 0.2855)), "Rendered pixel is incorrect.")
}
