module shapes

import sokol
import sokol.sgl
import math

pub enum FillMode {
	hollow
	filled
}

pub enum DrawMode {
	points lines line_strips tris tri_strips quads
}

pub interface ShapeSpecifier {
	draw_shape()
	// update_shape()
}

pub struct Rect {
	x    f32
	y    f32
	w    f32
	h    f32
	mode FillMode = .hollow
	draw_mode DrawMode = .quads
}

pub struct UnitRectConfig {
	x    f32 = 0.0
	y    f32 = 0.0
	w    f32 = 1.0
	h    f32 = 1.0
	mode FillMode = .hollow
	draw_mode DrawMode = .quads
}

pub fn (r Rect) draw_shape() {
	if r.mode == .hollow {
		r.hollow()
	} else {
		r.filled()
	}
}

pub struct UnitArcConfig {
	x           f32 = 0
	y           f32 = 0
	start_angle f32 = 0
	end_angle   f32 = math.pi
	steps       int = 10
	mode        FillMode = .hollow
	draw_mode   DrawMode = .points
	rings       int = 1
mut:
	init_sgl    bool = true
	a           f32 = 1
	b           f32 = 1
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
	percent f32
	wgc     ShapeConfig
}

pub type Shape = Arc | Rect

pub struct Gauge {
mut:
	gauge   Shape
	percent f32
}

pub fn new_config(percent f32, cfg ShapeConfig) &GaugeConfig {
	return &GaugeConfig{
		percent: percent
		wgc: cfg
	}
}

pub fn new_gauge(cfg GaugeConfig) &Gauge {
	mut gauge := &Shape{}
	match cfg.wgc {
		UnitRectConfig { gauge = new_rect(
				x: cfg.wgc.x
				y: cfg.wgc.y
				w: cfg.wgc.w
				h: cfg.wgc.h
				mode: cfg.wgc.mode
			) }
		UnitArcConfig {
			gauge = new_arc(
				x: cfg.wgc.x
				y: cfg.wgc.y
				start_angle: cfg.wgc.start_angle
				end_angle: cfg.wgc.end_angle
				steps: 10
				a: cfg.wgc.a
				b: cfg.wgc.b
				mode: .filled
				rings: 15
				init_sgl: false
			) }
	}
	return &Gauge{
		gauge: gauge
		percent: cfg.percent
	}
}

pub fn (g Gauge) draw() {
	match g.gauge {
		Rect {
			g.gauge.draw_shape()
			mut new_w := g.gauge.w
			mut new_h := g.gauge.h
			if g.gauge.w > g.gauge.h {
				new_w  *= g.percent
			} else {
				new_h *= g.percent
			}
			filled := new_rect(x: g.gauge.x, y: g.gauge.y,
												 w: new_w, h: new_h, mode: .filled)
		  filled.draw_shape()
		}
		Arc {
			g.gauge.draw_shape()
			range := g.gauge.end_angle - g.gauge.start_angle
			completed := range * g.percent
			filled_arc := new_arc(init_sgl: false,
			 											x: g.gauge.x, y: g.gauge.y,
			 											a: g.gauge.a, b: g.gauge.b,
														start_angle: g.gauge.start_angle,
													 	end_angle: completed,
														mode: .filled
														steps: g.gauge.steps * 2, rings: g.gauge.rings )
			filled_arc.draw_shape()
		}
	}
}
