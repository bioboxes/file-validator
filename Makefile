env = PYTHONPATH=validate_input:env/lib/python2.7/site-packages PATH=env/bin:$$PATH

feature: build/validate-input Gemfile.lock
	bundle exec cucumber 

build: build/validate-input

test:
	$(env) nosetests --rednose

console:
	$(env) python -i console.py

build/validate-input: bin/validate-input $(shell find validate_input/*.py)
	$(env) nuitka --remove-output --standalone $<
	rm -rf $(dir $@)
	mv $(notdir $<).dist/ $(dir $@)
	mv $@.exe $@

Gemfile.lock: Gemfile
	bundle install

clean:
	rm -rf build

.PHONY: build feature test
