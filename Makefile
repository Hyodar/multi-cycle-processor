
.PHONY: run clean

# Os pacotes tem que ser compilados antes pro compilador não reclamar de coisas não declaradas
FILES = ./unsigned_array.vhd ./signed_array.vhd ./opcodes.vhd
FILES += $(wildcard ./*.vhd)
FILES += $(wildcard ./Testbench/*.vhd)

make:
	@cd ./Generated && $(foreach src, $(FILES), \
		ghdl -a --std=08 "$(realpath $(src))"; \
	)

clean:
	@cd ./Generated && rm *;

run:
	@cd ./Generated && ghdl -e --std=08 $(testbench) && ghdl -r --std=08 $(testbench) --vcd=$(testbench).vcd --ieee-asserts=disable && gtkwave $(testbench).vcd


