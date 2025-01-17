ARMGNU = aarch64-linux-gnu

board = rpi4b

COPS += -DCONFIG_BOARD_PI4B
QEMU_FLAGS  += -machine raspi4b


COPS += -g -Wall -nostdlib -nostdinc -Iinclude -Idrivers -Ilibcpu -I include/driver
ASMOPS = -g -Iinclude -Idrivers -Ilibcpu -I include/asm

BUILD_DIR = build
SRC_DIRS = src drivers libcpu

all : benos.bin

clean :
	rm -rf $(BUILD_DIR) *.bin

# 自动生成编译目标
C_FILES := $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.c))
ASM_FILES := $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.S))
OBJ_FILES := $(C_FILES:%.c=$(BUILD_DIR)/%_c.o)
OBJ_FILES += $(ASM_FILES:%.S=$(BUILD_DIR)/%_s.o)

# 自动创建构建目录
$(BUILD_DIR)/%_c.o: %.c
	mkdir -p $(@D)
	$(ARMGNU)-gcc $(COPS) -MMD -c $< -o $@ -O0 -g

$(BUILD_DIR)/%_s.o: %.S
	mkdir -p $(@D)
	$(ARMGNU)-gcc $(ASMOPS) -MMD -c $< -o $@ -O0 -g

# 依赖文件处理
DEP_FILES := $(OBJ_FILES:%.o=%.d)
-include $(DEP_FILES)

# 链接生成最终可执行文件
benos.bin: libcpu/link.ld $(OBJ_FILES)
	mkdir -p $(BUILD_DIR)
	$(ARMGNU)-ld -T libcpu/link.ld -o $(BUILD_DIR)/benos.elf $(OBJ_FILES)
	$(ARMGNU)-objcopy $(BUILD_DIR)/benos.elf -O binary benos.bin

# 运行和调试规则
QEMU_FLAGS  += -nographic

run:
	qemu-system-aarch64 $(QEMU_FLAGS) -kernel benos.bin

debug:
	qemu-system-aarch64 $(QEMU_FLAGS) -kernel benos.bin -S -s
