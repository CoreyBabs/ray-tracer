package side_projects

import "core:math"
import "core:os"
import "src:features/camera"
import "src:features/tuples"
import "src:features/canvas"
import "src:features/intersection"
import "src:features/light"
import "src:features/patterns"
import "src:features/transforms"
import "src:features/shape"
import "src:features/rays"
import "src:features/world"

hexagon_scene :: proc() {
	s := hexagon()
	defer free_group_list(&s)
	defer delete(s)

	light_position := tuples.point(2, 10, -5)
	light_color := tuples.white()
	l := light.point_light(light_position, light_color)

	cam := camera.camera(500, 500, 0.45)
	view := transforms.get_view_transform(tuples.point(0, 3.0, -5), tuples.point(0, 0, 0), tuples.vector(0, 1, 0))
	camera.set_transform(&cam, view)

	w := world.empty_world()
	defer world.delete_world(&w)

	world.set_light(&w, l)
	for &o in s {
		world.add_object(&w, o^)
	}

	image := camera.render(&cam, &w)
	defer canvas.free_canvas(&image)

	ppm := canvas.to_ppm(&image)
	result := os.write_entire_file("./images/hexagon.ppm", transmute([]u8)ppm)
}

@(private)
hexagon_corner :: proc() -> ^shape.Shape {
	corner := shape.new_shape()
	shape.set_transform(corner, transforms.get_translation_matrix(0, 0, -1) * transforms.get_scale_matrix(0.25, 0.25, 0.25))
	return corner
}

@(private)
hexagon_edge :: proc() -> ^shape.Shape {
	cyl := shape.cylinder(0, 1)

	edge := shape.new_shape()
	shape.set_shape(edge, cyl)

	transform := transforms.get_translation_matrix(0, 0, -1) *
		transforms.get_rotation_matrix(-math.PI/6, .Y) *
		transforms.get_rotation_matrix(-math.PI/2, .Z) *
		transforms.get_scale_matrix(0.25, 1, 0.25)

	shape.set_transform(edge, transform)
	return edge
}

@(private)
hexagon_side :: proc() -> ^shape.Shape {
	g := shape.group()
	side := shape.new_shape()
	shape.set_shape(side, g)
	c := hexagon_corner()
	e := hexagon_edge()

	shape.add_shape_to_group(side, c)
	shape.add_shape_to_group(side, e)
	
	return side
}

@(private)
hexagon :: proc() -> [dynamic]^shape.Shape {
	hex := make([dynamic]^shape.Shape, 6, context.allocator)
	for n in 0..<6 {
		side := hexagon_side()
		shape.set_transform(side, transforms.get_rotation_matrix(cast(f64)n * math.PI/3, .Y))
		hex[n] = side
	}

	return hex
}
