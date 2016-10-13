OPENSCAD=/usr/bin/openscad-nightly
ASM_MODULES=$(sort $(shell grep 'module [a-z0-9_]*_assembly' assembly.scad | sed 's/^module //' | sed 's/[^a-z0-9_].*$$//' | sed '1!G;h;$$!d'))

main: $(ASM_MODULES)

readmemd:
	@echo "# Tybalt Extruder" > readme.md

${ASM_MODULES}: readmemd
	@echo "use <../assembly.scad>" > docs/build_$@.scad
	@echo "$@();" >> docs/build_$@.scad
	@${OPENSCAD} docs/build_$@.scad \
		--csglimit=2000000 --imgsize=880,810 --projection=p \
		$(shell grep -A2 'module $@' assembly.scad | head -5 | grep '// *view:' | sed 's/[^]0-9.,-]//g' | sed 's/[]]/,/g' | sed 's/^/--camera=/') \
		-o docs/$@.png 2<&1
	echo "## $(shell grep -A2 'module $@' assembly.scad | head -5 | grep '// *title:' | sed -n 's/.*title*: \(.*$\\)/\1/p')" >> readme.md
	echo "![Img](/docs/$@.png)" >> readme.md
	echo "" >> readme.md
	@rm -f docs/build_$@.scad
