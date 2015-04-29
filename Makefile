env = PYTHONPATH=validate_biobox_file:vendor/python/lib/python2.7/site-packages PATH=vendor/python/bin:$$PATH

pwd = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

image = deb-builder

distributable = dist/validate-biobox-file.tar.xz

###############################################
#
# Workflow steps
#
###############################################


deploy: VERSION $(distributable)
	bundle exec ./plumbing/push-to-s3 $^
	bundle exec ./plumbing/rebuild-website

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

bootstrap: Gemfile.lock vendor/python


.PHONY: bootstrap console test feature build deploy


###############################################
#
# Specific targets
#
###############################################


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

vendor/python: requirements.txt
	virtualenv $@
	$@/bin/pip install -r $<
	touch $@


Gemfile.lock: Gemfile
	bundle install --path vendor/ruby

clean:
	rm -rf build
