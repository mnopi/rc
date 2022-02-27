.PHONY: brew color publish release tests

MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
ROOT_DIR := $(patsubst %/,%,$(dir $(MAKEFILE_PATH)))
BASH_ENV := $(ROOT_DIR)/.envrc
export BASH_ENV
SHELL := $(shell bash -c 'command -v bash') -e

brew:
	@brew bundle --quiet --cleanup --no-lock

color:
	@color generate

publish: tests
	@git add .
	@git commit --quiet -a -m "test" || true
	@git push --quiet

release:
	@makeself release

tests:
	@bats.bash --run
