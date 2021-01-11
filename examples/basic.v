import sokol
import sokol.sapp
import sokol.gfx
import sokol.sgl
import second as shapes
import math

struct AppState {
	pass_action C.sg_pass_action
}

const (
	used_import = sokol.used_import
)

struct Vec2d {
	x f64
	y f64
}

fn main() {
	state := &AppState{
		pass_action: gfx.create_clear_pass(0.1, 0.1, 0.1, 1.0)
	}
	title := 'Sokol Drawing Template'
	desc := C.sapp_desc{
		user_data: state
		init_userdata_cb: init
		frame_userdata_cb: frame
		window_title: title.str
		html5_canvas_name: title.str
	}
	sapp.run(&desc)
}

fn init(user_data voidptr) {
	desc := sapp.create_desc() // C.sg_desc{
	gfx.setup(&desc)
	sgl_desc := C.sgl_desc_t{}
	sgl.setup(&sgl_desc)
}

fn frame(user_data voidptr) {
	// println('frame')
	state := &AppState(user_data)
	draw()
	gfx.begin_default_pass(&state.pass_action, sapp.width(), sapp.height())
	sgl.draw()
	gfx.end_pass()
	gfx.commit()
}

fn draw() {
	// first, reset and setup ortho projection
	sgl.defaults()
	sgl.matrix_mode_projection()
	sgl.ortho(0.0, f32(sapp.width()), f32(sapp.height()), 0.0, -1.0, 1.0)
	mut rect := shapes.new_rect(x: 10, y: 10, w: 100, h: 30)
	rect.draw_shape()
	sgl.c4b(255, 0, 0, 128)
	sgl.c4b(25, 150, 0, 128)
	rect = shapes.new_rect(x: 10, y: 150, w: 80, h: 40, mode: .filled)
	rect.draw_shape()
	mut arc := shapes.new_arc(
		x: 130
		y: 10
		a: 25
		b: 25
		start_angle: f32(0.0)
		end_angle: 2 * math.pi
		steps: 15
	)
	arc.draw_shape()
	arc = shapes.new_arc(
		x: 130
		y: 100
		a: 25
		b: 25
		start_angle: f32(0.0)
		end_angle: 3 * math.pi / 4
		steps: 15
	)
	arc.draw_shape()
	sgl.c4b(255, 0, 0, 255)
	mut test_arc := shapes.new_arc(
		init_sgl: false
		x: 130
		y: 100
		a: 25
		b: 25
		start_angle: f32(0.0)
		end_angle: 3 * math.pi / 2
		steps: 15
		mode: .filled
		rings: 5
	)
	test_arc.draw_shape()
	test_arc = shapes.new_arc(
		init_sgl: false
		x: 230
		y: 150
		a: 35
		b: 55
		start_angle: f32(0.0)
		end_angle: 2 * math.pi
		steps: 25
		mode: .filled
		rings: 15
	)
	test_arc.draw_shape()
	test_arc = shapes.new_arc(
		init_sgl: false
		x: 230
		y: 150
		a: 35
		b: 55
		start_angle: f32(0.0)
		end_angle: math.pi
		steps: 100
		mode: .filled
		rings: 10
	)
	test_arc.draw_shape()
	sgl.c4b(25, 150, 0, 128)
	// line(0, 0, 500, 500)
}
