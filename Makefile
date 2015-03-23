env = PYTHONPATH=env/lib/python2.7/site-packages PATH=env/bin

feature: build/validate-input
	$(env) behave --stop

build: build/validate-input

build/validate-input: bin/validate-input
	./env/bin/nuitka --remove-output --standalone $^
	mkdir -p $(dir $@)
	mv $(notdir $<).dist/$(notdir $@).exe $@

.PHONY: build feature
