package test_features

import "core:math"
import "core:testing"
import "src:features/intersection"
import "src:features/rays"
import "src:features/shape"
import "src:features/transforms"
import "src:features/tuples"
import "src:features/world"
import utils "src:utilities"


@(test)
create_intersection :: proc(t: ^testing.T) {
	s := shape.default_shape()
	i := intersection.intersection(3.5, s)

	testing.expect(t, utils.fp_equals(i.t, 3.5), "Intersection t value is not correct.")
	testing.expect(t, shape.shape_equals(&s, &i.shape), "Intersection sphere is not correct.")
}

@(test)
multiple_intersections :: proc(t: ^testing.T) {
	s := shape.default_shape()
	i1 := intersection.intersection(1, s)
	i2 := intersection.intersection(2, s)
	xs := intersection.aggregate_intersections(i1, i2)
	defer delete(xs)

	testing.expect(t, len(xs) == 2, "Intersection aggregate does not have expected length.")
	testing.expect(t, xs[0].t == 1, "First intersection does not have correct t value.")
	testing.expect(t, xs[1].t == 2, "Second intersection does not have correct t value.")
}

@(test)
test_intersection :: proc(t: ^testing.T) {
	origin := tuples.point(0, 0, -5)
	direction := tuples.vector(0, 0, 1)
	ray := rays.create_ray(origin, direction)
	s := shape.default_shape()
	xs := intersection.intersect(&s, &ray)
	defer delete(xs)

	testing.expect(t, len(xs) == 2, "Intersection count does not match.")
	testing.expect(t, utils.fp_equals(xs[0].t, 4.0), "First intersection is not correct")
	testing.expect(t, utils.fp_equals(xs[1].t, 6.0), "Second intersection is not correct")
}

@(test)
test_intersection_tangent :: proc(t: ^testing.T) {
	origin := tuples.point(0, 1, -5)
	direction := tuples.vector(0, 0, 1)
	ray := rays.create_ray(origin, direction)
	s := shape.default_shape()
	xs := intersection.intersect(&s, &ray)
	defer delete(xs)

	testing.expect(t, len(xs) == 2, "Intersection count does not match.")
	testing.expect(t, utils.fp_equals(xs[0].t, 5.0), "First intersection is not correct")
	testing.expect(t, utils.fp_equals(xs[1].t, 5.0), "Second intersection is not correct")
}

@(test)
test_intersection_miss :: proc(t: ^testing.T) {
	origin := tuples.point(0, 2, -5)
	direction := tuples.vector(0, 0, 1)
	ray := rays.create_ray(origin, direction)
	s := shape.default_shape()
	xs := intersection.intersect(&s, &ray)
	defer delete(xs)

	testing.expect(t, len(xs) == 0, "Intersection count does not match.")
}

@(test)
test_intersection_inside :: proc(t: ^testing.T) {
	origin := tuples.point(0, 0, 0)
	direction := tuples.vector(0, 0, 1)
	ray := rays.create_ray(origin, direction)
	s := shape.default_shape()
	xs := intersection.intersect(&s, &ray)
	defer delete(xs)

	testing.expect(t, len(xs) == 2, "Intersection count does not match.")
	testing.expect(t, utils.fp_equals(xs[0].t, -1.0), "First intersection is not correct")
	testing.expect(t, utils.fp_equals(xs[1].t, 1.0), "Second intersection is not correct")
}

@(test)
test_intersection_behind :: proc(t: ^testing.T) {
	origin := tuples.point(0, 0, 5)
	direction := tuples.vector(0, 0, 1)
	ray := rays.create_ray(origin, direction)
	s := shape.default_shape()
	xs := intersection.intersect(&s, &ray)
	defer delete(xs)

	testing.expect(t, len(xs) == 2, "Intersection count does not match.")
	testing.expect(t, utils.fp_equals(xs[0].t, -6.0), "First intersection is not correct")
	testing.expect(t, utils.fp_equals(xs[1].t, -4.0), "Second intersection is not correct")
}

@(test)
intersection_shapes :: proc(t: ^testing.T) {
	origin := tuples.point(0, 0, -5)
	dir := tuples.vector(0, 0, 1)
	r := rays.create_ray(origin, dir)
	s := shape.default_shape()

	xs := intersection.intersect(&s, &r)
	defer delete(xs)

	testing.expect(t, len(xs) == 2, "Intersection count does not match.")
	testing.expect(t, shape.shape_equals(&xs[0].shape, &s), "First intersection sphere does not match.")
	testing.expect(t, shape.shape_equals(&xs[1].shape, &s), "Second intersection sphere does not match.")
}

