package parser

import "core:io"
import "core:os"
import "core:strconv"
import "core:strings"
import "src:features/shape"
import "src:features/tuples"

Parser :: struct {
	ignored: int,
	vertices: [dynamic]tuples.Tuple,
	default_group: ^shape.Shape, // Should always be of ShapeType Group
	groups: map[string]^shape.Shape, // Should always be of ShapeType Group
}

parse_obj_file :: proc(file: string) -> Parser {
	data, ok := os.read_entire_file(file, context.allocator)
	if !ok {
		msg := [?]string {"Unable to read file ", file}
		panic(strings.concatenate(msg[:]))
	}

	defer delete(data)

	it := string(data)
	ignore := 0
	verts := make([dynamic]tuples.Tuple, context.allocator)

	// Vertices are 1 based indexed, so add a fake point at the front
	append(&verts, tuples.point(0, 0, 0))

	// Can there be a default group and other groups at the same time
	// or if there is one or more group then are all triangles in group?
	// Should check obj spec to see, this assumes if a group is present then
	// all triangles are in a group.
	g := shape.new_group_shape()
	m := make(map[string]^shape.Shape)
	defer delete(m)
	first_group := true

	for line in strings.split_lines_iterator(&it) {

		vals := strings.split(line, " ")
		defer delete(vals)

		switch vals[0] {
		case "v": {
			x, okx := strconv.parse_f64(vals[1])
			y, oky := strconv.parse_f64(vals[2])
			z, okz := strconv.parse_f64(vals[3])

			if !okx || !oky || !okz {
				panic("Unexpected vertex value")
			}

			p := tuples.point(x, y, z)
			append(&verts, p)
		}
		case "f":
			for i := 2; i < len(vals) - 1; i += 1 {
				f1, ok1 := strconv.parse_int(vals[1])
				f2, ok2 := strconv.parse_int(vals[i])
				f3, ok3 := strconv.parse_int(vals[i + 1])
				
				if !ok1 || !ok2 || !ok3 {
					panic("Unexpected vertex value")
				}

				t := shape.new_triangle_shape(verts[f1], verts[f2], verts[f3])
				shape.add_shape_to_group(g, t)
			}
		case "g":
			if !first_group {
				g = shape.new_group_shape()
			}
			m[vals[1]] = g
			first_group = false
		case:
			ignore += 1
		}
	}

	if len(m) > 0 {
		return Parser{ignore, verts, nil, m}
	}

	return Parser{ignore, verts, g, nil}
}

// Should be freed before the parser object
// That is kind of clunky so maybe this could be handled in a better way?
parser_to_groups :: proc(p: ^Parser) -> [dynamic]^shape.Shape {
	groups := make([dynamic]^shape.Shape)

	if p.default_group != nil {
		append(&groups, p.default_group)
	}

	if p.groups != nil {
		for _, value in p.groups {
			append(&groups, value)
		}
	}

	return groups
}

free_parser :: proc(p: ^Parser) {
	delete(p.vertices)

	if p.default_group != nil {
		shape.free_shape(p.default_group)
	}

	if p.groups != nil {
		for _, value in p.groups {
			shape.free_shape(value)
		}
	}
}
