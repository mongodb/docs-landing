GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`
USER=`whoami`
URL="https://docs-mongodborg-staging.corp.mongodb.com"
PRODUCTION_BUCKET=docs-mongodb-org-prod
PREFIX=landing

.PHONY: help stage fake-deploy build

CSS_ERRORS=errors,empty-rules,duplicate-properties,selector-max-approaching
CSS_WARNINGS=regex-selectors,unqualified-attributes,text-indent

help:
	@echo 'Targets'
	@echo '  help         - Show this help message'
	@echo '  build        - Build HTML artifacts for upload'
	@echo '  stage        - Host online for review'
	@echo '  deploy       - Deploy into production'
	@echo ''
	@echo 'Variables'
	@echo '  ARGS         - Arguments to pass to mut-publish'

stage: build
	mut-publish build/ docs-mongodb-org-staging --prefix=${PREFIX} --stage --verbose ${ARGS}
	@echo "Hosted at ${URL}/${PREFIX}/${USER}/${GIT_BRANCH}/index.html"
	@echo "Hosted at ${URL}/${PREFIX}/${USER}/${GIT_BRANCH}/cloud/index.html"
	@echo "Hosted at ${URL}/${PREFIX}/${USER}/${GIT_BRANCH}/tools/index.html"

deploy: build
	mut-publish build ${PRODUCTION_BUCKET} --prefix='/' --deploy --all-subdirectories ${ARGS}

	@echo "Deployed"

build: style.min.css
	# Clean build directory
	rm -rf $@
	# Create output directories
	mkdir -p $@
	mkdir -p $@/cloud
	mkdir -p $@/tools
	mkdir -p $@/evaluate
	@# Copy CSS and JS files to output directories
	cp static/favicon.png $@/favicon.ico
	cp -r static/images static/fonts static/css static/js $@/
	cp -r static/images static/fonts static/css static/js $@/tools
	cp -r static/images static/fonts static/css static/js $@/cloud
	@# Run the script to generate each landing page
	python3 ./gen_landings.py $@

# Don't grab node_modules unless we have to
style.min.css: src/sass/style.scss node_modules/.npm_pulled
	./node_modules/.bin/node-sass src/sass/style.scss | ./node_modules/.bin/cleancss --skip-rebase --semantic-merging -o ./static/css/$@

node_modules/.npm_pulled: package.json
	npm install
	touch node_modules/.npm_pulled
