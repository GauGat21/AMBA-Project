
module apb_master (
    input  logic        PCLK,
    input  logic        PRESETn,

    input  logic        transaction,
    input  logic [31:0] addr,
    input  logic        write,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,

    output logic        PSEL,
    output logic        PENABLE,
    output logic [31:0] PADDR,
    output logic        PWRITE,
    output logic [31:0] PWDATA,

    input  logic [31:0] PRDATA,
    input  logic        PREADY,
    input  logic        PSLVERR
);

    typedef enum logic [1:0] {
        IDLE,
        SETUP,
        ACCESS
    } state_t;

    state_t state, nxt_state;

    // Sequential logic
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            state  <= IDLE;
            PADDR  <= '0;
            PWRITE <= 1'b0;
            PWDATA <= '0;
            rdata  <= '0;
        end else begin
            state <= nxt_state;

            // Capture request information in IDLE
            if (state == IDLE && transaction) begin
                PADDR  <= addr;
                PWRITE <= write;
                PWDATA <= wdata;
            end

            // Capture read data when ACCESS completes
            if (state == ACCESS && PREADY && !PWRITE)
                rdata <= PRDATA;
        end
    end

    // Combinational next-state and control logic
    always_comb begin
        nxt_state = state;
        PSEL      = 1'b0;
        PENABLE   = 1'b0;

        case (state)
            IDLE: begin
                if (transaction)
                    nxt_state = SETUP;
            end

            SETUP: begin
                PSEL      = 1'b1;
                PENABLE   = 1'b0;
                nxt_state = ACCESS;
            end

            ACCESS: begin
                PSEL    = 1'b1;
                PENABLE = 1'b1;

                if (PREADY)
                    nxt_state = IDLE;
                else
                    nxt_state = ACCESS;
            end

            default: begin
                nxt_state = IDLE;
            end
        endcase
    end

endmodule
