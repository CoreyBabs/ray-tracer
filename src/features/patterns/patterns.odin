package patterns

import "core:math"
import "core:math/linalg"
import "src:features/tuples"
import utils "src:utilities"


Pattern :: struct {
	a: tuples.Color,
	b: tuples.Color,
	transform: matrix[4,4]f64,
}

empty_pattern :: proc() -> Pattern {
	return Pattern{tuples.black(), tuples.black(), utils.matrix4_identity()}
}

set_transform :: proc(p: ^Pattern, transform: matrix[4,4]f64) {
	p.transform = transform
}

is_empty :: proc(p: ^Pattern) -> bool {
	return tuples.color_equals(p.a, p.b)
}

stripes :: proc(a, b: tuples.Color) -> Pattern {
	return Pattern{a, b, utils.matrix4_identity()}
}

stripe_at :: proc(p: ^Pattern, point: tuples.Tuple) -> tuples.Color {
	if cast(int)(math.floor(point.x)) % 2 == 0 {
		return p.a
	}
	else {
		return p.b
	}
}

// The obj param should be a shape, but given the current project setup, this would 
// create a circular dependency so it uses the shapes transform directly instead
stripe_at_object :: proc(p: ^Pattern, obj_transform: matrix[4,4]f64, point: tuples.Tuple) -> tuples.Color {
	obj_point := linalg.inverse(obj_transform) * point
	pattern_point := linalg.inverse(p.transform) * obj_point
	return stripe_at(p, pattern_point)
}
