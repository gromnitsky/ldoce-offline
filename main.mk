pp-%:
	@echo "$(strip $($*))" | tr ' ' \\n

.DELETE_ON_ERROR:

src := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
