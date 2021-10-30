
.PHONY: run clean

SRC_FOLDER = ./project
BUILD_FOLDER = ./project/Generated

# Os pacotes tem que ser compilados antes pro compilador não reclamar de coisas não declaradas
CUSTOM_PACKAGES = $(SRC_FOLDER)/unsigned_array.vhd $(SRC_FOLDER)/opcodes.vhd
FILES += $(wildcard $(SRC_FOLDER)/*.vhd)
FILES += $(wildcard $(SRC_FOLDER)/Testbench/*.vhd)
FILES := $(CUSTOM_PACKAGES) $(filter-out $(CUSTOM_PACKAGES), $(FILES))

make:
	@cd $(BUILD_FOLDER) && $(foreach src, $(FILES), \
		echo "$(src)"; \
		ghdl -a --std=08 "$(realpath $(src))"; \
	)

clean:
	@cd $(BUILD_FOLDER) && rm *;

run:
	@cd $(BUILD_FOLDER) && ghdl -e --std=08 $(testbench) && ghdl -r --std=08 $(testbench) --vcd=$(testbench).vcd --ieee-asserts=disable && gtkwave $(testbench).vcd