@(test)
hit_test_all_positive :: proc(t: ^testing.T) {
	s := shape.default_shape()
	i1 := intersection.intersection(1, s)
	i2 := intersection.intersection(2, s)
	xs := intersection.aggregate_intersections(i1, i2)
	defer delete(xs)

	hit, found  := intersection.hit(xs)
	testing.expect(t, found, "Hit was not found.")
	testing.expect(t, intersection.intersection_equals(&hit, &i1), "Hit was not correct.")
}

@(test)
hit_test_some_negative :: proc(t: ^testing.T) {
	s := shape.default_shape()
	i1 := intersection.intersection(-1, s)
	i2 := intersection.intersection(1, s)
	xs := intersection.aggregate_intersections(i2, i1)
	defer delete(xs)

	hit, found := intersection.hit(xs)
	testing.expect(t, found, "Hit was not found.")
	testing.expect(t, intersection.intersection_equals(&hit, &i2), "Hit was not correct.")
}

@(test)
hit_test_all_negative :: proc(t: ^testing.T) {
	s := shape.default_shape()
	i1 := intersection.intersection(-2, s)
	i2 := intersection.intersection(-1, s)
	xs := intersection.aggregate_intersections(i2, i1)
	defer delete(xs)

	hit, found := intersection.hit(xs)
	testing.expect(t,  !found, "Hit was found when it should not have been.")
}

@(test)
hit_test_many :: proc(t: ^testing.T) {
	s := shape.default_shape()
	i1 := intersection.intersection(5, s)
	i2 := intersection.intersection(7, s)
	i3 := intersection.intersection(-3, s)
	i4 := intersection.intersection(2, s)
	xs := intersection.aggregate_intersections(i1, i2, i3, i4)
	defer delete(xs)

	hit, found := intersection.hit(xs)
	testing.expect(t, found, "Hit was not found.")
	testing.expect(t, intersection.intersection_equals(&hit, &i4), "Hit was not correct.")
}

@(test)
scaled_intersection :: proc(t: ^testing.T) {
	origin := tuples.point(0, 0, -5)
	dir := tuples.vector(0, 0, 1)
	r := rays.create_ray(origin, dir)
	s := shape.default_shape()
	transform := transforms.get_scale_matrix(2, 2, 2)
	shape.set_transform(&s, transform)

	xs := intersection.intersect(&s, &r)
	defer delete(xs)

	testing.expect(t, len(xs) == 2, "Intersection count does not match.")
	testing.expectf(t, utils.fp_equals(xs[0].t, 3), "First intersection t does not match. Got %f", xs[0].t)
	testing.expectf(t, utils.fp_equals(xs[1].t, 7), "Second intersection t does not match. Got %f", xs[1].t)
}

@(test)
translated_intersection :: proc(t: ^testing.T) {
	origin := tuples.point(0, 0, -5)
	dir := tuples.vector(0, 0, 1)
	r := rays.create_ray(origin, dir)
	s := shape.default_shape()
	transform := transforms.get_translation_matrix(5, 5, 5)
	shape.set_transform(&s, transform)

	xs := intersection.intersect(&s, &r)
	defer delete(xs)

	testing.expect(t, len(xs) == 0, "Intersection count does not match.")
}

@(test)
precompute :: proc(t: ^testing.T) {
	origin := tuples.point(0, 0, -5)
	dir := tuples.vector(0, 0, 1)
	r := rays.create_ray(origin, dir)
	s := shape.default_shape()
	i1 := intersection.intersection(4, s)

	precomp := intersection.prepare_computation(&i1, &r)

	testing.expect(t, utils.fp_equals(precomp.t, i1.t), "Precomputed t is not correct.")
	testing.expect(t, shape.shape_equals(&precomp.object, &i1.shape), "Precomputed object is not correct.")
	testing.expect(t, tuples.tuple_equals(precomp.point, tuples.point(0, 0, -1)), "Precomputed point is not correct.")
	testing.expectf(t, tuples.tuple_equals(precomp.eyev, tuples.vector(0, 0, -1)), "Precomputed eyev is not correct. Got %v", precomp.eyev)
	testing.expect(t, tuples.tuple_equals(precomp.normalv, tuples.vector(0, 0, -1)), "Precomputed normalv is not correct.")
}

@(test)
outside_hit :: proc(t: ^testing.T) {
	origin := tuples.point(0, 0, -5)
	dir := tuples.vector(0, 0, 1)
	r := rays.create_ray(origin, dir)
	s := shape.default_shape()
	i1 := intersection.intersection(4, s)

	precomp := intersection.prepare_computation(&i1, &r)
	testing.expect(t, !precomp.inside, "Precomputed inside is not correct.")
}

