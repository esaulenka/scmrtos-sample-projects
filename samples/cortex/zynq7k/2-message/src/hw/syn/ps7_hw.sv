//-------------------------------------------------------------------------------
//
//     Project: Any
//
//     Purpose: PS7 Hardware SV wrapper
//
//-------------------------------------------------------------------------------

`include "cfg_params.svh"


module automatic ps7_hw_m
#(
    parameter DDR_ADDR_W     = 14,
    parameter DDR_BA_W       = 3,
    parameter DDR_DATA_W     = 32,
    parameter DDR_LANE_COUNT = 4,
    parameter MIO_DATA_W     = 54
)
(
    // External ports

    inout  [    DDR_ADDR_W-1:0]  ddr_addr,
    inout  [      DDR_BA_W-1:0]  ddr_ba,
    inout                        ddr_cas_n,
    inout                        ddr_ck_n,
    inout                        ddr_ck_p,
    inout                        ddr_cke,
    inout                        ddr_cs_n,
    inout  [DDR_LANE_COUNT-1:0]  ddr_dm,
    inout  [      DDR_DATA_W:0]  ddr_dq,
    inout  [DDR_LANE_COUNT-1:0]  ddr_dqs_n,
    inout  [DDR_LANE_COUNT-1:0]  ddr_dqs_p,
    inout                        ddr_odt,
    inout                        ddr_ras_n,
    inout                        ddr_reset_n,
    inout                        ddr_we_n,
    
    inout                        ddr_vrn,
    inout                        ddr_vrp,
    
    inout  [    MIO_DATA_W-1:0]  mio,
    inout                        ps_clk,
    inout                        ps_porb,
    inout                        ps_srstb,

    // Internal ports
    output                       fclk0,
    output                       fclk0_rst_n,

    axi3_if.m                    mmr

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
ps7_hw_wrapper ps7_hw_inst
(
    .DDR_addr          ( ddr_addr    ),
    .DDR_ba            ( ddr_ba      ),
    .DDR_cas_n         ( ddr_cas_n   ),
    .DDR_ck_n          ( ddr_ck_n    ),
    .DDR_ck_p          ( ddr_ck_p    ),
    .DDR_cke           ( ddr_cke     ),
    .DDR_cs_n          ( ddr_cs_n    ),
    .DDR_dm            ( ddr_dm      ),
    .DDR_dq            ( ddr_dq      ),
    .DDR_dqs_n         ( ddr_dqs_n   ),
    .DDR_dqs_p         ( ddr_dqs_p   ),
    .DDR_odt           ( ddr_odt     ),
    .DDR_ras_n         ( ddr_ras_n   ),
    .DDR_reset_n       ( ddr_reset_n ),
    .DDR_we_n          ( ddr_we_n    ),
    .FIXED_IO_ddr_vrn  ( ddr_vrn     ),
    .FIXED_IO_ddr_vrp  ( ddr_vrp     ),
    .FIXED_IO_mio      ( mio         ),
    .FIXED_IO_ps_clk   ( ps_clk      ),
    .FIXED_IO_ps_porb  ( ps_porb     ),
    .FIXED_IO_ps_srstb ( ps_srstb    ),
    .FCLK0             ( fclk0       ),
    .FCLK0_RST_N       ( fclk0_rst_n ),
    .MMR_araddr        ( mmr.araddr  ),
    .MMR_arburst       ( mmr.arburst ),
    .MMR_arcache       ( mmr.arcache ),
    .MMR_arid          ( mmr.arid    ),
    .MMR_arlen         ( mmr.arlen   ),
    .MMR_arlock        ( mmr.arlock  ),
    .MMR_arprot        ( mmr.arprot  ),
    .MMR_arqos         ( mmr.arqos   ),
    .MMR_arready       ( mmr.arready ),
    .MMR_arsize        ( mmr.arsize  ),
    .MMR_arvalid       ( mmr.arvalid ),
    .MMR_awaddr        ( mmr.awaddr  ),
    .MMR_awburst       ( mmr.awburst ),
    .MMR_awcache       ( mmr.awcache ),
    .MMR_awid          ( mmr.awid    ),
    .MMR_awlen         ( mmr.awlen   ),
    .MMR_awlock        ( mmr.awlock  ),
    .MMR_awprot        ( mmr.awprot  ),
    .MMR_awqos         ( mmr.awqos   ),
    .MMR_awready       ( mmr.awready ),
    .MMR_awsize        ( mmr.awsize  ),
    .MMR_awvalid       ( mmr.awvalid ),
    .MMR_bid           ( mmr.bid     ),
    .MMR_bready        ( mmr.bready  ),
    .MMR_bresp         ( mmr.bresp   ),
    .MMR_bvalid        ( mmr.bvalid  ),
    .MMR_rdata         ( mmr.rdata   ),
    .MMR_rid           ( mmr.rid     ),
    .MMR_rlast         ( mmr.rlast   ),
    .MMR_rready        ( mmr.rready  ),
    .MMR_rresp         ( mmr.rresp   ),
    .MMR_rvalid        ( mmr.rvalid  ),
    .MMR_wdata         ( mmr.wdata   ),
    .MMR_wid           ( mmr.wid     ),
    .MMR_wlast         ( mmr.wlast   ),
    .MMR_wready        ( mmr.wready  ),
    .MMR_wstrb         ( mmr.wstrb   ),
    .MMR_wvalid        ( mmr.wvalid  )
);
//-------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------

