package side_projects

import "core:math"
import "core:os"
import "src:features/camera"
import "src:features/tuples"
import "src:features/canvas"
import "src:features/intersection"
import "src:features/light"
import "src:features/transforms"
import "src:features/shape"
import "src:features/rays"
import "src:features/world"

circle :: proc() {
	s := shape.default_shape()
	m := light.material(0.5, 0.9, 0.1)
	light.set_material_color(&m, tuples.color(0.5, 0.2, 1))
	shape.set_material(&s, m)

	light_position := tuples.point(-10, 10, -10)
	light_color := tuples.color(1, 1, 1)
	l := light.point_light(light_position, light_color)

	cam := camera.camera(500, 500, math.PI / 3)
	view := transforms.get_view_transform(tuples.point(0, 1.5, -5), tuples.point(0, 1, 0), tuples.vector(0, 1, 0))
	camera.set_transform(&cam, view)

	w := world.empty_world()
	defer world.delete_world(&w)

	world.set_light(&w, l)
	world.add_object(&w, floor())
	// world.add_object(&w, left_wall())
	// world.add_object(&w, right_wall())
	world.add_object(&w, middle())
	world.add_object(&w, right())
	world.add_object(&w, left())

	image := camera.render(&cam, &w)
	defer canvas.free_canvas(&image)

	ppm := canvas.to_ppm(&image)
	result := os.write_entire_file("./images/circle.ppm", transmute([]u8)ppm)
}

floor :: proc() -> shape.Shape {
	floor := shape.default_shape()
	plane := shape.plane()
	shape.set_shape(&floor, plane)
	// transform := transforms.get_scale_matrix(10, 0.01, 10)
	mat := light.material(spec=0)
	light.set_material_color(&mat, tuples.color(1, 0.9, 0.9))

	// shape.set_transform(&floor, transform)
	shape.set_material(&floor, mat)

	return floor
}

left_wall :: proc() -> shape.Shape {
	wall := shape.default_shape()
	transform := transforms.get_translation_matrix(0, 0, 5) * 
		transforms.get_rotation_matrix(-math.PI / 4, .Y) * transforms.get_rotation_matrix(math.PI / 2, .X) *
		transforms.get_scale_matrix(10, 0.01, 10)
	mat := light.material(spec=0)
	light.set_material_color(&mat, tuples.color(1, 0.9, 0.9))

	shape.set_transform(&wall, transform)
	shape.set_material(&wall, mat)

	return wall
}

right_wall :: proc() -> shape.Shape {
	wall := shape.default_shape()
	transform := transforms.get_translation_matrix(0, 0, 5) * 
		transforms.get_rotation_matrix(math.PI / 4, .Y) * transforms.get_rotation_matrix(math.PI / 2, .X) *
		transforms.get_scale_matrix(10, 0.01, 10)
	mat := light.material(spec=0)
	light.set_material_color(&mat, tuples.color(1, 0.9, 0.9))

	shape.set_transform(&wall, transform)
	shape.set_material(&wall, mat)

	return wall
}

middle :: proc() -> shape.Shape {
	mid := shape.default_shape()
	transform := transforms.get_translation_matrix(-0.5, 1, 0.5)

	mat := light.material(d=0.7, spec=0.3)
	light.set_material_color(&mat, tuples.color(0.1, 1, 0.5))

	shape.set_transform(&mid, transform)
	shape.set_material(&mid, mat)

	return mid
}

right :: proc() -> shape.Shape {
	right := shape.default_shape()
	transform := transforms.get_translation_matrix(1.5, 0.5, -0.5) * transforms.get_scale_matrix(0.5, 0.5, 0.5)

	mat := light.material(d=0.7, spec=0.3)
	light.set_material_color(&mat, tuples.color(0.5, 1, 0.1))

	shape.set_transform(&right, transform)
	shape.set_material(&right, mat)

	return right
}

left :: proc() -> shape.Shape {
	left := shape.default_shape()
	transform := transforms.get_translation_matrix(-1.5, 0.33, -0.75) * transforms.get_scale_matrix(0.33, 0.33, 0.33)

	mat := light.material(d=0.7, spec=0.3)
	light.set_material_color(&mat, tuples.color(1, 0.8, 0.1))

	shape.set_transform(&left, transform)
	shape.set_material(&left, mat)

	return left
}
