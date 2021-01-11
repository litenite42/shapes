module second

import sokol
import sokol.sgl
import math

pub enum FillMode {
	hollow
	filled
}

pub enum DrawMode {
	points
	lines
	line_strips
	tris
	tri_strips
	quads
}

pub interface ShapeSpecifier {
	draw_shape()
	// update_shape()
}

pub struct UnitRectConfig {
	x         f32      = 0.0
	y         f32      = 0.0
	w         f32      = 1.0
	h         f32      = 1.0
	mode      FillMode = .hollow
	draw_mode DrawMode = .quads
}

pub struct Rect {
	x         f32
	y         f32
	w         f32
	h         f32
	mode      FillMode = .hollow
	draw_mode DrawMode = .quads
}

pub fn new_rect(c UnitRectConfig) &Rect {
	return &Rect{
		x: c.x
		y: c.y
		w: c.w
		h: c.h
		mode: c.mode
		draw_mode: c.draw_mode
	}
}

pub fn (r Rect) draw_shape() {
	if r.mode == .hollow {
		r.hollow()
	} else {
		r.filled()
	}
}

pub struct UnitArcConfig {
	x           f32      = 0
	y           f32      = 0
	start_angle f32      = 0
	end_angle   f32      = math.pi
	steps       int      = 10
	mode        FillMode = .hollow
	draw_mode   DrawMode = .points
	rings       int      = 1
mut:
	init_sgl    bool = true
	a           f32  = 1
	b           f32  = 1
}

pub struct Arc {
pub:
	x           f32
	y           f32
	start_angle f32
	end_angle   f32
	steps       int
	rings       int
	mode        FillMode
	draw_mode   DrawMode
mut:
	a           f32
	b           f32
	init_sgl    bool
}

pub fn new_arc(c UnitArcConfig) &Arc {
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
		mode: c.mode
	}
}

pub fn (c Arc) draw_shape() {
	if c.mode == .hollow {
		c.hollow()
	} else {
		c.filled()
	}
}

pub enum GaugeType {
	bar
	arc
}

pub type ShapeConfig = UnitArcConfig | UnitRectConfig

pub struct GaugeConfig {
	percent  f32 = 0.0
	fill_dir FillDirection = .standard
	shape    ShapeConfig
}

pub type Shape = Arc | Rect

pub enum FillDirection {
	standard // should be l->r on horizontal [rect] gauges, bottom -> top for vertical, and start angle -> end angle for arc gauges
	inverted // opposites r->l                       top    -> bottom                end angle   -> start angle
}

pub struct Gauge {
mut:
	gauge    Shape
	percent  f32
	fill_dir FillDirection
}

pub fn new_config(percent f32, fill_dir FillDirection, cfg ShapeConfig) &GaugeConfig {
	return &GaugeConfig{
		percent: percent
		shape: cfg
		fill_dir: fill_dir
	}
}

pub fn new_gauge(cfg GaugeConfig) &Gauge {
	mut gauge := &Shape{}
	match cfg.shape {
		UnitRectConfig { gauge = new_rect(
				x: cfg.shape.x
				y: cfg.shape.y
				w: cfg.shape.w
				h: cfg.shape.h
				mode: cfg.shape.mode
			) }
		UnitArcConfig { gauge = new_arc(
				x: cfg.shape.x
				y: cfg.shape.y
				start_angle: cfg.shape.start_angle
				end_angle: cfg.shape.end_angle
				steps: 10
				a: cfg.shape.a
				b: cfg.shape.b
				mode: .filled
				rings: 15
				init_sgl: false
			) }
	}
	return &Gauge{
		gauge: gauge
		percent: cfg.percent
		fill_dir: cfg.fill_dir
	}
}

fn (g Rect) fill_rect(percent f32, fill_dir FillDirection) &Rect {
	mut new_w := g.w
	mut new_h := g.h
	mut new_x := g.x
	mut new_y := g.y
	if g.w > g.h {
		new_w *= percent
		if fill_dir == .standard {
			new_x = g.x + g.w - new_w
			new_y = g.y + g.h - new_h
		}
	} else {
		new_h *= percent
		if fill_dir == .standard {
			new_x = g.x + g.w - new_w
			new_y = g.y + g.h - new_h
		}
	}
	return new_rect(
		x: new_x
		y: new_y
		w: new_w
		h: new_h
		mode: .filled
	)
}

pub fn (g Gauge) draw() {
	match g.gauge {
		Rect {
			g.gauge.draw_shape()
			rect := g.gauge.fill_rect(g.percent, g.fill_dir)
			rect.draw_shape()
		}
		Arc {
			g.gauge.draw_shape()
			range := g.gauge.end_angle - g.gauge.start_angle
			completed := range * g.percent
			filled_arc := new_arc(
				init_sgl: false
				x: g.gauge.x
				y: g.gauge.y
				a: g.gauge.a
				b: g.gauge.b
				start_angle: g.gauge.start_angle
				end_angle: completed
				mode: .filled
				steps: g.gauge.steps * 2
				rings: g.gauge.rings
			)
			filled_arc.draw_shape()
		}
	}
}
