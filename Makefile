.PHONY : log help

SHELL = /bin/bash

log:help

help: Makefile
	sed -n "s/^##//p" $<