OPENSCAD=/usr/bin/openscad-nightly
PART_DIR=stl
PART_QUALITY=50
RENDER_QUALITY=50
ASM_MODULES=$(sort $(shell grep 'module [a-z0-9_]*_assembly' assembly.scad | sed 's/^module //' | sed 's/[^a-z0-9_].*$$//' | sed '1!G;h;$$!d')) fullassembly
PARTS=$(sort $(shell grep 'module [a-z0-9_]*_part' assembly.scad | sed 's/^module //' | sed 's/[^a-z0-9_].*$$//' | sed '1!G;h;$$!d'))
ASM_MD_FILE=docs/assembly.md


main: parts $(ASM_MODULES)

assembly: ${ASM_MODULES}
parts: $(PARTS)

assemblymd:
	@echo "" > $(ASM_MD_FILE)

${PARTS}:
	@echo "Build part: $(subst _part,,$@)"
	@echo "use <../assembly.scad>" > $(PART_DIR)/build_$@.scad
	@echo "$@();" >> $(PART_DIR)/build_$@.scad
	@${OPENSCAD} -D \$$fn=$(PART_QUALITY) $(PART_DIR)/build_$@.scad -o $(PART_DIR)/$(subst _part,,$@).stl
	@rm -f $(PART_DIR)/build_$@.scad

${ASM_MODULES}: assemblymd
	@echo "Render $@"
	@echo "use <../assembly.scad>" > docs/build_$@.scad
	@echo "$@();" >> docs/build_$@.scad
	@${OPENSCAD} -D \$$fn=$(RENDER_QUALITY) docs/build_$@.scad \
		--csglimit=2000000 --imgsize=880,810 --projection=p \
		$(shell grep -A2 'module $@' assembly.scad | head -5 | grep '// *view:' | sed 's/[^]0-9.,-]//g' | sed 's/[]]/,/g' | sed 's/^/--camera=/') \
		-o docs/$@.png > /dev/null 2>&1
	@echo "## $(shell grep -A2 'module $@' assembly.scad | head -5 | grep '// *title:' | sed -n 's/.*title*: \(.*$\\)/\1/p')" >> $(ASM_MD_FILE)
	@echo "![Img](/docs/$@.png)" >> $(ASM_MD_FILE)
	@echo "" >> $(ASM_MD_FILE)
	@rm -f docs/build_$@.scad

