package canvas

import "core:fmt"
import "core:math"
import "core:strings"
import "core:strconv"
import "src:features/tuples"

Canvas :: struct {
	width: int,
	height: int,
	data: []tuples.Color
}

canvas :: proc(w, h: int) -> Canvas {
	data:= make([]tuples.Color, w * h, context.allocator) 

	for i := 0; i < w * h; i += 1 {
		data[i] = tuples.color(0, 0, 0)
	}

	return Canvas{w, h, data}
}

write_pixel :: proc(canvas: ^Canvas, x, y: int, color: tuples.Color) {
	if x < 0 || x >= canvas.width || y < 0 || y >= canvas.height {
		return
	}

	idx := get_index(x, y, canvas.width)
	canvas.data[idx] = color
}

get_pixel :: proc(canvas: ^Canvas, x, y: int) -> tuples.Color {
	idx := get_index(x, y, canvas.width)
	return canvas.data[idx]
}

to_ppm :: proc(canvas: ^Canvas) -> string {
	builder := strings.builder_make(context.temp_allocator)
	defer strings.builder_destroy(&builder)
	ppm_header(&builder, canvas.width, canvas.height)
	ppm_body(&builder, canvas)
	return strings.to_string(builder)
}

free_canvas :: proc(canvas: ^Canvas) {
	delete(canvas.data)
}

@(private)
get_index :: proc(x, y, width: int) -> int {
	return y * width + x
}

@(private)
ppm_header :: proc(builder: ^strings.Builder, w, h: int) {
	strings.write_string(builder, "P3\n")

	strings.write_int(builder, w)
	strings.write_string(builder, " ")
	strings.write_int(builder, h)
	strings.write_string(builder, "\n")

	strings.write_string(builder, "255\n")
}

@(private)
ppm_body :: proc(builder: ^strings.Builder, canvas: ^Canvas) {
	// print_first_char(builder)
	line := strings.builder_make()
	defer strings.builder_destroy(&line)
	col_count := 0
	for i := 0; i < canvas.width * canvas.height; i+=1 {
		for j := 0; j < 3; j += 1 {
			component, component_str := clamp_component_and_covert_to_string(canvas.data[i][j])
			if col_count >= canvas.width || strings.builder_len(line) + len(component_str) + 1 > 70 {
				l := strings.to_string(line)
				strings.write_string(builder, l)
				strings.write_string(builder, "\n")
				strings.builder_reset(&line)
				if col_count >= canvas.width {
					col_count = 0
				}
			}
			else if strings.builder_len(line) > 0 {
				strings.write_string(&line, " ")
			}

			strings.write_int(&line, component)
		}

		// print_first_char(builder)
		col_count += 1
	}

	l := strings.to_string(line)
	strings.write_string(builder, l)
	strings.write_string(builder, "\n")
	// print_first_char(builder)
}

@(private)
clamp_component_and_covert_to_string :: proc(value: f32) -> (int, string) {
	v : int = auto_cast math.round_f32(math.clamp(value * 255, 0, 255))
	
	buf: [4]byte
	result := strconv.itoa(buf[:], v)
	return v, result
}

print_first_char :: proc(builder: ^strings.Builder) {
	str := strings.to_string(builder^)
	for codepoint in str {
		fmt.println(codepoint)
		break
	}		
}
