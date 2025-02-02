package test_features

import "core:math"
import "core:testing"
import "src:features/intersection"
import "src:features/light"
import "src:features/patterns"
import "src:features/rays"
import "src:features/shape"
import "src:features/tuples"
import "src:features/transforms"
import "src:features/world"
import utils "src:utilities"

@(test)
create_world :: proc(t: ^testing.T) {
	w := world.empty_world()
	testing.expect(t, len(w.objects) == 0, "Initial world has too many objects.")
}

@(test)
default_world :: proc(t: ^testing.T) {
	l := light.point_light(tuples.point(-10, 10, -10), tuples.color(1, 1, 1))
	s1 := shape.default_shape()
	s2 := shape.default_shape()

	m := light.material(d=0.7, spec=0.2)
	light.set_material_color(&m, tuples.color(0.8, 1.0, 0.6))
	shape.set_material(&s1, m)

	transform := transforms.get_scale_matrix(0.5, 0.5, 0.5)
	shape.set_transform(&s2, transform)

	w := world.default_world()
	defer world.delete_world(&w)

	testing.expect(t, tuples.tuple_equals(l.position, w.light.position), "Default world light is incorrect.")
	testing.expect(t, tuples.color_equals(l.intensity, w.light.intensity), "Default world light is incorrect.")
	testing.expect(t, world.contains_object(&w, &s1), "Default world does not contain a shape with the expected material.")
	testing.expect(t, world.contains_object(&w, &s2), "Default world does not contain a shape with the expected transform.")
}

@(test)
intersect_world :: proc(t: ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	r := rays.create_ray(tuples.point(0, 0, -5), tuples.vector(0, 0, 1))
	xs := world.intersect_world(&w, &r)
	defer delete(xs)

	testing.expect(t, len(xs) == 4, "World intersection is incorrect.")
	testing.expect(t, utils.fp_equals(xs[0].t, 4), "World intersection is incorrect.")
	testing.expectf(t, utils.fp_equals(xs[1].t, 4.5), "World intersection is incorrect. Got %f", xs[1].t)
	testing.expectf(t, utils.fp_equals(xs[2].t, 5.5), "World intersection is incorrect. Got %f", xs[2].t)
	testing.expectf(t, utils.fp_equals(xs[3].t, 6), "World intersection is incorrect. Got %f", xs[3].t)
}

@(test)
shade_intersection :: proc(t: ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	r := rays.create_ray(tuples.point(0, 0, -5), tuples.vector(0, 0, 1))
	s := w.objects[0]
	i := intersection.intersection(4, s)
	comps := intersection.prepare_computation(&i, &r)
	c := world.shade_hit(&w, &comps)
	testing.expectf(t, tuples.color_equals(c, tuples.color(0.38066, 0.47583, 0.2855)), "Shading color is incorrect. Got %v", c)
}

@(test)
shade_inside :: proc(t: ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	l := light.point_light(tuples.point(0, 0.25, 0), tuples.color(1, 1, 1))
	w.light = l

	r := rays.create_ray(tuples.point(0, 0, 0), tuples.vector(0, 0, 1))
	s := w.objects[1]
	i := intersection.intersection(0.5, s)
	comps := intersection.prepare_computation(&i, &r)
	c := world.shade_hit(&w, &comps)
	testing.expect(t, tuples.color_equals(c, tuples.color(0.90498, 0.90498, 0.90498)), "Shading color is incorrect.")
}

@(test)
ray_miss :: proc(t: ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	r := rays.create_ray(tuples.point(0, 0, -5), tuples.vector(0, 1, 0))

	c := world.color_at(&w, &r)
	testing.expect(t, tuples.color_equals(c, tuples.color(0, 0, 0)), "Shading color is incorrect.")
}

@(test)
ray_hit :: proc(t: ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	r := rays.create_ray(tuples.point(0, 0, -5), tuples.vector(0, 0, 1))

	c := world.color_at(&w, &r)
	testing.expect(t, tuples.color_equals(c, tuples.color(0.38066, 0.47583, 0.2855)), "Shading color is incorrect.")
}

@(test)
ray_behind :: proc(t: ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	w.objects[0].material.ambient = 1
	w.objects[1].material.ambient = 1

	r := rays.create_ray(tuples.point(0, 0, 0.75), tuples.vector(0, 0, -1))

	c := world.color_at(&w, &r)
	testing.expectf(t, tuples.color_equals(c, w.objects[1].material.color), "Shading color is incorrect. Expected: %v, Got: %v", w.objects[1].material.color, c)
}

@(test)
no_shadow :: proc(t: ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	p := tuples.point(0, 10, 0)
	is_shadowed := world.is_shadowed(&w, &p)

	testing.expect(t, !is_shadowed, "Point was incorrectly shadowed.")
}

@(test)
is_shadow :: proc(t: ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	p := tuples.point(10, -10, 10)
	is_shadowed := world.is_shadowed(&w, &p)

	testing.expect(t, is_shadowed, "Point was incorrectly shadowed.")
}

