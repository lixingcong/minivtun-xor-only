BIN := minivtun/src/minivtun

PATCH_DIR  := patches
PATCHES    := $(sort $(wildcard $(PATCH_DIR)/*.patch))
PATCHED    := $(sort $(patsubst $(PATCH_DIR)/%.patch, $(PATCH_DIR)/%.patched, $(PATCHES)))

all:$(BIN)

$(BIN):$(PATCHED)
	cd minivtun/src && $(MAKE)
	$(MAKE) remove_patched
	$(MAKE) reset_submodule

# disable parallel build for patching files
# for preventing from producing out of order chunks
.NOTPARALLEL: %.patched
%.patched:%.patch
	@echo "Applying $^"
	@patch -p 1 -d minivtun < $^ && touch $@
	@echo

.PHONY: reset_submodule
reset_submodule:
	git submodule foreach --recursive git reset --hard

.PHONY: remove_patched
remove_patched:
	find . \( -name \*.orig -o -name \*.rej \) -delete
	rm -rf $(PATCHED)

.PHONY: clean
clean:
	$(MAKE) -C minivtun/src clean
	$(MAKE) remove_patched
	$(MAKE) reset_submodule
