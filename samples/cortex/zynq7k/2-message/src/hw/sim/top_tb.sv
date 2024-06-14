//-------------------------------------------------------------------------------
//
//     Project: Any
//
//     Purpose: Default testbench file
//
//-------------------------------------------------------------------------------

`include "cfg_params.svh"

`timescale 1ns/1ps

module top_tb;

//------------------------------------------------------------------------------
//
//    Settings
//
localparam CLK_HALF_PERIOD = `REF_CLK_HALF_PERIOD;
    
//------------------------------------------------------------------------------
//
//    Types
//
    
//------------------------------------------------------------------------------
//
//    Objects
//

logic ref_clk;

    
//------------------------------------------------------------------------------
//
//    Logic
//
always begin
    #CLK_HALF_PERIOD
    ref_clk = ~ref_clk;
end



initial begin
    #10us
    $display("\n%c[1;32m ******************** SIMULATION RUN FINISHED SUCCESSFULLY ********************%c[0m", 27, 27);
    $stop(2);   
end 

//------------------------------------------------------------------------------
//
//    Instances
//
lwircam dut
(
    .ddr_addr    ( ddr_addr    ),
    .ddr_ba      ( ddr_ba      ),
    .ddr_cas_n   ( ddr_cas_n   ),
    .ddr_ck_n    ( ddr_ck_n    ),
    .ddr_ck_p    ( ddr_ck_p    ),
    .ddr_cke     ( ddr_cke     ),
    .ddr_cs_n    ( ddr_cs_n    ),
    .ddr_dm      ( ddr_dm      ),
    .ddr_dq      ( ddr_dq      ),
    .ddr_dqs_n   ( ddr_dqs_n   ),
    .ddr_dqs_p   ( ddr_dqs_p   ),
    .ddr_odt     ( ddr_odt     ),
    .ddr_ras_n   ( ddr_ras_n   ),
    .ddr_reset_n ( ddr_reset_n ),
    .ddr_we_n    ( ddr_we_n    ),
    .ddr_vrn     ( ddr_vrn     ),
    .ddr_vrp     ( ddr_vrp     ),
    .ps_clk      ( ref_clk     ),
    .ps_porb     ( ps_porb     ),
    .mio         ( mio         ),
    .ps_srstb    ( ps_srstb    ),
    .out         ( out         )

);

endmodule
//-------------------------------------------------------------------------------

