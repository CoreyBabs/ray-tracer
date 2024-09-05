package side_projects

import "core:fmt"
import "core:io"
import "core:math"
import "core:os"
import "core:strings"
import "src:features/tuples"
import "src:features/canvas"

Projectile :: struct {
	position: tuples.Tuple,
	velocity: tuples.Tuple,
}

Environment :: struct {
	gravity: tuples.Tuple,
	wind: tuples.Tuple,
}

tick :: proc(env: Environment, proj: Projectile) -> Projectile {
	new_position := tuples.add_tuples(proj.position, proj.velocity)
	new_velocity := tuples.add_tuples(proj.velocity, env.gravity)
	new_velocity = tuples.add_tuples(new_velocity, env.wind)
	return Projectile{new_position, new_velocity}
}

run :: proc() {
	position := tuples.point(0, 1, 0)
	velocity := tuples.vector(1, 1.8, 0)
	velocity = tuples.normalize(velocity)
	velocity = tuples.scalar_multiply(velocity, 11.25)

	gravity := tuples.vector(0, -0.1, 0)
	wind := tuples.vector(-0.01, 0, 0)

	c := canvas.canvas(900, 550)
	defer canvas.free_canvas(&c)
	color := tuples.color(255, 0, 0)

	projectile := Projectile{position, velocity} 
	environment := Environment{gravity, wind}

	tick_count := 0
	for projectile.position.y >= 0 {
		projectile = tick(environment, projectile)
		x: int = auto_cast math.round(projectile.position.x)
		y: int = auto_cast math.round(projectile.position.y)
		y = c.height - y
		canvas.write_pixel(&c, x, y, color)
		tick_count += 1
		fmt.printf("After %i ticks, projectile is at %f, %f, %f\n",
			tick_count,
			projectile.position.x,
			projectile.position.y,
			projectile.position.z)
	}

	ppm := canvas.to_ppm(&c)

	result := os.write_entire_file("./images/projectile.ppm", transmute([]u8)ppm)
}

