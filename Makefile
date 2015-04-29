env = PYTHONPATH=validate_input:vendor/python/lib/python2.7/site-packages PATH=vendor/python/bin:$$PATH

pwd = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

distributable = dist/validate-input-$(shell cat VERSION).tar.xz


###############################################
#
# Workflow steps
#
###############################################


deploy: $(distributable)
	bundle exec ./plumbing/push-to-s3 $<
	bundle exec ./plumbing/rebuild-website

build: dist/validate-input
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

dist/validate-input: bin/validate-input $(shell find validate_input/*.py)
	$(env) pyinstaller --specpath pyinstaller --onefile --noconfirm --clean --distpath dist --path .  --additional-hooks-dir=. bin/validate-input
	cp doc/validate-input.mkd $(dir $@)README.mkd

vendor/python: requirements.txt
	virtualenv $@
	$@/bin/pip install -r $<
	touch $@


Gemfile.lock: Gemfile
	bundle install --path vendor/ruby

clean:
	rm -rf build
