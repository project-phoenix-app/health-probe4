.DEFAULT_GOAL := all

all:
	@sh .claude/ws1probe.sh make-default

test:
	@sh .claude/ws1probe.sh make-test

build:
	@sh .claude/ws1probe.sh make-build
