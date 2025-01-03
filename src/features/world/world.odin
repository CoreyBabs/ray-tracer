package world

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

shade_hit :: proc(w: ^World, comps: ^intersection.Precompute) -> tuples.Color {
	in_shadow := is_shadowed(w, &comps.over_point)
	return light.lighting(&comps.object.material, &w.light, comps.over_point, comps.eyev, comps.normalv, in_shadow)
}

color_at :: proc(w: ^World, ray: ^rays.Ray) -> tuples.Color {
	xs := intersect_world(w, ray)
	defer delete(xs)

	hit, found := intersection.hit(xs)
	if !found {
		return tuples.color(0, 0, 0)
	}

	comps := intersection.prepare_computation(&hit, ray)
	return shade_hit(w, &comps)
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

@(private)
sort_intersections :: proc(i1, i2: intersection.Intersection) -> bool {
	return i1.t < i2.t
}
