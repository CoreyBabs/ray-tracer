package test_features

import "core:testing"
import "src:features/intersection"
import "src:features/rays"
import "src:features/shape"
import "src:features/transforms"
import "src:features/tuples"
import utils "src:utilities"

@(test)
create_group :: proc(t: ^testing.T) {
	g := shape.group()
	defer shape.free_group(&g)
	
	testing.expect(t, len(g.shapes) == 0, "Default group is not empty.")
}

// TODO: I am questioning the memory management of this operation. This should be tested further.
@(test)
add_child_to_group :: proc(t: ^testing.T) {
	g := shape.group_shape()
	defer shape.free_group(&g.shape.(shape.Group))

	s := shape.default_shape()

	shape.add_shape_to_group(&g, &s)

	testing.expectf(t, len(g.shape.(shape.Group).shapes) > 0, "Shape was not added to group. Got %v", g)
	testing.expect(t, shape.group_equals(&s.parent.shape.(shape.Group), &g.shape.(shape.Group)), "Shape's parent was not set correctly.")
}

@(test)
ray_intersection_empty_group :: proc(t: ^testing.T) {
	g := shape.group_shape()
	defer shape.free_group(&g.shape.(shape.Group))

	r := rays.create_ray(tuples.point(0, 0, 0), tuples.vector(0, 0, 1))

	xs := intersection.intersect(&g, &r)
	defer delete(xs)

	testing.expect(t, len(xs) == 0, "Intersections found on group when there should not be.")
}

@(test)
ray_intersection_with_group :: proc(t: ^testing.T) {
	g := shape.group_shape()
	defer shape.free_group(&g.shape.(shape.Group))

	s1 := shape.default_shape()
	s2 := shape.default_shape()
	s3 := shape.default_shape()
	shape.set_transform(&s2, transforms.get_translation_matrix(0, 0, -3))
	shape.set_transform(&s3, transforms.get_translation_matrix(5, 0, 0))

	shape.add_shape_to_group(&g, &s1)
	shape.add_shape_to_group(&g, &s2)
	shape.add_shape_to_group(&g, &s3)

	r := rays.create_ray(tuples.point(0, 0, -5), tuples.vector(0, 0, 1))

	xs := intersection.intersect(&g, &r)
	defer delete(xs)

	testing.expectf(t, len(xs) == 4, "Number of intersections in group is incorrect. Expected: %v, Got: %v", 4, len(xs))
	testing.expectf(t, shape.shape_equals(&xs[0].shape, &s2), "First intersection is not correct. Expected: %v, Got: %v", s2, xs[0].shape)
	testing.expectf(t, shape.shape_equals(&xs[1].shape, &s2), "Second intersection is not correct. Expected: %v, Got: %v", s2, xs[1].shape)
	testing.expectf(t, shape.shape_equals(&xs[2].shape, &s1), "Third intersection is not correct. Expected: %v, Got: %v", s1, xs[2].shape)
	testing.expectf(t, shape.shape_equals(&xs[3].shape, &s1), "Fourth intersection is not correct. Expected: %v, Got: %v", s1, xs[3].shape)
}

@(test)
intersecting_transformed_group :: proc(t: ^testing.T) {
	g := shape.group_shape()
	defer shape.free_group(&g.shape.(shape.Group))

	s1 := shape.default_shape()
	shape.set_transform(&s1, transforms.get_translation_matrix(5, 0, 0))
	shape.add_shape_to_group(&g, &s1)

	shape.set_transform(&g, transforms.get_scale_matrix(2, 2, 2))

	r := rays.create_ray(tuples.point(10, 0, -10), tuples.vector(0, 0, 1))

	xs := intersection.intersect(&g, &r)
	defer delete(xs)

	testing.expectf(t, len(xs) == 2, "Expected xs of len 2. Got %v\n of len %v\n%v", xs, len(xs), g)
}