@(test)
no_shadow_behind_light :: proc(t: ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	p := tuples.point(-20, 20, -20)
	is_shadowed := world.is_shadowed(&w, &p)

	testing.expect(t, !is_shadowed, "Point was incorrectly shadowed.")
}

@(test)
no_shadow_in_between :: proc(t: ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	p := tuples.point(-2, 2, -2)
	is_shadowed := world.is_shadowed(&w, &p)

	testing.expect(t, !is_shadowed, "Point was incorrectly shadowed.")
}

@(test)
render_shadow :: proc(t: ^testing.T) {
	w := world.empty_world()
	defer world.delete_world(&w)

	l := light.point_light(tuples.point(0, 0, -10), tuples.color(1, 1, 1))
	world.set_light(&w, l)

	s1 := shape.default_shape()
	s2 := shape.default_shape()
	transform := transforms.get_translation_matrix(0, 0 ,10)
	shape.set_transform(&s2, transform)

	world.add_object(&w, s1)
	world.add_object(&w, s2)

	r := rays.create_ray(tuples.point(0, 0, 5), tuples.vector(0, 0, 1))
	i := intersection.intersection(4, s2)

	comps := intersection.prepare_computation(&i, &r)

	c := world.shade_hit(&w, &comps)

	testing.expect(t, tuples.color_equals(c, tuples.color(0.1, 0.1, 0.1)), "Shadow color is not correct.")
}

@(test)
nonreflective_mat :: proc(t: ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)
	
	r := rays.create_ray(tuples.point(0, 0, 0), tuples.vector(0, 0, 1))
	s := &w.objects[1]
	s.material.ambient = 1
	i := intersection.intersection(1, s^)
	comps := intersection.prepare_computation(&i, &r)
	rc := world.reflected_color(&w, &comps)
	testing.expect(t, tuples.color_equals(rc, tuples.black()), "Non reflective color is not correct.")
}

@(test)
reflective_mat :: proc(t: ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	ps := shape.default_shape()
	plane := shape.plane()
	shape.set_shape(&ps, plane)
	ps.material.reflective = 0.5
	shape.set_transform(&ps, transforms.get_translation_matrix(0, -1, 0))
	world.add_object(&w, ps)
	
	r := rays.create_ray(tuples.point(0, 0, -3), tuples.vector(0, -math.sqrt_f64(2) / 2, math.sqrt_f64(2) / 2))
	i := intersection.intersection(math.sqrt_f64(2), ps)
	comps := intersection.prepare_computation(&i, &r)
	rc := world.reflected_color(&w, &comps)

	testing.expectf(t, tuples.color_equals(rc, tuples.color(0.19033, 0.23791, 0.14274)), "Reflective color is not correct. Got %v", rc)
}

@(test)
shade_hit_reflective :: proc(t: ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	ps := shape.default_shape()
	plane := shape.plane()
	shape.set_shape(&ps, plane)
	ps.material.reflective = 0.5
	shape.set_transform(&ps, transforms.get_translation_matrix(0, -1, 0))
	world.add_object(&w, ps)

	r := rays.create_ray(tuples.point(0, 0, -3), tuples.vector(0, -math.sqrt_f64(2) / 2, math.sqrt_f64(2) / 2))
	i := intersection.intersection(math.sqrt_f64(2), ps)
	comps := intersection.prepare_computation(&i, &r)
	rc := world.shade_hit(&w, &comps)

	testing.expectf(t, tuples.color_equals(rc, tuples.color(0.87676, 0.92435, 0.82917)), "Shade hit reflective is not correct. Got %v", rc)
}

@(test)
limit_recursion_reflection :: proc(t: ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	ps := shape.default_shape()
	plane := shape.plane()
	shape.set_shape(&ps, plane)
	ps.material.reflective = 0.5
	shape.set_transform(&ps, transforms.get_translation_matrix(0, -1, 0))
	world.add_object(&w, ps)

	r := rays.create_ray(tuples.point(0, 0, -3), tuples.vector(0, -math.sqrt_f64(2) / 2, math.sqrt_f64(2) / 2))
	i := intersection.intersection(math.sqrt_f64(2), ps)
	comps := intersection.prepare_computation(&i, &r)
	rc := world.reflected_color(&w, &comps, 0)

	testing.expectf(t, tuples.color_equals(rc, tuples.black()), "Rescursion limit is not respected. Got %v", rc)
}

@(test)
opaque_refracted_color :: proc(t: ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	s := w.objects[0]
	r := rays.create_ray(tuples.point(0, 0, -5), tuples.vector(0, 0, 1))

	i1 := intersection.intersection(4, s)
	i2 := intersection.intersection(6, s)

	xs := intersection.aggregate_intersections(i1, i2)
	defer delete(xs)

	comps := intersection.prepare_computation(&xs[0], &r, &xs)
	c := world.refracted_color(&w, &comps, 5)

	testing.expect(t, tuples.color_equals(c, tuples.black()), "Refracted color is not correct")
}

