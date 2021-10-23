
.PHONY: run clean

# Os pacotes tem que ser compilados antes pro compilador não reclamar de coisas não declaradas
CUSTOM_PACKAGES = ./unsigned_array.vhd ./signed_array.vhd ./opcodes.vhd
CUSTOM_PACKAGES += $(wildcard ./*.vhd)
CUSTOM_PACKAGES += $(wildcard ./Testbench/*.vhd)

make:
	@cd ./Generated && $(foreach src, $(CUSTOM_PACKAGES), \
		ghdl -a --std=08 "$(realpath $(src))"; \
	)

clean:
	@cd ./Generated && rm *;

run:
	@cd ./Generated && ghdl -e --std=08 $(testbench) && ghdl -r --std=08 $(testbench) --vcd=$(testbench).vcd --ieee-asserts=disable && gtkwave $(testbench).vcd


