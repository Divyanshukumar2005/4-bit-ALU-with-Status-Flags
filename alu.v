module alu (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [2:0] opcode,
    input  wire       enable,
    output reg  [3:0] y,
    output reg         carry_out,
    output reg         overflow,
    output reg         zero
);

    reg [4:0] result_ext;

    always @(*) begin
        carry_out = 1'b0;
        overflow  = 1'b0;
        result_ext = 5'b0;

        if (enable) begin
            case (opcode)
                3'b000: begin
                    result_ext = {1'b0, a} + {1'b0, b};
                    y          = result_ext[3:0];
                    carry_out  = result_ext[4];
                    overflow   = (a[3] == b[3]) && (y[3] != a[3]);
                end

                3'b010: y = a & b;
                3'b011: y = a | b;
                3'b100: y = a ^ b;
                3'b101: y = ~a;
                3'b110: y = a << 1;
                3'b111: y = a >> 1;

                default: y = 4'b0000;
            endcase
        end
        else begin
            y = 4'b0000;
        end

        zero = (y == 4'b0000);
    end

endmodule
