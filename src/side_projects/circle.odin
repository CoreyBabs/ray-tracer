package side_projects

import "core:math"
import "core:os"
import "src:features/tuples"
import "src:features/canvas"
import "src:features/intersection"
import "src:features/light"
import "src:features/transforms"
import "src:features/sphere"
import "src:features/rays"

circle :: proc() {
	canvas_pixels := 100
	c := canvas.canvas(canvas_pixels, canvas_pixels)
	defer canvas.free_canvas(&c)

	s := sphere.sphere()
	m := light.material(0.5, 0.9, 0.1)
	light.set_material_color(&m, tuples.color(0.5, 0.2, 1))
	sphere.set_material(&s, m)

	light_position := tuples.point(5, 10, -10)
	light_color := tuples.color(1, 1, 1)
	l := light.point_light(light_position, light_color)
	// transform := transforms.get_shear_matrix(1, 0, 0, 0, 0, 1) * transforms.get_scale_matrix(0.5, 1, 1)
	// transform := transforms.get_scale_matrix(0.5, 1, 1)
	// sphere.set_transform(&s, transform)


	origin := tuples.point(0, 0, -5)
	wall_z: f32 = 10
	wall_size: f32 = 7.0
	pixel_size: f32 = wall_size / 100
	half := wall_size / 2

	for y := 0; y < canvas_pixels; y += 1 {
		world_y := half - pixel_size * f32(y)
		for x := 0; x < canvas_pixels; x += 1 {
			world_x := -half + pixel_size * f32(x)
			position := tuples.point(world_x, world_y, wall_z)

			r := rays.create_ray(origin, tuples.normalize(position - origin))
			xs := intersection.intersect(&s, &r)
			defer delete(xs)
			
			hit, found := intersection.hit(xs)
			if found {
				point := rays.position(&r, hit.t)
				normal := sphere.normal_at(&hit.sphere, point)
				eye := -r.direction
				color := light.lighting(&hit.sphere.material, &l, point, eye, normal)
				canvas.write_pixel(&c, x, y, color)
			}
			
		}
	}

	ppm := canvas.to_ppm(&c)
	result := os.write_entire_file("./images/circle.ppm", transmute([]u8)ppm)
}
