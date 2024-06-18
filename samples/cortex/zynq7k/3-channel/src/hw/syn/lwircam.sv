//-------------------------------------------------------------------------------
//
//     Project: Any
//
//     Purpose: Default top-level file
//
//-------------------------------------------------------------------------------

`include "cfg_params.svh"


module automatic lwircam
(
    // External memory, Bank 502
    inout  [    `DDR_ADDR_W-1:0]  ddr_addr,
    inout  [      `DDR_BA_W-1:0]  ddr_ba,
    inout                         ddr_cas_n,
    inout                         ddr_ck_n,
    inout                         ddr_ck_p,
    inout                         ddr_cke,
    inout                         ddr_cs_n,
    inout  [`DDR_LANE_COUNT-1:0]  ddr_dm,
    inout  [      `DDR_DATA_W:0]  ddr_dq,
    inout  [`DDR_LANE_COUNT-1:0]  ddr_dqs_n,
    inout  [`DDR_LANE_COUNT-1:0]  ddr_dqs_p,
    inout                         ddr_odt,
    inout                         ddr_ras_n,
    inout                         ddr_reset_n,
    inout                         ddr_we_n,

    inout                         ddr_vrn,
    inout                         ddr_vrp,


    // Bank 500, 3.3V
    input                         ps_clk,
    inout                         ps_porb,
    
    // Bank 501, 1.8V
    inout  [    `MIO_DATA_W-1:0]  mio,
    inout                         ps_srstb,

    //
    output logic out
);

//------------------------------------------------------------------------------
//
//    Settings
//
    
//------------------------------------------------------------------------------
//
//    Types
//
    
//------------------------------------------------------------------------------
//
//    Objects
//
logic   fclk0;
logic   fclk0_rst_n;
axi3_if mmr();


//------------------------------------------------------------------------------
//
//    ILA debug
//
`ifdef TOP_ENABLE_ILA

(* mark_debug = "true" *) logic [DATA_W-1:0] dbg_out;
(* mark_debug = "true" *) logic              dbg_pll_locked;

assign dbg_out        = out;
assign dbg_pll_locked = pll_locked;

`endif // TOP_DEBUG_ENABLE


//------------------------------------------------------------------------------
//
//    Functions and tasks
//

//------------------------------------------------------------------------------
//
//    Logic
//

//------------------------------------------------------------------------------
//
//    Instances
//
//-------------------------------------------------------------------------------
ps7_hw_m
#(
    .DDR_ADDR_W     ( `DDR_ADDR_W     ),
    .DDR_BA_W       ( `DDR_BA_W       ),
    .DDR_DATA_W     ( `DDR_DATA_W     ),
    .DDR_LANE_COUNT ( `DDR_LANE_COUNT ),
    .MIO_DATA_W     ( `MIO_DATA_W     )

)
ps7_hw
(
    .ddr_addr          ( ddr_addr     ),
    .ddr_ba            ( ddr_ba       ),
    .ddr_cas_n         ( ddr_cas_n    ),
    .ddr_ck_n          ( ddr_ck_n     ),
    .ddr_ck_p          ( ddr_ck_p     ),
    .ddr_cke           ( ddr_cke      ),
    .ddr_cs_n          ( ddr_cs_n     ),
    .ddr_dm            ( ddr_dm       ),
    .ddr_dq            ( ddr_dq       ),
    .ddr_dqs_n         ( ddr_dqs_n    ),
    .ddr_dqs_p         ( ddr_dqs_p    ),
    .ddr_odt           ( ddr_odt      ),
    .ddr_ras_n         ( ddr_ras_n    ),
    .ddr_reset_n       ( ddr_reset_n  ),
    .ddr_we_n          ( ddr_we_n     ),
    .ddr_vrn           ( ddr_vrn      ),
    .ddr_vrp           ( ddr_vrp      ),
    .mio               ( mio          ),
    .ps_clk            ( ps_clk       ),
    .ps_porb           ( ps_porb      ),
    .ps_srstb          ( ps_srstb     ),
    .fclk0             ( fclk0        ),
    .fclk0_rst_n       ( fclk0_rst_n  ),
    .mmr               ( mmr          )

);

//-------------------------------------------------------------------------------
endmodule : lwircam
//-------------------------------------------------------------------------------

