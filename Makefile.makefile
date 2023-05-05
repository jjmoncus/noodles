# Tests, builds, and checks of the package

# This file assumes that the user has bump2version installed:
# https://pypi.org/project/bump2version/

BRANCH := $(shell git rev-parse --symbolic-full-name --abbrev-ref HEAD)

# by default, we'll bump the "build" part of the version, for non-releases
PART = build

# but bump the patch part for releases unless otherwise specified
ifeq ($(PART),build)
release: PART = patch
endif

PKG_DIR := .
PKG_BASENAME := $(shell basename $(dir $(abspath $$PWD)))

all: clean test docs build check

clean:
	-rm -rf $(PKG_BASENAME).Rcheck $(PKG)
	Rscript -e 'roxygen2::roxygenise("$(PKG_DIR)")'

test:
	Rscript -e 'testthat::test_local("$(PKG_DIR)")'

docs: clean
	-rm -rf docs/
	$(eval PKG_VERSION := $(if $(PKG_VERSION),$(PKG_VERSION),$(shell grep -Po '(?<=current_version = )[\d\.]+' .bumpversion.cfg)))
	Rscript -e "pkgdown::build_site()"

build: clean
	R CMD build $(PKG_DIR)

check: build
	$(eval PKG_TAR := $(shell find . -maxdepth 1 -type f -name "$(PKG_BASENAME)_*.tar.gz"))
	R CMD check $(PKG_TAR)

install: build check
	R CMD INSTALL $(PKG_TAR)

.ONESHELL:
bump:
	git checkout $(BRANCH)
	git pull origin $(BRANCH)
	bump2version --commit $(PART)

.ONESHELL:
sync_branch:
	git checkout $(BRANCH)
	git pull origin $(BRANCH)
	git push origin $(BRANCH)

.ONESHELL:
release:
	git checkout $(BRANCH)
	git pull origin $(BRANCH)
	bump2version --commit --tag $(PART)
	git push origin $(BRANCH) --follow-tags

.PHONY: clean bump docs
