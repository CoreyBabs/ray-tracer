package side_projects

import "core:math"
import "core:os"
import "src:features/camera"
import "src:features/tuples"
import "src:features/canvas"
import "src:features/intersection"
import "src:features/light"
import "src:features/parser"
import "src:features/patterns"
import "src:features/transforms"
import "src:features/shape"
import "src:features/rays"
import "src:features/world"

teapot_scene :: proc() {
	path := "./object_files/teapot.obj"

	p := parser.parse_obj_file(path)
	defer parser.free_parser(&p)

	groups := parser.parser_to_groups(&p)
	delete(groups)

	light_position := tuples.point(2, 10, -5)
	light_color := tuples.white()
	l := light.point_light(light_position, light_color)

	cam := camera.camera(500, 500, 1.0)
	view := transforms.get_view_transform(tuples.point(0, 3.0, -10), tuples.point(0, 0, 0), tuples.vector(0, 1, 0))
	camera.set_transform(&cam, view)

	w := world.empty_world()
	defer world.delete_world(&w)

	world.set_light(&w, l)
	for &g in groups {
		world.add_object(&w, g^)
	}

	image := camera.render(&cam, &w)
	defer canvas.free_canvas(&image)

	ppm := canvas.to_ppm(&image)
	result := os.write_entire_file("./images/teapot.ppm", transmute([]u8)ppm)
}