@(test)
inside_hit :: proc(t: ^testing.T) {
	origin := tuples.point(0, 0, 0)
	dir := tuples.vector(0, 0, 1)
	r := rays.create_ray(origin, dir)
	s := shape.default_shape()
	i1 := intersection.intersection(1, s)

	precomp := intersection.prepare_computation(&i1, &r)
	testing.expect(t, precomp.inside, "Precomputed inside is not correct.")
	testing.expect(t, tuples.tuple_equals(precomp.point, tuples.point(0, 0, 1)), "Precomputed point is not correct.")
	testing.expectf(t, tuples.tuple_equals(precomp.eyev, tuples.vector(0, 0, -1)), "Precomputed eyev is not correct. Got %v", precomp.eyev)
	testing.expect(t, tuples.tuple_equals(precomp.normalv, tuples.vector(0, 0, -1)), "Precomputed normalv is not correct.")
}

@(test)
offset_hit :: proc(t: ^testing.T) {
	origin := tuples.point(0, 0, -5)
	dir := tuples.vector(0, 0, 1)
	r := rays.create_ray(origin, dir)
	s := shape.default_shape()
	transform := transforms.get_translation_matrix(0, 0, 1)
	shape.set_transform(&s, transform)
	i1 := intersection.intersection(5, s)

	precomp := intersection.prepare_computation(&i1, &r)

	testing.expect(t, precomp.over_point.z < -utils.EPS / 2, "Precomputed over point is not correct.")
	testing.expectf(t, precomp.point.z > precomp.over_point.z, "Precomputed over point is not correct. Expected: %v, Got: %v", precomp.point, precomp.over_point)
}

@(test)
shape_scaled_intersection :: proc(t: ^testing.T) {
	origin := tuples.point(0, 0, -5)
	dir := tuples.vector(0, 0, 1)
	r := rays.create_ray(origin, dir)
	s := shape.default_shape()
	transform := transforms.get_scale_matrix(2, 2, 2)
	shape.set_transform(&s, transform)

	xs := intersection.intersect(&s, &r)
	defer delete(xs)

	testing.expectf(t, tuples.tuple_equals(s.ray.origin, tuples.point(0, 0, -2.5)), "Shape ray origin does not match. Got %v", s.ray.origin)
	testing.expectf(t, tuples.tuple_equals(s.ray.direction, tuples.vector(0, 0, 0.5)), "Shape ray direction does not match. Got %v", s.ray.direction)
}

@(test)
shape_translated_intersection :: proc(t: ^testing.T) {
	origin := tuples.point(0, 0, -5)
	dir := tuples.vector(0, 0, 1)
	r := rays.create_ray(origin, dir)
	s := shape.default_shape()
	transform := transforms.get_translation_matrix(5, 0, 0)
	shape.set_transform(&s, transform)

	xs := intersection.intersect(&s, &r)
	defer delete(xs)

	testing.expectf(t, tuples.tuple_equals(s.ray.origin, tuples.point(-5, 0, -5)), "Shape ray origin does not match. Got %v", s.ray.origin)
	testing.expectf(t, tuples.tuple_equals(s.ray.direction, tuples.vector(0, 0, 1)), "Shape ray direction does not match. Got %v", s.ray.direction)
}

@(test)
calculate_reflect_vector :: proc(t: ^testing.T) {
	s := shape.default_shape()
	plane := shape.plane()
	shape.set_shape(&s, plane) 

	ray := rays.create_ray(tuples.point(0, 1, -1), tuples.vector(0, -math.sqrt_f64(2) / 2, math.sqrt_f64(2) / 2))
	i := intersection.intersection(math.sqrt_f64(2), s)
	comps := intersection.prepare_computation(&i, &ray)

	testing.expect(t, tuples.tuple_equals(comps.reflectv, tuples.vector(0, math.sqrt_f64(2) / 2, math.sqrt_f64(2) / 2)), "reflect vector is incorrect.")
}

