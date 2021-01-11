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
	mut cfg := shapes.new_config(0.4, .standard, shapes.UnitRectConfig{ x: 10, y: 10, w: 15, h: 110 })
	mut gauge := shapes.new_gauge(cfg)
	gauge.draw()
	sgl.c4b(25, 150, 0, 128)
	cfg = shapes.new_config(0.5, .standard, shapes.UnitArcConfig{
		x: 100
		y: 50
		a: 55
		b: 35
		start_angle: 0.0
		end_angle: math.pi / 2
	})
	gauge = shapes.new_gauge(cfg)
	gauge.draw()
	sgl.c4b(25, 150, 0, 128)
	// line(0, 0, 500, 500)
}
