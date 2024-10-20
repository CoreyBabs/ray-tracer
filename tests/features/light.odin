package test_features

import "core:testing"
import "core:math"
import "src:features/light"
import "src:features/sphere"
import "src:features/transforms"
import "src:features/tuples"
import utils "src:utilities"

@(test)
create_light :: proc(t: ^testing.T) {
	c := tuples.color(1, 1, 1)
	p := tuples.point(0, 0, 0)
	l := light.point_light(p, c)

	testing.expect(t, tuples.tuple_equals(l.position, p), "Light position is not correct.")
	testing.expect(t, tuples.color_equals(l.intensity, c), "Light intensity is not correct.")
}

@(test)
default_material :: proc(t: ^testing.T) {
	m := light.material()
	testing.expectf(t, tuples.color_equals(m.color, tuples.color(1, 1, 1)), "Default material color is not correct.")
	testing.expectf(t, utils.fp_equals(m.ambient, 0.1), "Default material ambient is not correct. Expected: %f, Got: %f", 0.1, m.ambient)
	testing.expectf(t, utils.fp_equals(m.diffuse, 0.9), "Default material diffuse is not correct. Expected: %f, Got: %f", 0.9, m.diffuse)
	testing.expectf(t, utils.fp_equals(m.specular, 0.9), "Default material specular is not correct. Expected: %f, Got: %f", 0.9, m.specular)
	testing.expectf(t, utils.fp_equals(m.shininess, 200.0), "Default material shininess is not correct. Expected: %f, Got: %f", 200.0, m.shininess)
}

@(test)
eye_between_light_and_surface :: proc(t: ^testing.T) {
	m := light.material()
	p := tuples.point(0, 0, 0)

	eyev := tuples.vector(0, 0, -1)
	n := tuples.vector(0, 0, -1)
	l:= light.point_light(tuples.point(0, 0, -10), tuples.color(1, 1, 1))
	result := light.lighting(&m, &l, p, eyev, n)

	testing.expect(t, tuples.color_equals(result, tuples.color(1.9, 1.9, 1.9)), "Lighting is incorrect.")
}

@(test)
eye_offset_by_45_degrees :: proc(t: ^testing.T) {
	m := light.material()
	p := tuples.point(0, 0, 0)

	a := math.sqrt_f32(2) / 2
	eyev := tuples.vector(0, a, -a)
	n := tuples.vector(0, 0, -1)
	l:= light.point_light(tuples.point(0, 0, -10), tuples.color(1, 1, 1))
	result := light.lighting(&m, &l, p, eyev, n)

	testing.expect(t, tuples.color_equals(result, tuples.color(1.0, 1.0, 1.0)), "Lighting is incorrect.")
}

@(test)
light_offset_by_45_degrees :: proc(t: ^testing.T) {
	m := light.material()
	p := tuples.point(0, 0, 0)

	eyev := tuples.vector(0, 0, -1)
	n := tuples.vector(0, 0, -1)
	l:= light.point_light(tuples.point(0, 10, -10), tuples.color(1, 1, 1))
	result := light.lighting(&m, &l, p, eyev, n)

	testing.expect(t, tuples.color_equals(result, tuples.color(0.7364, 0.7364, 0.7364)), "Lighting is incorrect.")
}

@(test)
eye_in_reflection_path :: proc(t: ^testing.T) {
	m := light.material()
	p := tuples.point(0, 0, 0)

	a := math.sqrt_f32(2) / 2
	eyev := tuples.vector(0, -a, -a)
	n := tuples.vector(0, 0, -1)
	l:= light.point_light(tuples.point(0, 10, -10), tuples.color(1, 1, 1))
	result := light.lighting(&m, &l, p, eyev, n)

	testing.expectf(t, tuples.color_equals(result, tuples.color(1.63638, 1.63638, 1.63638)), "Lighting is incorrect. Got: %v", result)
}

@(test)
light_behind_surface :: proc(t: ^testing.T) {
	m := light.material()
	p := tuples.point(0, 0, 0)

	eyev := tuples.vector(0, 0, -1)
	n := tuples.vector(0, 0, -1)
	l := light.point_light(tuples.point(0, 0, 10), tuples.color(1, 1, 1))
	result := light.lighting(&m, &l, p, eyev, n)

	testing.expectf(t, tuples.color_equals(result, tuples.color(0.1, 0.1, 0.1)), "Lighting is incorrect. Got: %v", result)
}
