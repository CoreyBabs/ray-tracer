package world

import "core:slice"
import "src:features/intersection"
import "src:features/light"
import "src:features/rays"
import "src:features/sphere"
import "src:features/transforms"
import "src:features/tuples"

World :: struct {
	objects: [dynamic]sphere.Sphere,
	light: light.Light
}

empty_world :: proc() -> World {
	return World{nil, light.Light{}}
}


set_light :: proc(w: ^World, l: light.Light) {
	w.light = l
}

add_object :: proc(w: ^World, s: sphere.Sphere) {
	if w.objects == nil {
		w.objects = make([dynamic]sphere.Sphere, 1)
		w.objects[0] = s
	}
	else {
		append(&w.objects, s)
	}
}

default_world :: proc() -> World {
	l := light.point_light(tuples.point(-10, 10, -10), tuples.color(1, 1, 1))
	s1 := sphere.sphere()
	s2 := sphere.sphere()

	m := light.material(d=0.7, spec=0.2)
	light.set_material_color(&m, tuples.color(0.8, 1.0, 0.6))
	sphere.set_material(&s1, m)

	transform := transforms.get_scale_matrix(0.5, 0.5, 0.5)
	sphere.set_transform(&s2, transform)

	objs := make([dynamic]sphere.Sphere, 2)
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
	return light.lighting(&comps.object.material, &w.light, comps.point, comps.eyev, comps.normalv)
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

contains_object :: proc(w: ^World, s: ^sphere.Sphere) -> bool {
	for obj in w.objects {
		if sphere.sphere_equals(obj, s^) {
			return true
		}
	}

	return false
}



delete_world :: proc(w: ^World) {
	delete(w.objects)
}

@(private)
sort_intersections :: proc(i1, i2: intersection.Intersection) -> bool {
	return i1.t < i2.t
}
