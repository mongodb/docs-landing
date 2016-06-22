GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`
USER=`whoami`
URL="https://docs-mongodborg-staging.corp.mongodb.com"
PRODUCTION_BUCKET=docs-mongodb-org-prod
PREFIX=landing

.PHONY: help stage fake-deploy build-temp lint

CSS_ERRORS=errors,empty-rules,duplicate-properties,selector-max-approaching
CSS_WARNINGS=regex-selectors,unqualified-attributes,text-indent

help:
	@echo 'Targets'
	@echo '  help         - Show this help message'
	@echo '  lint         - Check the CSS'
	@echo ''
	@echo 'Variables'
	@echo '  ARGS         - Arguments to pass to mut-publish'

build-temp: style.min.css header.js
	rm -rf $@
	mkdir $@
	cp -p landing.html mongodb-logo.png style.min.css header.js *webfont* $@/

# Don't grab node_modules unless we have to
style.min.css: normalize.css style.css header.css
	$(MAKE) node_modules lint
	./node_modules/.bin/cleancss --skip-rebase --semantic-merging -o $@ $^

lint: | node_modules
	./node_modules/.bin/csslint --quiet --format=compact --errors=$(ERRORS) --warnings=$(CSS_WARNINGS) style.css

node_modules:
	npm update
