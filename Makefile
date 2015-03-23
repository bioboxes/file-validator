build: build/validate-input


build/validate-input: bin/validate-input
	./env/bin/nuitka --remove-output --standalone --output-dir=. $^
	mv $(notdir $<).dist $(dir $@)
	mv $@.exe $@
