package test_features

import "core:testing"
import "src:features/intersection"
import "src:features/light"
import "src:features/rays"
import "src:features/sphere"
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
	s1 := sphere.sphere()
	s2 := sphere.sphere()

	m := light.material(d=0.7, spec=0.2)
	light.set_material_color(&m, tuples.color(0.8, 1.0, 0.6))
	sphere.set_material(&s1, m)

	transform := transforms.get_scale_matrix(0.5, 0.5, 0.5)
	sphere.set_transform(&s2, transform)

	w := world.default_world()
	defer world.delete_world(&w)

	testing.expect(t, tuples.tuple_equals(l.position, w.light.position), "Default world light is incorrect.")
	testing.expect(t, tuples.color_equals(l.intensity, w.light.intensity), "Default world light is incorrect.")
	testing.expect(t, world.contains_object(&w, &s1), "Default world does not contain a sphere with the expected material.")
	testing.expect(t, world.contains_object(&w, &s2), "Default world does not contain a sphere with the expected transform.")
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

	s1 := sphere.sphere()
	s2 := sphere.sphere()
	transform := transforms.get_translation_matrix(0, 0 ,10)
	sphere.set_transform(&s2, transform)

	world.add_object(&w, s1)
	world.add_object(&w, s2)

	r := rays.create_ray(tuples.point(0, 0, 5), tuples.vector(0, 0, 1))
	i := intersection.intersection(4, s2)

	comps := intersection.prepare_computation(&i, &r)

	c := world.shade_hit(&w, &comps)

	testing.expect(t, tuples.color_equals(c, tuples.color(0.1, 0.1, 0.1)), "Shadow color is not correct.")
}
