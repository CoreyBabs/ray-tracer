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

	sa1 := patterns.pattern_at(&pattern, tuples.point(0, 0, 0))
	sa2 := patterns.pattern_at(&pattern, tuples.point(0, 1, 0))
	sa3 := patterns.pattern_at(&pattern, tuples.point(0, 2, 0))

	testing.expect(t, tuples.color_equals(sa1, tuples.white()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(sa2, tuples.white()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(sa3, tuples.white()), "Incorrect pattern color.")
}

@(test)
stripe_z :: proc(t: ^testing.T) {
	pattern := patterns.stripes(tuples.white(), tuples.black())

	sa1 := patterns.pattern_at(&pattern, tuples.point(0, 0, 0))
	sa2 := patterns.pattern_at(&pattern, tuples.point(0, 0, 1))
	sa3 := patterns.pattern_at(&pattern, tuples.point(0, 0, 2))

	testing.expect(t, tuples.color_equals(sa1, tuples.white()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(sa2, tuples.white()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(sa3, tuples.white()), "Incorrect pattern color.")
}

@(test)
stripe_x :: proc(t: ^testing.T) {
	pattern := patterns.stripes(tuples.white(), tuples.black())

	sa1 := patterns.pattern_at(&pattern, tuples.point(0, 0, 0))
	sa2 := patterns.pattern_at(&pattern, tuples.point(0.9, 0, 0))
	sa3 := patterns.pattern_at(&pattern, tuples.point(1, 0, 0))
	sa4 := patterns.pattern_at(&pattern, tuples.point(-0.1, 0, 0))
	sa5 := patterns.pattern_at(&pattern, tuples.point(-1, 0, 0))
	sa6 := patterns.pattern_at(&pattern, tuples.point(-1.1, 0, 0))

	testing.expect(t, tuples.color_equals(sa1, tuples.white()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(sa2, tuples.white()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(sa3, tuples.black()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(sa4, tuples.black()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(sa5, tuples.black()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(sa6, tuples.white()), "Incorrect pattern color.")
}

@(test)
pattern_set_transform :: proc(t: ^testing.T) {
	p := patterns.empty_pattern()
	patterns.set_transform(&p, transforms.get_translation_matrix(1, 2, 3))

	testing.expect(t, utils.matrix4_equals_f64(p.transform, transforms.get_translation_matrix(1, 2, 3)))
}

@(test)
pattern_obj_transform :: proc(t: ^testing.T) {
	obj := shape.default_shape()
	shape.set_transform(&obj, transforms.get_scale_matrix(2, 2, 2))
	pat := patterns.empty_pattern()
	c := patterns.pattern_at_shape(&pat, obj.transform, tuples.point(2, 3, 4))

	testing.expect(t, tuples.color_equals(c, tuples.color(1, 1.5, 2)), "Incorrect pattern color.")
}

@(test)
pattern_pat_transform :: proc(t: ^testing.T) {
	obj := shape.default_shape()
	pat := patterns.empty_pattern()
	patterns.set_transform(&pat, transforms.get_scale_matrix(2, 2, 2))
	c := patterns.pattern_at_shape(&pat, obj.transform, tuples.point(2, 3, 4))

	testing.expect(t, tuples.color_equals(c, tuples.color(1, 1.5, 2)), "Incorrect pattern color.")
}

@(test)
pattern_obj_and_pat_transform :: proc(t: ^testing.T) {
	obj := shape.default_shape()
	shape.set_transform(&obj, transforms.get_scale_matrix(2, 2, 2))
	pat := patterns.empty_pattern()
	patterns.set_transform(&pat, transforms.get_translation_matrix(0.5, 1, 1.5))
	c := patterns.pattern_at_shape(&pat, obj.transform, tuples.point(2.5, 3, 3.5))

	testing.expect(t, tuples.color_equals(c, tuples.color(0.75, 0.5, 0.25)), "Incorrect pattern color.")
}

@(test)
linear_gradient_pattern :: proc(t: ^testing.T) {
	pattern := patterns.gradient(tuples.white(), tuples.black())

	ga1 := patterns.pattern_at(&pattern, tuples.point(0, 0, 0))
	ga2 := patterns.pattern_at(&pattern, tuples.point(0.25, 0, 0))
	ga3 := patterns.pattern_at(&pattern, tuples.point(0.5, 0, 0))
	ga4 := patterns.pattern_at(&pattern, tuples.point(0.75, 0, 0))

	testing.expect(t, tuples.color_equals(ga1, tuples.white()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(ga2, tuples.color(0.75, 0.75, 0.75)), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(ga3, tuples.color(0.5, 0.5, 0.5)), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(ga4, tuples.color(0.25, 0.25, 0.25)), "Incorrect pattern color.")
}

@(test)
ring_pattern :: proc(t: ^testing.T) {
	pattern := patterns.ring(tuples.white(), tuples.black())

	ra1 := patterns.pattern_at(&pattern, tuples.point(0, 0, 0))
	ra2 := patterns.pattern_at(&pattern, tuples.point(1, 0, 0))
	ra3 := patterns.pattern_at(&pattern, tuples.point(0, 0, 1))
	ra4 := patterns.pattern_at(&pattern, tuples.point(0.708, 0, 0.708))

	testing.expectf(t, tuples.color_equals(ra1, tuples.white()), "Incorrect pattern color. Got %v", ra1)
	testing.expect(t, tuples.color_equals(ra2, tuples.black()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(ra3, tuples.black()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(ra4, tuples.black()), "Incorrect pattern color.")
}

@(test)
checker_pattern_x :: proc(t: ^testing.T) {
	pattern := patterns.checker(tuples.white(), tuples.black())

	ca1 := patterns.pattern_at(&pattern, tuples.point(0, 0, 0))
	ca2 := patterns.pattern_at(&pattern, tuples.point(0.99, 0, 0))
	ca3 := patterns.pattern_at(&pattern, tuples.point(1.01, 0, 0))

	testing.expectf(t, tuples.color_equals(ca1, tuples.white()), "Incorrect pattern color. Got %v", ca1)
	testing.expect(t, tuples.color_equals(ca2, tuples.white()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(ca3, tuples.black()), "Incorrect pattern color.")
}

@(test)
checker_pattern_y :: proc(t: ^testing.T) {
	pattern := patterns.checker(tuples.white(), tuples.black())

	ca1 := patterns.pattern_at(&pattern, tuples.point(0, 0, 0))
	ca2 := patterns.pattern_at(&pattern, tuples.point(0, 0.99, 0))
	ca3 := patterns.pattern_at(&pattern, tuples.point(0, 1.01, 0))

	testing.expectf(t, tuples.color_equals(ca1, tuples.white()), "Incorrect pattern color. Got %v", ca1)
	testing.expect(t, tuples.color_equals(ca2, tuples.white()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(ca3, tuples.black()), "Incorrect pattern color.")
}

@(test)
checker_pattern_z :: proc(t: ^testing.T) {
	pattern := patterns.checker(tuples.white(), tuples.black())

	ca1 := patterns.pattern_at(&pattern, tuples.point(0, 0, 0))
	ca2 := patterns.pattern_at(&pattern, tuples.point(0, 0, 0.99))
	ca3 := patterns.pattern_at(&pattern, tuples.point(0, 0, 1.01))

	testing.expectf(t, tuples.color_equals(ca1, tuples.white()), "Incorrect pattern color. Got %v", ca1)
	testing.expect(t, tuples.color_equals(ca2, tuples.white()), "Incorrect pattern color.")
	testing.expect(t, tuples.color_equals(ca3, tuples.black()), "Incorrect pattern color.")
}
