env = PYTHONPATH=validate_input:vendor/python/lib/python2.7/site-packages PATH=vendor/python/bin:$$PATH

pwd = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

distributable = dist/validate-input-$(shell cat VERSION).tar.xz


###############################################
#
# Workflow steps
#
###############################################


deploy:  ./plumbing/push-to-s3 $(distributable)
	bundle exec $^

build: build/validate-input
	BINARY='$(realpath $<)' \
	       bundle exec cucumber

feature: Gemfile.lock
	BINARY='$(pwd)/vendor/python/bin/python $(pwd)/bin/validate-input' \
	       bundle exec cucumber

test:
	$(env) nosetests --rednose

console:
	$(env) python -i console.py

bootstrap: Gemfile.lock vendor/python


.PHONY: bootstrap console test feature build deploy

###############################################
#
# Specific targets
#
###############################################


$(distributable): build/validate-input
	mkdir -p $(dir $@)
	tar -c -J -f $@ $(dir $^)

build/validate-input: bin/validate-input $(shell find validate_input/*.py)
	$(env) nuitka --remove-output --standalone $<
	rm -rf $(dir $@)
	mv $(notdir $<).dist/ $(dir $@)
	mv $@.exe $@

vendor/python: requirements.txt
	virtualenv $@
	$@/bin/pip install -r $<


Gemfile.lock: Gemfile
	bundle install --path vendor/ruby

clean:
	rm -rf build
