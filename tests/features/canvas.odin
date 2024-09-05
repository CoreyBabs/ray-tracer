package test_features

import "core:fmt"
import "core:os"
import "core:strings"
import "core:testing"
import "src:features/canvas"
import "src:features/tuples"

@(test)
create_canvas :: proc(t: ^testing.T) {
	c := canvas.canvas(10, 20)
	defer canvas.free_canvas(&c)

	bg := tuples.color(0, 0, 0)
	result := c.width == 10
	result &= c.height == 20
	for i := 0; i < c.width * c.height; i += 1 {
		result &= tuples.color_equals(c.data[i], bg)
	}

	result &= len(c.data) == c.width * c.height

	testing.expect(t, result, "canvas was not created correctly")
}

@(test)
write_pixel_to_canvas :: proc(t: ^testing.T) {
	c := canvas.canvas(10, 20)
	defer canvas.free_canvas(&c)

	bg := tuples.color(1, 0, 0)
	canvas.write_pixel(&c, 2, 3, bg)
	pixel := canvas.get_pixel(&c, 2, 3)
	result := tuples.color_equals(bg, pixel)

	testing.expect(t, result, "canvas was not updated correctly")
}

@(test)
ppm_header :: proc(t: ^testing.T) {
	c := canvas.canvas(5, 3)
	defer canvas.free_canvas(&c)

	ppm := canvas.to_ppm(&c)
	
	expected := "P3\n5 3\n255\n"
	testing.expect(t, strings.starts_with(ppm, expected), "ppm header is incorrect")
}

@(test)
ppm_body :: proc(t: ^testing.T) {
	c := canvas.canvas(5, 3)
	defer canvas.free_canvas(&c)

	c1 := tuples.color(1.5, 0, 0)
	c2 := tuples.color(0, 0.5, 0)
	c3 := tuples.color(-0.5, 0, 1)

	canvas.write_pixel(&c, 0, 0, c1)
	canvas.write_pixel(&c, 2, 1, c2)
	canvas.write_pixel(&c, 4, 2, c3)
	
	ppm := canvas.to_ppm(&c)
	result := os.write_entire_file("../images/ppm_test.ppm", transmute([]u8)ppm)

	expected := "255 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n" + \
				"0 0 0 0 0 0 0 128 0 0 0 0 0 0 0\n" + \
				"0 0 0 0 0 0 0 0 0 0 0 0 0 0 255\n"

	testing.expectf(t, strings.ends_with(ppm, expected), "ppm body is incorrect: got\n %s", ppm)
}

@(test)
ppm_body_line_length :: proc(t: ^testing.T) {
	c := canvas.canvas(10, 2)
	defer canvas.free_canvas(&c)

	c1 := tuples.color(1, 0.8, 0.6)

	for i := 0; i < c.width; i += 1 {
		for j := 0; j < c.height; j += 1 {
			canvas.write_pixel(&c, i, j, c1)
		}
	}
	
	ppm := canvas.to_ppm(&c)

	expected := "255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204\n" + \
				"153 255 204 153 255 204 153 255 204 153 255 204 153\n" + \
				"255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204\n" + \
				"153 255 204 153 255 204 153 255 204 153 255 204 153\n"

	testing.expectf(t, strings.ends_with(ppm, expected), "ppm body is incorrect: got\n %s\n%s", ppm, expected)
}

@(test)
ppm_ends_with_newline :: proc(t: ^testing.T) {
	c := canvas.canvas(5, 3)
	defer canvas.free_canvas(&c)

	ppm := canvas.to_ppm(&c)

	testing.expect(t, strings.ends_with(ppm, "\n"), "ppm does not end with a new line")
}
