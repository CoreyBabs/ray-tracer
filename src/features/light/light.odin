package light

import "core:math"
import "src:features/tuples"

Light :: struct {
	position: tuples.Tuple,
	intensity: tuples.Color
}

point_light :: proc(p: tuples.Tuple, i: tuples.Color) -> Light {
	return Light{p, i}
}

lighting :: proc(
	m: Material,
	l: Light,
	p: tuples.Tuple,
	eyev: tuples.Tuple,
	n: tuples.Tuple) -> tuples.Color {

	effective_color := m.color * l.intensity

	lv := tuples.normalize(l.position - p)
	ambient := effective_color * m.ambient
	diffuse := tuples.color(0, 0, 0)
	specular := tuples.color(0, 0, 0)
	light_dot_normal := tuples.dot(lv, n)
	if light_dot_normal >= 0 {
		diffuse = effective_color * m.diffuse * light_dot_normal

		reflectv := tuples.reflect(-lv, n)
		reflect_dot_eye := tuples.dot(reflectv, eyev)
		if reflect_dot_eye > 0 {
			factor := math.pow(reflect_dot_eye, m.shininess)
			specular = l.intensity * m.specular * factor
		}
	}

	diff_plus_spec := tuples.add_colors(diffuse, specular)
	return tuples.add_colors(ambient, diff_plus_spec)
}
