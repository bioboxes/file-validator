env = PYTHONPATH=env/lib/python2.7/site-packages PATH=env/bin


build: build/validate-input

feature:
	$(env) behave --stop

build/validate-input: bin/validate-input
	./env/bin/nuitka --remove-output --standalone $^
	mkdir -p $(dir $@)
	mv $(notdir $<).dist/$(notdir $@).exe $@
