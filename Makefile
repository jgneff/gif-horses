# ======================================================================
# Makefile - creates bilevel animated GIFs from image sequences
# Copyright (C) 2019 John Neffenger
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# ======================================================================
SHELL = /bin/bash

# Commands
CONVERT = convert
MKBITMAP = mkbitmap
POTRACE = potrace
INKSCAPE = inkscape

# Command options
POTRACE_FLAGS = --backend svg --resolution 90 --turdsize 2
INKSCAPE_FLAGS = --export-width=800

# Bitmap options (defaults: -f 4 -s 2 -3 -t 0.45)
motion_bitmap = --filter 32 --scale 2 --cubic --threshold 0.45
pacing_bitmap = --filter 128 --scale 2 --cubic --threshold 0.45
racing_bitmap = --filter 64 --scale 2 --cubic --threshold 0.50
traced_bitmap = --filter 4 --scale 2 --cubic --threshold 0.45

# Image processing options
monochrome = -layers Flatten -dither None -monochrome -negate
animation = -delay 13 -dispose None -loop 0 -background white
extract = -coalesce -scene 1
threshold = -threshold 60% -negate

# Lists of targets and prerequisites
motion_ppm_list := $(shell echo motion/frame-{02..11}.ppm)
motion_gif_list := $(shell echo motion/frame-{02..11}.gif)
cutoff_gif_list := $(shell echo motion/cutoff-{02..11}.gif)
edge_gif_list := $(shell echo motion/edge-{02..11}.gif)

pacing_ppm_list := $(shell echo pacing/frame-{01..20}.ppm)
pacing_gif_list := $(shell echo pacing/frame-{01..20}.gif)

racing_ppm_list := $(shell echo racing/frame-{01..15}.ppm)
racing_gif_list := $(shell echo racing/frame-{01..15}.gif)

traced_ppm_list := $(shell echo traced/frame-{01..12}.ppm)
traced_gif_list := $(shell echo traced/frame-{01..12}.gif)
traced_pbm_list := $(shell echo traced/frame-{01..12}.pbm)

# ======================================================================
# Pattern Rules
# ======================================================================

motion/%.png: src/%.png
	cp $< $@

motion/%.pbm: motion/%.ppm
	$(MKBITMAP) $(motion_bitmap) --output $@ $<

pacing/%.pbm: pacing/%.ppm
	$(MKBITMAP) $(pacing_bitmap) --output $@ $<

racing/%.pbm: racing/%.ppm
	$(MKBITMAP) $(racing_bitmap) --output $@ $<

traced/%.pbm: traced/%.ppm
	$(CONVERT) $< $(threshold) $@

%.svg: %.pbm
	$(POTRACE) $(POTRACE_FLAGS) --output $@ $<

%.png: %.svg
	$(INKSCAPE) $(INKSCAPE_FLAGS) --export-png=$@ $<

%.gif: %.png
	$(CONVERT) $< $(monochrome) $@

# ======================================================================
# Explicit rules
# ======================================================================

.PHONY: all clean

all: horse-motion.gif horse-motion-cutoff.gif horse-motion-edge.gif \
    horse-pacing.gif horse-racing.gif \
    horse-traced.gif horse-traced-cutoff.gif

$(motion_ppm_list): extracted_motion

$(pacing_ppm_list): extracted_pacing

$(racing_ppm_list): extracted_racing

$(traced_ppm_list): extracted_traced

extracted_motion: src/The_Horse_in_Motion-anim.gif
	$(CONVERT) $^ $(extract) motion/frame-%02d.ppm
	touch $@

extracted_pacing: src/Muybridge_horse_pacing_animated.gif
	$(CONVERT) $^ $(extract) pacing/frame-%02d.ppm
	touch $@

extracted_racing: src/Muybridge_race_horse_animated.gif
	$(CONVERT) $^ $(extract) racing/frame-%02d.ppm
	touch $@

extracted_traced: src/Horse_gif.gif
	$(CONVERT) $^ $(extract) traced/frame-%02d.ppm
	touch $@

horse-motion.gif: $(motion_gif_list)
	$(CONVERT) $(animation) $^ $@

horse-motion-cutoff.gif: $(cutoff_gif_list)
	$(CONVERT) $(animation) $^ $@

horse-motion-edge.gif: $(edge_gif_list)
	$(CONVERT) $(animation) $^ $@

horse-pacing.gif: $(pacing_gif_list)
	$(CONVERT) $(animation) $^ $@

horse-racing.gif: $(racing_gif_list)
	$(CONVERT) $(animation) $^ $@

horse-traced.gif: $(traced_gif_list)
	$(CONVERT) $(animation) $^ $@

horse-traced-cutoff.gif: $(traced_pbm_list)
	$(CONVERT) $(animation) $^ $@

clean:
	rm -f *.gif extracted_*
	rm -f motion/* pacing/* racing/* traced/*
