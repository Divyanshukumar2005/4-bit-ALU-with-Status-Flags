`timescale 1ns/1ps

module alu_tb();

    reg  [3:0] a, b;
    reg  [2:0] opcode;
    reg        enable;
    wire [3:0] y;
    wire       carry_out, overflow, zero;

    integer i;

    alu uut (
        .a(a), .b(b), .opcode(opcode), .enable(enable),
        .y(y), .carry_out(carry_out), .overflow(overflow), .zero(zero)
    );

    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(1, alu_tb);
        $monitor("Time=%0t | a=%b b=%b op=%b en=%b | y=%b | C=%b OVF=%b Z=%b",
                  $time, a, b, opcode, enable, y, carry_out, overflow, zero);

        enable = 0;
        a = 4'b0101; b = 4'b0011;
        for (i = 0; i < 8; i = i + 1) begin
            opcode = i;
            #10;
        end

        enable = 1;
        a = 4'b0101; b = 4'b0011;
        for (i = 0; i < 8; i = i + 1) begin
            opcode = i;
            #10;
        end

        opcode = 3'b000; a = 4'b1111; b = 4'b0001; #10;

        $finish;
    end

endmodule
