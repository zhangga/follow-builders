.PHONY: help update-submodule npm-install setup

help:
	bash ./follow-builders help

update-submodule:
	bash ./follow-builders update-submodule

npm-install:
	bash ./follow-builders npm-install

setup:
	bash ./follow-builders setup
