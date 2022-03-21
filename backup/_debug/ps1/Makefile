
top := $(shell git super)
basename := $(shell git basename)
volume := $(top):/$(basename)

env:
	echo $(volume)

alpine:
	@docker build --tag ps1 . && docker run -it --rm ps1

bash:
	@docker build --build-arg image=bash --tag ps1 . && docker run -it --rm ps1
