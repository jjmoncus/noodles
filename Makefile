# h/t to @jimhester and @yihui for this parse block:
# https://github.com/yihui/knitr/blob/dc5ead7bcfc0ebd2789fe99c527c7d91afb3de4a/Makefile#L1-L4
# Note the portability change as suggested in the manual:
# https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Writing-portable-packages


BRANCH := $(shell git rev-parse --symbolic-full-name --abbrev-ref HEAD)

# by default, we'll bump the "build" part of the version, for non-releases
PART = build

# but bump the patch part for releases unless otherwise specified
ifeq ($(PART),build)
release: PART = patch
endif

PKGNAME = `sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION`
PKGVERS = `sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION`

all: check

build: install_deps
	R CMD build .

check: build
	R CMD check --no-manual $(PKGNAME)_$(PKGVERS).tar.gz

install_deps:
	Rscript \
	-e 'if (!requireNamespace("remotes")) install.packages("remotes")' \
	-e 'remotes::install_deps(dependencies = TRUE)'

install: build
	R CMD INSTALL $(PKGNAME)_$(PKGVERS).tar.gz

clean:
	@rm -rf $(PKGNAME)_$(PKGVERS).tar.gz $(PKGNAME).Rcheck

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
