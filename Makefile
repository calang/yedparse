# Description

# variable definitions, available to all rules
# REPO_ROOT := $(shell git rev-parse --show-toplevel)  # root directory of this git repo
# BRANCH := $(shell git branch --show-current)
# Notes:
# all env variables are available
# = uses recursive substitution
# :=  uses immediate substitution


# target: help - Display callable targets.
help:
	@echo "Usage:  make <target>"
	@egrep -h "^# target:" [Mm]akefile


# target: test - create local venv
test:
	cd tests; swipl -g run_tests -t halt unit_tests.plt


# ignore files with any of these names
# so that the rules with those as target are always executed
# .PHONY: ALWAYS

# always do/refresh ALWAYS target
# ALWAYS:
