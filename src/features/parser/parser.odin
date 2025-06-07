package parser

import "core:fmt"
import "core:io"
import "core:os"
import "core:strconv"
import "core:strings"
import "src:features/shape"
import "src:features/tuples"

Parser :: struct {
	vertices: [dynamic]tuples.Tuple,
	normals: [dynamic]tuples.Tuple,
	default_group: ^shape.Shape, // Should always be of ShapeType Group
	groups: map[string]^shape.Shape, // Should always be of ShapeType Group
	ignored: int,
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
	normals := make([dynamic]tuples.Tuple, context.allocator)

	// Vertices are 1 based indexed, so add a fake point at the front
	append(&verts, tuples.point(0, 0, 0))
	append(&normals, tuples.vector(0, 0, 0))

	// Can there be a default group and other groups at the same time
	// or if there is one or more group then are all triangles in group?
	// Should check obj spec to see, this assumes if a group is present then
	// all triangles are in a group.
	g := shape.new_group_shape()
	m := make(map[string]^shape.Shape)
	defer delete(m)
	first_group := true

	for line in strings.split_lines_iterator(&it) {
		l := strings.trim(line, " ")
		vals := strings.split(l, " ")
		defer delete(vals)

		switch vals[0] {
		case "v": 
			parse_vertex(g, &vals, &verts)
		case "f":
			parse_face(g, &vals, &verts, &normals)
		case "vn":
			parse_vertex_normal(g, &vals, &normals)
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
		return Parser{verts, normals , nil, m, ignore}
	}

	return Parser{verts, normals, g, nil, ignore}
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

@(private)
parse_vertex :: proc(g: ^shape.Shape, vals: ^[]string, verts: ^[dynamic]tuples.Tuple) {
	i := 1
	for s := 0; s < len(vals); s += 1 {
		if vals[s] == "" {
			i += 1
		}
	}
	
	x, okx := strconv.parse_f64(vals[i])
	y, oky := strconv.parse_f64(vals[i + 1])
	z, okz := strconv.parse_f64(vals[i + 2])

	if !okx || !oky || !okz {
		fmt.printfln("%v", vals)
		panic("Unexpected vertex value")
	}

	p := tuples.point(x, y, z)
	append(verts, p)
}

@(private)
parse_face :: proc(g: ^shape.Shape, vals: ^[]string, verts: ^[dynamic]tuples.Tuple, normals: ^[dynamic]tuples.Tuple) {
	for i := 2; i < len(vals) - 1; i += 1 {
		f1, n1 := parse_face_value(vals[1])
		f2, n2 := parse_face_value(vals[i])
		f3, n3 := parse_face_value(vals[i + 1])

		if n1 == -1 {
			t := shape.new_triangle_shape(verts[f1], verts[f2], verts[f3])
			shape.add_shape_to_group(g, t)
		}
		else {
			t := shape.new_smooth_triangle_shape(verts[f1], verts[f2], verts[f3], normals[n1], normals[n2], normals[n3])
			shape.add_shape_to_group(g, t)
		}
	}
} 

@(private)
parse_face_value :: proc(val: string) -> (int, int) {
	split := strings.split(val, "/")
	defer delete(split)
	f, ok1 := strconv.parse_int(split[0])
	
	n := -1
	ok2 := true
	if (len(split) == 3) {
		n, ok2 = strconv.parse_int(split[2])
	}

	if !ok1 || !ok2 {
		fmt.println(val)
		panic("Invalid face value")
	}

	return f, n

}

@(private)
parse_vertex_normal :: proc(g: ^shape.Shape, vals: ^[]string, normals: ^[dynamic]tuples.Tuple) {
	x, okx := strconv.parse_f64(vals[1])
	y, oky := strconv.parse_f64(vals[2])
	z, okz := strconv.parse_f64(vals[3])

	if !okx || !oky || !okz {
		panic("Unexpected vertex value")
	}

	v := tuples.vector(x, y, z)
	append(normals, v)
}

free_parser :: proc(p: ^Parser) {
	delete(p.vertices)
	delete(p.normals)

	if p.default_group != nil {
		shape.free_shape(p.default_group)
	}

	if p.groups != nil {
		for _, value in p.groups {
			shape.free_shape(value)
		}
	}
}
