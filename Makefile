
.PHONY: run clean

SRC_FOLDER = ./project
PACKAGES_FOLDER = ./project/Package
BUILD_FOLDER = ./project/Generated

# Os pacotes tem que ser compilados antes pro compilador não reclamar de coisas não declaradas
PACKAGES = $(wildcard $(PACKAGES_FOLDER)/*.vhd)
SOURCES = $(wildcard $(SRC_FOLDER)/*.vhd)
TESTBENCHES = $(wildcard $(SRC_FOLDER)/Testbench/*.vhd)
FILES = $(PACKAGES) $(SOURCES) $(TESTBENCHES)

make:
	@cd $(BUILD_FOLDER) && $(foreach src, $(FILES), \
		echo "$(src)"; \
		ghdl -a --std=08 "$(realpath $(src))"; \
	)
	@cd $(BUILD_FOLDER) && $(foreach testbench, $(TESTBENCHES), \
		echo "$(testbench)"; \
		ghdl -e --std=08 $(basename $(notdir $(testbench))) && ghdl -r --std=08 $(basename $(notdir $(testbench))) --vcd=$(basename $(notdir $(testbench))).vcd --ieee-asserts=disable; \
	)

clean:
	@cd $(BUILD_FOLDER) && rm *;

run:
	@cd $(BUILD_FOLDER) && gtkwave $(testbench).vcd