@(test)
find_n1_and_n2 :: proc(t: ^testing.T) {
	a := shape.glass_sphere()
	at := transforms.get_scale_matrix(2, 2, 2)
	shape.set_transform(&a, at)

	b := shape.glass_sphere()
	b.material.refractive_index = 2.0
	bt := transforms.get_translation_matrix(0, 0, -0.25)
	shape.set_transform(&b, bt)

	c := shape.glass_sphere()
	c.material.refractive_index = 2.5
	ct := transforms.get_translation_matrix(0, 0, 0.25)
	shape.set_transform(&c, ct)

	r := rays.create_ray(tuples.point(0, 0, -4), tuples.vector(0, 0, 1))
	
	i1 := intersection.intersection(2, a)
	i2 := intersection.intersection(2.75, b)
	i3 := intersection.intersection(3.25, c)
	i4 := intersection.intersection(4.75, b)
	i5 := intersection.intersection(5.25, c)
	i6 := intersection.intersection(6, a)

	xs := intersection.aggregate_intersections(i1, i2, i3, i4, i5, i6)
	defer delete(xs)

	n1s := [6]f64{1.0, 1.5, 2.0, 2.5, 2.5, 1.5}
	n2s := [6]f64{1.5, 2.0, 2.5, 2.5, 1.5, 1.0}

	for i := 0; i < 6; i += 1 {
		comps := intersection.prepare_computation(&xs[i], &r, &xs)
		testing.expectf(t, utils.fp_equals(comps.n1, n1s[i]), "Incorrect n1 value at index %d. Got %f, Expected %f", i, comps.n1, n1s[i])
		testing.expectf(t, utils.fp_equals(comps.n2, n2s[i]), "Incorrect n2 value at index %d. Got %f, Expected %f", i, comps.n2, n2s[i])
	}
}

@(test)
under_point :: proc(t: ^testing.T) {
	r := rays.create_ray(tuples.point(0, 0, -5), tuples.vector(0, 0, 1))
	s := shape.glass_sphere()
	st := transforms.get_translation_matrix(0, 0, 1)
	shape.set_transform(&s, st)

	i := intersection.intersection(5, s)
	xs := intersection.aggregate_intersections(i)
	defer delete(xs)

	comps := intersection.prepare_computation(&i, &r, &xs)

	testing.expectf(t, comps.under_point.z > utils.EPS / 2, "Under point is not correct. Got %f, Expected %f", comps.under_point.z, utils.EPS / 2)
	testing.expectf(t, comps.point.z < comps.under_point.z, "Under point z is smaller than point z. Under point is %f, point is %f", comps.under_point.z, comps.point.z)
}

@(test)
schlick_approx_with_total_internal_reflection :: proc(t: ^testing.T) {
	s := shape.glass_sphere()
	r := rays.create_ray(tuples.point(0, 0, math.sqrt_f64(2)/2), tuples.vector(0, 1, 0))

	i1 := intersection.intersection(-math.sqrt_f64(2)/2, s)
	i2 := intersection.intersection(math.sqrt_f64(2)/2, s)
	xs := intersection.aggregate_intersections(i1, i2)
	defer delete(xs)

	comps := intersection.prepare_computation(&xs[1], &r, &xs)
	reflectance := world.schlick(&comps)

	testing.expectf(t, utils.fp_equals(reflectance, 1.0), "Reflectance is incorrect. Got %v, Expected 1.0")
}

@(test)
schlick_perpendicular :: proc(t: ^testing.T) {
	s := shape.glass_sphere()
	r := rays.create_ray(tuples.point(0, 0, 0), tuples.vector(0, 1, 0))

	i1 := intersection.intersection(-1, s)
	i2 := intersection.intersection(1, s)
	xs := intersection.aggregate_intersections(i1, i2)
	defer delete(xs)

	comps := intersection.prepare_computation(&xs[1], &r, &xs)
	reflectance := world.schlick(&comps)

	testing.expectf(t, utils.fp_equals(reflectance, 0.04), "Reflectance is incorrect. Got %v, Expected 0.04")
}

@(test)
schlick_small_angle :: proc(t: ^testing.T) {
	s := shape.glass_sphere()
	r := rays.create_ray(tuples.point(0, 0.99, -2), tuples.vector(0, 0, 1))

	i1 := intersection.intersection(1.8589, s)
	xs := intersection.aggregate_intersections(i1)
	defer delete(xs)

	comps := intersection.prepare_computation(&xs[0], &r, &xs)
	reflectance := world.schlick(&comps)

	testing.expectf(t, utils.fp_equals(reflectance, 0.48873), "Reflectance is incorrect. Got %v, Expected 0.48873")
}

@(test)
intersection_uv :: proc(t: ^testing.T) {
	s := shape.triangle_shape(tuples.point(0, 1, 0), tuples.point(-1, 0, 0), tuples.point(1, 0, 0))
	i := intersection.intersection_with_uv(3.5, s, 0.2, 0.4)

	testing.expect(t, utils.fp_equals(i.u, 0.2), "Intersection u value is not correct.")
	testing.expect(t, utils.fp_equals(i.v, 0.4), "Intersection v value is not correct.")
}
