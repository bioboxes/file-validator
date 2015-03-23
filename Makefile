env = PYTHONPATH=validate_input PATH=$$PATH:env/bin

feature: build/validate-input Gemfile.lock
	bundle exec cucumber 

build: build/validate-input

build/validate-input: bin/validate-input $(shell find validate_input/*.py)
	$(env) nuitka --remove-output --standalone $<
	rm -rf $(dir $@)
	mv $(notdir $<).dist/ $(dir $@)
	mv $@.exe $@

Gemfile.lock: Gemfile
	bundle install

clean:
	rm -rf build

.PHONY: build feature
