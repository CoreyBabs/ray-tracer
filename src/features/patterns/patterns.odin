package patterns

import "core:math"
import "core:math/linalg"
import "src:features/tuples"
import utils "src:utilities"

PatternType :: enum {
	None,
	Stripe,
	Gradient,
	Ring,
	Checker,
}

Pattern :: struct {
	a: tuples.Color,
	b: tuples.Color,
	transform: matrix[4,4]f64,
	pattern: PatternType,
}

empty_pattern :: proc() -> Pattern {
	return Pattern{tuples.black(), tuples.black(), utils.matrix4_identity(), .None}
}

test_pattern :: proc() -> Pattern {
	return Pattern{tuples.white(), tuples.black(), utils.matrix4_identity(), .None}
}

set_transform :: proc(p: ^Pattern, transform: matrix[4,4]f64) {
	p.transform = transform
}

pattern_equals :: proc(p1, p2: ^Pattern) -> bool {
	return tuples.color_equals(p1.a, p2.a) &&
		tuples.color_equals(p1.b, p2.b) &&
		utils.matrix4_equals_f64(p1.transform, p2.transform) &&
		p1.pattern == p2.pattern
}

is_empty :: proc(p: ^Pattern) -> bool {
	return tuples.color_equals(p.a, p.b)
}

stripes :: proc(a, b: tuples.Color) -> Pattern {
	return Pattern{a, b, utils.matrix4_identity(), .Stripe}
}

gradient :: proc(a, b: tuples.Color) -> Pattern {
	return Pattern{a, b, utils.matrix4_identity(), .Gradient}
}

ring :: proc(a, b: tuples.Color) -> Pattern {
	return Pattern{a, b, utils.matrix4_identity(), .Ring}
}

checker :: proc(a, b: tuples.Color) -> Pattern {
	return Pattern{a, b, utils.matrix4_identity(), .Checker}
}

// The obj param should be a shape, but given the current project setup, this would 
// create a circular dependency so it uses the shapes transform directly instead.
// A downside/bug that results from this is that patterns do not work correctly on groups.
pattern_at_shape :: proc(p: ^Pattern, obj_transform: matrix[4,4]f64, point: tuples.Tuple) -> tuples.Color {
	obj_point := linalg.inverse(obj_transform) * point
	pattern_point := linalg.inverse(p.transform) * obj_point
	return pattern_at(p, pattern_point)
}

pattern_at :: proc(p: ^Pattern, point: tuples.Tuple) -> tuples.Color {
	switch p.pattern {
	case .Stripe:
		return stripe_at(p, point)
	case .Gradient:
		return gradient_at(p, point)
	case .Ring:
		return ring_at(p, point)
	case .Checker:
		return checker_at(p, point)
	case .None:
		return tuples.color(point.x, point.y, point.z)
	case:
		panic("Unknown pattern type.")
	}
}

@(private)
stripe_at :: proc(p: ^Pattern, point: tuples.Tuple) -> tuples.Color {
	if cast(int)(math.floor(point.x)) % 2 == 0 {
		return p.a
	}
	else {
		return p.b
	}
}

@(private)
gradient_at :: proc(p: ^Pattern, point: tuples.Tuple) -> tuples.Color {
	distance := tuples.subtract_colors(p.b, p.a)
	fraction := point.x - math.floor(point.x)
	scaled_distance := tuples.color_scalar_multiply(distance, fraction)
	return tuples.add_colors(p.a, scaled_distance)
}

@(private)
ring_at :: proc(p: ^Pattern, point: tuples.Tuple) -> tuples.Color {
	distance := math.sqrt_f64(math.pow(point.x, 2) + math.pow(point.z, 2))
	di := cast(int)math.floor(distance)
	return di % 2 == 0 ? p.a : p.b
}

@(private)
checker_at :: proc(p: ^Pattern, point: tuples.Tuple) -> tuples.Color {
	sum_dim := math.floor(point.x) + math.floor(point.y) + math.floor(point.z)
	di := cast(int)sum_dim
	return di % 2 == 0 ? p.a : p.b
}