@(test)
limit_recursion_refraction :: proc(t: ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	s := w.objects[0]
	s.material.transparency = 1.0
	s.material.refractive_index = 1.5
	r := rays.create_ray(tuples.point(0, 0, -5), tuples.vector(0, 0, 1))

	i1 := intersection.intersection(4, s)
	i2 := intersection.intersection(6, s)

	xs := intersection.aggregate_intersections(i1, i2)
	defer delete(xs)

	comps := intersection.prepare_computation(&xs[0], &r, &xs)
	c := world.refracted_color(&w, &comps, 0)

	testing.expect(t, tuples.color_equals(c, tuples.black()), "Refracted color is not returning black when out of recursive calls.")
}

@(test)
total_internal_reflection :: proc(t: ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	s := w.objects[0]
	s.material.transparency = 1.0
	s.material.refractive_index = 1.5
	r := rays.create_ray(tuples.point(0, 0, math.sqrt_f64(2)/2), tuples.vector(0, 1, 0))

	i1 := intersection.intersection(-math.sqrt_f64(2) / 2, s)
	i2 := intersection.intersection(math.sqrt_f64(2) / 2, s)

	xs := intersection.aggregate_intersections(i1, i2)
	defer delete(xs)

	comps := intersection.prepare_computation(&xs[1], &r, &xs)

	c := world.refracted_color(&w, &comps, 5)

	testing.expect(t, tuples.color_equals(c, tuples.black()), "Refracted color is not black when total internal reflection is happening.")
}

@(test)
refracted_color :: proc(t: ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	a := w.objects[0]
	m := light.material(1.0)
	light.set_material_pattern(&m, patterns.test_pattern())
	shape.set_material(&w.objects[0], m)

	b := w.objects[1]
	b.material.transparency = 1.0
	b.material.refractive_index = 1.5
	r := rays.create_ray(tuples.point(0, 0, 0.1), tuples.vector(0, 1, 0))

	i1 := intersection.intersection(-0.9899, a)
	i2 := intersection.intersection(-0.4899, b)
	i3 := intersection.intersection(0.4899, b)
	i4 := intersection.intersection(0.9899, a)

	xs := intersection.aggregate_intersections(i1, i2, i3, i4)
	defer delete(xs)

	comps := intersection.prepare_computation(&xs[2], &r, &xs)
	c := world.refracted_color(&w, &comps, 5)
	ec := tuples.color(0, 0.99887, 0.04722)

	testing.expectf(t, tuples.color_equals(c, ec), "Refracted color is incorrect. Got %v, expected %v", c, ec)
}

@(test)
shade_hit_with_refraction :: proc(t : ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	floor := shape.plane_shape()
	ft := transforms.get_translation_matrix(0, -1, 0)
	shape.set_transform(&floor, ft)
	floor.material.transparency = 0.5
	floor.material.refractive_index = 1.5

	ball := shape.default_shape()
	ball.material.color = tuples.color(1, 0, 0)
	ball.material.ambient = 0.5
	bt := transforms.get_translation_matrix(0, -3.5, -0.5)
	shape.set_transform(&ball, bt)

	world.add_object(&w, floor)
	world.add_object(&w, ball)

	r := rays.create_ray(tuples.point(0, 0, -3), tuples.vector(0, -math.sqrt_f64(2)/2, math.sqrt_f64(2)/2))
	
	i := intersection.intersection(math.sqrt_f64(2), floor)
	xs := intersection.aggregate_intersections(i)
	defer delete(xs)

	comps := intersection.prepare_computation(&xs[0], &r, &xs)
	c := world.shade_hit(&w, &comps, 5)
	ec := tuples.color(0.93642, 0.68642, 0.68642)

	testing.expectf(t, tuples.color_equals(c, ec), "Refracted color from shade hit is incorrect. Got %v, expected %v", c, ec)
}

@(test)
shade_hit_with_schlick :: proc(t : ^testing.T) {
	w := world.default_world()
	defer world.delete_world(&w)

	floor := shape.plane_shape()
	ft := transforms.get_translation_matrix(0, -1, 0)
	shape.set_transform(&floor, ft)
	floor.material.reflective = 0.5
	floor.material.transparency = 0.5
	floor.material.refractive_index = 1.5

	ball := shape.default_shape()
	ball.material.color = tuples.color(1, 0, 0)
	ball.material.ambient = 0.5
	bt := transforms.get_translation_matrix(0, -3.5, -0.5)
	shape.set_transform(&ball, bt)

	world.add_object(&w, floor)
	world.add_object(&w, ball)

	r := rays.create_ray(tuples.point(0, 0, -3), tuples.vector(0, -math.sqrt_f64(2)/2, math.sqrt_f64(2)/2))
	
	i := intersection.intersection(math.sqrt_f64(2), floor)
	xs := intersection.aggregate_intersections(i)
	defer delete(xs)

	comps := intersection.prepare_computation(&xs[0], &r, &xs)
	c := world.shade_hit(&w, &comps, 5)
	ec := tuples.color(0.93391, 0.69643, 0.69243)

	testing.expectf(t, tuples.color_equals(c, ec), "Color from shade hit with Schlick is incorrect. Got %v, expected %v", c, ec)
}
