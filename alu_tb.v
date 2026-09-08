`timescale 1ns/1ps

module alu_tb();

    reg  [3:0] a, b;
    reg  [2:0] opcode;
    reg        enable;
    wire [3:0] y;
    wire       carry_out, overflow, zero;

    integer i;
    integer errors = 0;

    alu uut (
        .a(a), .b(b), .opcode(opcode), .enable(enable),
        .y(y), .carry_out(carry_out), .overflow(overflow), .zero(zero)
    );

    // Compares DUT outputs against expected values and reports PASS/FAIL
    task check(input [3:0] exp_y, input exp_c, input exp_ovf, input exp_z);
        begin
            if (y !== exp_y || carry_out !== exp_c || overflow !== exp_ovf || zero !== exp_z) begin
                $display("FAIL @%0t : a=%b b=%b op=%b en=%b -> y=%b C=%b OVF=%b Z=%b (expected y=%b C=%b OVF=%b Z=%b)",
                          $time, a, b, opcode, enable, y, carry_out, overflow, zero,
                          exp_y, exp_c, exp_ovf, exp_z);
                errors = errors + 1;
            end
            else begin
                $display("PASS @%0t : a=%b b=%b op=%b en=%b -> y=%b C=%b OVF=%b Z=%b",
                          $time, a, b, opcode, enable, y, carry_out, overflow, zero);
            end
        end
    endtask

    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(1, alu_tb);

        // enable low -> output must stay at zero regardless of opcode
        enable = 0;
        a = 4'b0101; b = 4'b0011;
        for (i = 0; i < 8; i = i + 1) begin
            opcode = i;
            #10; check(4'b0000, 1'b0, 1'b0, 1'b1);
        end

        // enable high -> full opcode sweep with a=0101 (5), b=0011 (3)
        enable = 1;
        a = 4'b0101; b = 4'b0011;

        opcode = 3'b000; #10; check(4'b1000, 1'b0, 1'b1, 1'b0); // 5+3=8 -> signed overflow (1000 = -8)
        opcode = 3'b001; #10; check(4'b0010, 1'b1, 1'b0, 1'b0); // 5-3=2
        opcode = 3'b010; #10; check(4'b0001, 1'b0, 1'b0, 1'b0); // 0101&0011
        opcode = 3'b011; #10; check(4'b0111, 1'b0, 1'b0, 1'b0); // 0101|0011
        opcode = 3'b100; #10; check(4'b0110, 1'b0, 1'b0, 1'b0); // 0101^0011
        opcode = 3'b101; #10; check(4'b1010, 1'b0, 1'b0, 1'b0); // ~0101
        opcode = 3'b110; #10; check(4'b1010, 1'b0, 1'b0, 1'b0); // 0101<<1
        opcode = 3'b111; #10; check(4'b0010, 1'b0, 1'b0, 1'b0); // 0101>>1

        // Corner cases: unsigned carry-out
        opcode = 3'b000; a = 4'b1111; b = 4'b0001; #10; check(4'b0000, 1'b1, 1'b0, 1'b1);

        // Corner cases: positive overflow (7+1 -> -8 in signed 4-bit)
        opcode = 3'b000; a = 4'b0111; b = 4'b0001; #10; check(4'b1000, 1'b0, 1'b1, 1'b0);

        // Corner cases: negative overflow (-8-1 -> out of signed range)
        opcode = 3'b001; a = 4'b1000; b = 4'b0001; #10; check(4'b0111, 1'b1, 1'b1, 1'b0);

        // Corner cases: zero flag via a XOR a
        opcode = 3'b100; a = 4'b1010; b = 4'b1010; #10; check(4'b0000, 1'b0, 1'b0, 1'b1);

        // Extra subtraction check (5-3=2, no borrow)
        opcode = 3'b001; a = 4'b0101; b = 4'b0011; #10; check(4'b0010, 1'b1, 1'b0, 1'b0);

        if (errors == 0)
            $display("\n*** ALL TESTS PASSED ***");
        else
            $display("\n*** %0d TEST(S) FAILED ***", errors);

        $finish;
    end

endmodule
