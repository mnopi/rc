.PHONY: brew tests publish

BASH_ENV := .envrc
export BASH_ENV
SHELL := $(shell bash -c 'command -v bash') -e

brew:
	@brew bundle --file packages/Brewfile --quiet --cleanup --no-lock
	@brew cleanup

tests:
	@brew bundle --file packages/Brewfile --quiet --no-lock | grep -v "^Using"
	@bats tests --print-output-on-failure  --recursive

publish: tests
	@git add .
	@git commit --quiet -a -m "test" || true
	@git push --quiet
