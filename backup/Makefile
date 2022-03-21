.PHONY: brew color debug publish rc release tests

MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
ROOT_DIR := $(patsubst %/,%,$(dir $(MAKEFILE_PATH)))
BASH_ENV := $(ROOT_DIR)/.envrc
export BASH_ENV
SHELL := $(shell bash -c 'command -v bash') -e

NAME := $(shell basename $(ROOT_DIR))

image := alpine

env:
	@echo $(image)

debug:
	# make image=bash debug
	@docker build --build-arg image=$(image) --target debug --tag $(NAME) . && docker run -it -v $(ROOT_DIR):/$(NAME) --rm $(NAME)

# TODO: aqui lo dejo - si hago bash entonces va a el .bashrc y no sale el icono o sea o set -o posix ? o ..
# TODO: en el terminal de aqui s iban las lineas. comprobar en bash en docker y en terminal para ver si es mio o de quien coño
# TODO: y si eso con el iTerm. ! se jode en bash tambié
#    n en Docker!!!!!
rc:
	# make image=bash docker
	@docker build --build-arg image=$(image) --target rc --tag $(NAME) . && docker run -it --name $(NAME) --rm $(NAME)

color:
	@color generate

release:
	@makeself release

tests:
	@bats.bash --run
