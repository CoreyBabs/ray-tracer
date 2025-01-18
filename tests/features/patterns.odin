package test_features

import "core:math"
import "core:testing"
import "src:features/patterns"
import "src:features/shape"
import "src:features/transforms"
import "src:features/tuples"
import utils "src:utilities"

@(test)
stripe_pattern :: proc(t: ^testing.T) {
	pattern := patterns.stripes(tuples.white(), tuples.black())

	testing.expect(t, tuples.color_equals(pattern.a, tuples.white()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(pattern.b, tuples.black()), "Incorrect pattern color.")
}

@(test)
stripe_y :: proc(t: ^testing.T) {
	pattern := patterns.stripes(tuples.white(), tuples.black())

	sa1 := patterns.stripe_at(&pattern, tuples.point(0, 0, 0))
	sa2 := patterns.stripe_at(&pattern, tuples.point(0, 1, 0))
	sa3 := patterns.stripe_at(&pattern, tuples.point(0, 2, 0))

	testing.expect(t, tuples.color_equals(sa1, tuples.white()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(sa2, tuples.white()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(sa3, tuples.white()), "Incorrect pattern color.")
}

@(test)
stripe_z :: proc(t: ^testing.T) {
	pattern := patterns.stripes(tuples.white(), tuples.black())

	sa1 := patterns.stripe_at(&pattern, tuples.point(0, 0, 0))
	sa2 := patterns.stripe_at(&pattern, tuples.point(0, 0, 1))
	sa3 := patterns.stripe_at(&pattern, tuples.point(0, 0, 2))

	testing.expect(t, tuples.color_equals(sa1, tuples.white()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(sa2, tuples.white()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(sa3, tuples.white()), "Incorrect pattern color.")
}

@(test)
stripe_x :: proc(t: ^testing.T) {
	pattern := patterns.stripes(tuples.white(), tuples.black())

	sa1 := patterns.stripe_at(&pattern, tuples.point(0, 0, 0))
	sa2 := patterns.stripe_at(&pattern, tuples.point(0.9, 0, 0))
	sa3 := patterns.stripe_at(&pattern, tuples.point(1, 0, 0))
	sa4 := patterns.stripe_at(&pattern, tuples.point(-0.1, 0, 0))
	sa5 := patterns.stripe_at(&pattern, tuples.point(-1, 0, 0))
	sa6 := patterns.stripe_at(&pattern, tuples.point(-1.1, 0, 0))

	testing.expect(t, tuples.color_equals(sa1, tuples.white()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(sa2, tuples.white()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(sa3, tuples.black()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(sa4, tuples.black()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(sa5, tuples.black()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(sa6, tuples.white()), "Incorrect pattern color.")
}

@(test)
stripe_obj_transform :: proc(t: ^testing.T) {
	obj := shape.default_shape()
	shape.set_transform(&obj, transforms.get_scale_matrix(2, 2, 2))
	pat := patterns.stripes(tuples.white(), tuples.black())
	c := patterns.stripe_at_object(&pat, obj.transform, tuples.point(1.5, 0, 0))

	testing.expect(t, tuples.color_equals(c, tuples.white()), "Incorrect pattern color.")
}

@(test)
stripe_pat_transform :: proc(t: ^testing.T) {
	obj := shape.default_shape()
	pat := patterns.stripes(tuples.white(), tuples.black())
	patterns.set_transform(&pat, transforms.get_scale_matrix(2, 2, 2))
	c := patterns.stripe_at_object(&pat, obj.transform, tuples.point(1.5, 0, 0))

	testing.expect(t, tuples.color_equals(c, tuples.white()), "Incorrect pattern color.")
}

@(test)
stripe_obj_and_pat_transform :: proc(t: ^testing.T) {
	obj := shape.default_shape()
	shape.set_transform(&obj, transforms.get_scale_matrix(2, 2, 2))
	pat := patterns.stripes(tuples.white(), tuples.black())
	patterns.set_transform(&pat, transforms.get_translation_matrix(0.5, 0, 0))
	c := patterns.stripe_at_object(&pat, obj.transform, tuples.point(2.5, 0, 0))

	testing.expect(t, tuples.color_equals(c, tuples.white()), "Incorrect pattern color.")
}
