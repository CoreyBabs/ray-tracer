package world

import "core:math"
import "core:slice"
import "src:features/intersection"
import "src:features/light"
import "src:features/rays"
import "src:features/shape"
import "src:features/transforms"
import "src:features/tuples"

World :: struct {
	objects: [dynamic]shape.Shape,
	light: light.Light
}

empty_world :: proc() -> World {
	return World{nil, light.Light{}}
}


set_light :: proc(w: ^World, l: light.Light) {
	w.light = l
}

add_object :: proc(w: ^World, s: shape.Shape) {
	if w.objects == nil {
		w.objects = make([dynamic]shape.Shape, 1)
		w.objects[0] = s
	}
	else {
		append(&w.objects, s)
	}
}

default_world :: proc() -> World {
	l := light.point_light(tuples.point(-10, 10, -10), tuples.color(1, 1, 1))
	s1 := shape.default_shape()
	s2 := shape.default_shape()

	m := light.material(d=0.7, spec=0.2)
	light.set_material_color(&m, tuples.color(0.8, 1.0, 0.6))
	shape.set_material(&s1, m)

	transform := transforms.get_scale_matrix(0.5, 0.5, 0.5)
	shape.set_transform(&s2, transform)

	objs := make([dynamic]shape.Shape, 2)
	objs[0] = s1
	objs[1] = s2

	return World{objs, l}
}

intersect_world :: proc(w: ^World, ray: ^rays.Ray) -> [dynamic]intersection.Intersection {
	intersections: [dynamic]intersection.Intersection
	for &obj in w.objects {
		xs := intersection.intersect(&obj, ray)
		append(&intersections, ..xs[:])
		delete(xs)
	}

	slice.sort_by(intersections[:], sort_intersections)
	return intersections
}

shade_hit :: proc(w: ^World, comps: ^intersection.Precompute, remaining: int = 5) -> tuples.Color {
	in_shadow := is_shadowed(w, &comps.over_point)
	surface := light.lighting(&comps.object.material, comps.object.transform, &w.light, comps.over_point, comps.eyev, comps.normalv, in_shadow)
	reflected := reflected_color(w, comps, remaining)
	refracted := refracted_color(w, comps, remaining)

	if comps.object.material.reflective > 0 && comps.object.material.transparency > 0 {
		reflectance := schlick(comps)
		fc := tuples.add_colors(surface, tuples.color_scalar_multiply(reflected, reflectance))
		fc = tuples.add_colors(fc, tuples.color_scalar_multiply(refracted, 1.0 - reflectance))
		return fc
	}

	fc := tuples.add_colors(surface, reflected)
	return tuples.add_colors(fc, refracted)
}

color_at :: proc(w: ^World, ray: ^rays.Ray, remaining: int = 5) -> tuples.Color {
	xs := intersect_world(w, ray)
	defer delete(xs)

	hit, found := intersection.hit(xs)
	if !found {
		return tuples.color(0, 0, 0)
	}

	comps := intersection.prepare_computation(&hit, ray, &xs)
	return shade_hit(w, &comps, remaining)
}

contains_object :: proc(w: ^World, s: ^shape.Shape) -> bool {
	for &obj in w.objects {
		if shape.shape_equals(&obj, s) {
			return true
		}
	}

	return false
}

is_shadowed :: proc(w: ^World, p: ^tuples.Tuple) -> bool {
	v := tuples.subtract_tuples(w.light.position, p^)
	distance := tuples.magnitude(v)
	direction := tuples.normalize(v)
	ray := rays.create_ray(p^, direction)

	intersections := intersect_world(w, &ray)
	defer delete(intersections)

	hit, found := intersection.hit(intersections)
	return found && hit.t < distance
}

delete_world :: proc(w: ^World) {
	delete(w.objects)
}

reflected_color :: proc(w: ^World, comps: ^intersection.Precompute, remaining: int = 5) -> tuples.Color {
	if comps.object.material.reflective == 0 || remaining < 1 {
		return tuples.black()
	}

	reflected_ray := rays.create_ray(comps.over_point, comps.reflectv)
	color := color_at(w, &reflected_ray, remaining - 1)
	return tuples.color_scalar_multiply(color, comps.object.material.reflective)
}

refracted_color :: proc(w: ^World, comps: ^intersection.Precompute, remaining: int = 5) -> tuples.Color {
	if remaining == 0 || comps.object.material.transparency == 0 {
		return tuples.black()
	}

	n_ratio := comps.n1 / comps.n2
	cos_i := tuples.dot(comps.eyev, comps.normalv)
	sin2_t := n_ratio * n_ratio * (1 - cos_i * cos_i)

	if sin2_t > 1 {
		return tuples.black()
	}

	cos_t := math.sqrt_f64(1.0 - sin2_t)
	ndir := tuples.scalar_multiply(comps.normalv, n_ratio * cos_i - cos_t)
	eye_dir := tuples.scalar_multiply(comps.eyev, n_ratio)
	dir := tuples.subtract_tuples(ndir, eye_dir)

	ref_ray := rays.create_ray(comps.under_point, dir)

	color := color_at(w, &ref_ray, remaining - 1)
	return tuples.color_scalar_multiply(color, comps.object.material.transparency)
}

schlick :: proc(comps: ^intersection.Precompute) -> f64 {
	cos_i := tuples.dot(comps.eyev, comps.normalv)
	if comps.n1 > comps.n2 {
		n_ratio := comps.n1 / comps.n2
		sin2_t := n_ratio * n_ratio * (1 - cos_i * cos_i)

		if sin2_t > 1.0 {
			return 1.0
		}

		cos_t := math.sqrt(1.0 - sin2_t)
		cos_i = cos_t
	}

	r0 := math.pow((comps.n1 - comps.n2) / (comps.n1 + comps.n2), 2)
	return r0 + (1 - r0) * math.pow((1 - cos_i), 5)
}

@(private)
sort_intersections :: proc(i1, i2: intersection.Intersection) -> bool {
	return i1.t < i2.t
}
