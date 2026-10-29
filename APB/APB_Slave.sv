
module apb_slave (
    input  logic        PCLK,
    input  logic        PRESETn,

    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic [31:0] PADDR,
    input  logic        PWRITE,
    input  logic [31:0] PWDATA,

    output logic [31:0] PRDATA,
    output logic        PREADY,
    output logic        PSLVERR
);

    logic [31:0] regs [0:3];
    logic [1:0]  index;
    logic        valid_addr;

    always_comb begin
        index = PADDR[3:2];

        valid_addr = (PADDR[1:0] == 2'b00) &&
                     (PADDR[31:4] == '0);

        PREADY  = 1'b1;
        PRDATA  = '0;
        PSLVERR = 1'b0;

        if (PSEL && PENABLE) begin
            if (valid_addr)
                PRDATA = regs[index];
            else
                PSLVERR = 1'b1;
        end
    end

    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            regs[0] <= '0;
            regs[1] <= '0;
            regs[2] <= '0;
            regs[3] <= '0;
        end else begin
            if (PSEL && PENABLE && PREADY &&
                PWRITE && valid_addr) begin
                regs[index] <= PWDATA;
            end
        end
    end

endmodule
