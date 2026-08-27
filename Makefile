SIM = iverilog
FLAGS = -Wall -g2012
TOP = alu_tb
SRC = alu.v alu_tb.v
OUT = alu_sim

all: sim

sim: $(OUT)
	vvp $(OUT)

$(OUT): $(SRC)
	$(SIM) $(FLAGS) -o $(OUT) $(SRC)

wave: sim
	gtkwave alu.vcd

clean:
	rm -f $(OUT) alu.vcd

.PHONY: all sim wave clean
