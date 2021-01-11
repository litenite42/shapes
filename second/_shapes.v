module second

import sokol
import sokol.sgl
import math

fn (r Rect) hollow() {
	sgl.begin_line_strip()
	sgl.v2f(r.x, r.y)
	sgl.v2f(r.x + r.w, r.y)
	sgl.v2f(r.x + r.w, r.y + r.h)
	sgl.v2f(r.x, r.y + r.h)
	sgl.v2f(r.x, r.y)
	sgl.end()
}

fn (r Rect) filled() {
	sgl.begin_quads()
	sgl.v2f(r.x, r.y)
	sgl.v2f(r.x + r.w, r.y)
	sgl.v2f(r.x + r.w, r.y + r.h)
	sgl.v2f(r.x, r.y + r.h)
	sgl.end()
}

fn (a Arc) hollow() {
	if a.init_sgl {
		match a.draw_mode {
			.points { sgl.begin_points() }
			else {}
		}
	}
	inc_amt := f32(a.end_angle - a.start_angle) / a.steps
	for curr_ang := a.start_angle; curr_ang <= a.end_angle; curr_ang += inc_amt {
		v_x := f32(a.a * math.cos(curr_ang)) + a.x
		v_y := a.y - f32(a.b * math.sin(curr_ang))
		sgl.v2f(v_x, v_y)
	}
	if a.init_sgl {
		sgl.end()
	}
}

fn (c Arc) clone() &Arc {
	return &Arc{
		x: c.x
		y: c.y
		a: c.a
		b: c.b
		start_angle: c.start_angle
		end_angle: c.end_angle
		steps: c.steps
		init_sgl: c.init_sgl
		rings: c.rings
	}
}

fn (c Arc) filled() {
	match c.draw_mode {
		.points { sgl.begin_points() }
		else {}
	}
	mut temp := c.clone()
	for i_r := c.rings; i_r >= 0; i_r-- {
		temp.a--
		temp.b--
		temp.hollow()
	}
	sgl.end()
}
