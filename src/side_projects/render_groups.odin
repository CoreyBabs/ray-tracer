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

group_scene :: proc() {
	s := build_group()
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
	result := os.write_entire_file("./images/groups.ppm", transmute([]u8)ppm)
}

@(private)
vertical_group :: proc() -> ^shape.Shape {
	b := shape.new_shape()
	g := shape.group()
	shape.set_shape(b, g)

	for n in 0..<5 {
		side := shape.new_shape()
		shape.set_transform(side, transforms.get_translation_matrix(0, cast(f64)n * 0.5, 0))
		shape.add_shape_to_group(b, side)
	}

	return b
}

@(private)
horizontal_group :: proc() -> ^shape.Shape {
	b := shape.new_shape()
	g := shape.group()
	shape.set_shape(b, g)

	for n in 0..<5 {
		side := shape.new_shape()
		shape.set_transform(side, transforms.get_translation_matrix(cast(f64)n * 0.5, 0, 0))
		shape.add_shape_to_group(b, side)
	}

	return b

}

@(private)
build_group :: proc() -> [dynamic]^shape.Shape {
	b := shape.new_shape()
	g := shape.group()
	shape.set_shape(b, g)

	v := vertical_group()
	h := horizontal_group()

	lb := make([dynamic]^shape.Shape, 2, context.allocator)
	lb[0] = v
	lb[1] = h

	return lb
}

@(private)
free_group_list :: proc(list: ^[dynamic]^shape.Shape) {
	for l in list {
		shape.free_group(&l.shape.(shape.Group))
	}
}


