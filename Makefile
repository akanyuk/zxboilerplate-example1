# Имя проекта
PROJECT_NAME = example1

# Перечисление частей, которые должны собираться автоматически
PARTS=part.one part.two part.final

VER = $(shell git log --format="%h" -n 1)

ifeq ($(COPY_SNAPSHOT_TO),)
	COPY_SNAPSHOT_TO = C:\Temp
endif

.PHONY: all build clean clean-% help

all: build

build: $(PARTS:%=build/%.bin.zx7) ## Default: build project
	@printf "\033[32mBuilding '$(PROJECT_NAME)'\033[0m\n"

	rm -f build/*.trd
	rm -f build/*.tap
	rm -f build/*.c
	rm -f build/.bintap-out

	sjasmplus --fullpath --inc=src/. \
		-DSNA_FILENAME=\"build/$(PROJECT_NAME)-$(VER).sna\" \
		-DTRD_FILENAME=\"build/$(PROJECT_NAME).trd\" \
		src/main.asm

	mktap -b "$(PROJECT_NAME)" 1 <src/loader.bas >build/loader.tap
	bintap "build/page0.c" build/0.tap "0" 24576 > build/.bintap-out
	bintap "build/page1.c" build/1.tap "1" 49152 > build/.bintap-out
	bintap "build/page3.c" build/3.tap "3" 49152 > build/.bintap-out
	bintap "build/page4.c" build/4.tap "4" 49152 > build/.bintap-out
	cat build/loader.tap build/1.tap build/3.tap build/4.tap build/0.tap >> build/$(PROJECT_NAME).tap

	cp --force build/$(PROJECT_NAME)-$(VER).sna $(COPY_SNAPSHOT_TO)
	@printf "\033[32mDone\033[0m\n"

build/%.bin.zx7: build/%.bin
	@printf "\033[32mBuilding '$@'\033[0m\n"

	rm -f $@
	zx7 $(subst .zx7,,$@)
	
	@printf "\033[32mdone\033[0m\n\n"

build/%.bin: clean-%
	@printf "\033[32mCompiling '$(patsubst build/%.bin,%,$@)'\033[0m\n"

	@echo $(subst part.,,$@)
	@echo $@
	mkdir -p build

	sjasmplus --fullpath \
		-DSNA_FILENAME=\"$(patsubst %.bin,%,$@)-$(VER).sna\" \
		-DBIN_FILENAME=\"$@\" \
		$(patsubst build/%.bin,%,$@)/main.asm

	cp --force $(patsubst %.bin,%,$@)-$(VER).sna $(COPY_SNAPSHOT_TO)
	@printf "\033[32mdone\033[0m\n\n"

clean-%:
	rm -f build/$(subst clean-,,$@)*

clean: ## Remove all artifacts
	rm -f build/*

help: 	## Display available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-8s\033[0m %s\n", $$1, $$2}' 
