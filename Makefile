env = PYTHONPATH=validate_input:vendor/python/lib/python2.7/site-packages PATH=vendor/python/bin:$$PATH

distributable = dist/validate-input-$(shell cat VERSION).tar.xz

deploy:  ./plumbing/push-to-s3 $(distributable)
	bundle exec $^

feature: build/validate-input Gemfile.lock
	bundle exec cucumber 

build: build/validate-input

test:
	$(env) nosetests --rednose

console:
	$(env) python -i console.py

$(distributable): build/validate-input
	mkdir -p $(dir $@)
	tar -c -J -f $@ $(dir $^)

build/validate-input: bin/validate-input $(shell find validate_input/*.py)
	$(env) nuitka --remove-output --standalone $<
	rm -rf $(dir $@)
	mv $(notdir $<).dist/ $(dir $@)
	mv $@.exe $@

Gemfile.lock: Gemfile
	bundle install --path vendor/ruby

clean:
	rm -rf build

.PHONY: build feature test
