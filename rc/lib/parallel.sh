#!/bin/bash

#
# Wrapper for env_parallel.bash

export PARALLEL_IGNORED_NAMES=''
. env_parallel.bash
env_parallel --session
var=not
# var is transferred
env_parallel -S localhost 'echo var is $var' ::: ignored
env_parallel --session
# var is not transferred
env_parallel -S localhost 'echo var is $var' ::: ignored
env_parallel --end-session
# var is transferred again
env_parallel -S localhost 'echo var is $var' ::: ignored
