package side_projects

import "core:math"
import "core:os"
import "src:features/tuples"
import "src:features/canvas"
import "src:features/transforms"

clock :: proc() {
	c := canvas.canvas(800, 800)
	defer canvas.free_canvas(&c)
	color := tuples.color(255, 255, 255)


	r : f32 = (3.0 / 8.0) * f32(c.width)
	cx := (c.width / 2) - 1
	cy := (c.width / 2) - 1

	p := tuples.point(0, 0, 1)

	for i := 0; i < 12; i+=1 {
		radians := f32(i) * (math.PI / 6)
		rp := transforms.rotate_y(p, radians)

		clock_point := rp * r
	
		x := cx + int(clock_point.x)
		y := cy + int(clock_point.z)
		canvas.write_pixel(&c, x, y, color)
	}


	ppm := canvas.to_ppm(&c)

	result := os.write_entire_file("./images/clock.ppm", transmute([]u8)ppm)
}
