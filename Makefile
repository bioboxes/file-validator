build: build/validate-input

build/validate-input: bin/validate-input
	./env/bin/nuitka --remove-output --standalone $^
	mkdir -p $(dir $@)
	mv $(notdir $<).dist/$(notdir $@).exe $@
