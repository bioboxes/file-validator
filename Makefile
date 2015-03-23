env = PYTHONPATH=env/lib/python2.7/site-packages PATH=env/bin

feature: build/validate-input Gemfile.lock
	bundle exec cucumber 

build: build/validate-input

build/validate-input: bin/validate-input
	./env/bin/nuitka --remove-output --standalone $^
	mv $(notdir $<).dist/ $(dir $@)
	mv $@.exe $@

Gemfile.lock: Gemfile
	bundle install

.PHONY: build feature
