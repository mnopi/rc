#!/bin/bash

. ./stack.sh

b() { stack; a; }
stack
b
