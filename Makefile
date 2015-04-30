env = PYTHONPATH=validate_biobox_file:vendor/python/lib/python2.7/site-packages PATH=vendor/python/bin:$$PATH

pwd = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

image = deb-builder

tool_version   = $(shell cat VERSION)
debian_version = $(shell cat DEBIAN_PACKAGE_VERSION)

distributable = dist/validate-biobox-file.tar.xz
package       = dist/validate-biobox-file.deb

###############################################
#
# Workflow steps
#
###############################################


deploy: VERSION $(distributable)
	bundle exec ./plumbing/push-to-s3 $^
	bundle exec ./plumbing/rebuild-website

package: $(package) $(distributable)

build: build/validate-biobox-file
	BINARY='$(realpath $<)' \
	       bundle exec cucumber

feature: Gemfile.lock
	BINARY='$(pwd)/vendor/python/bin/python $(pwd)/bin/validate-biobox-file' \
	       bundle exec cucumber

test:
	$(env) nosetests --rednose

console:
	$(env) python -i console.py

ssh: $(distributable) .image
	docker run \
		--tty \
		--interactive \
		--volume=$(pwd)/$(dir $<):/src:rw \
		$(image) \
		/bin/bash

bootstrap: Gemfile.lock vendor/python

.PHONY: bootstrap console test feature build deploy ssh


###############################################
#
# Specific targets
#
###############################################

$(package): $(distributable) .image
	docker run \
		--volume=$(pwd)/$(dir $<):/src:rw \
		$(image) $(tool_version) $(debian_version)

.image: images/deb-builder/Dockerfile
	docker build --tag $(image) $(pwd)/$(dir $<)

$(distributable): build/validate-biobox-file
	mkdir -p $(dir $@)
	tar -c -J -f $@ $(dir $^)

build/validate-biobox-file: bin/validate-biobox-file $(shell find validate_biobox_file/*.py)
	$(env) pyinstaller \
	  --workpath pyinstaller/build \
	  --specpath pyinstaller \
	  --onefile \
	  --noconfirm \
	  --clean \
	  --distpath build \
	  --path . \
	  --additional-hooks-dir=$(pwd)/pyinstaller \
	  bin/validate-biobox-file
	cp doc/validate-biobox-file.mkd $(dir $@)README.mkd
	cp VERSION $(dir $@)

vendor/python: requirements.txt
	virtualenv $@
	$@/bin/pip install -r $<
	touch $@


Gemfile.lock: Gemfile
	bundle install --path vendor/ruby

clean:
	rm -rf build
