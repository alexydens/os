# VARIABLES
## Folders
SRC_DIR=src
BUILD_DIR=build

# PATTERN RULES

# FILE TARGETS
## Bootloader
$(BUILD_DIR)/boot.bin: $(SRC_DIR)/boot.asm
	nasm -f bin $< -o $@
## Kernel
$(BUILD_DIR)/kernel.bin: $(SRC_DIR)/kernel.asm
	nasm -f bin $< -o $@

## Main image
$(BUILD_DIR)/main_image.bin: $(BUILD_DIR)/boot.bin $(BUILD_DIR)/kernel.bin
	cat $(BUILD_DIR)/*.bin > $@

# PHONY TARGETS
## List targets
.PHONY: clean test

## Clear build folder
clean:
	rm -rf $(BUILD_DIR)/*

## Build and test with QEMU
test: $(BUILD_DIR)/main_image.bin
	qemu-system-i386 -drive file=$<,if=floppy,index=0,format=raw
