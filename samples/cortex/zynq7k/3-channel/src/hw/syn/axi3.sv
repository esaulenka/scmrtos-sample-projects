//-------------------------------------------------------------------------------
//
//     Project: Any
//
//     Purpose: AXI3 Interface
//
//-------------------------------------------------------------------------------

interface axi3_if
#(
    parameter ADDR_W = 32,
    parameter DATA_W = 32,
    parameter ID_W   = 12
);

localparam LEN_W   = 4;
localparam LOCK_W  = 2;
localparam PROT_W  = 3;
localparam CACHE_W = 4;
localparam BURST_W = 2;
localparam QOS_W   = 4;
localparam SIZE_W  = 3;
localparam RESP_W  = 2;
localparam WSTRB_W = DATA_W/8;

typedef logic [ ADDR_W-1:0] addr_t;
typedef logic [ DATA_W-1:0] data_t;
typedef logic [   ID_W-1:0] id_t;
typedef logic [  LEN_W-1:0] len_t;
typedef logic [ LOCK_W-1:0] lock_t;
typedef logic [PROT_W -1:0] prot_t;
typedef logic [CACHE_W-1:0] cache_t;
typedef logic [BURST_W-1:0] burst_t;
typedef logic [  QOS_W-1:0] qos_t;
typedef logic [ SIZE_W-1:0] size_t;
typedef logic [ RESP_W-1:0] resp_t;
typedef logic [WSTRB_W-1:0] wstrb_t;

//  Write Address Channel
logic        awvalid;
logic        awready;
addr_t       awaddr;
id_t         awid;
len_t        awlen;
burst_t      awburst;
size_t       awsize;
cache_t      awcache;
lock_t       awlock;
prot_t       awprot;
qos_t        awqos;

//  Write Data Channel
logic        wvalid;
logic        wready;
data_t       wdata;
id_t         wid;
logic        wlast;
wstrb_t      wstrb;

//  Write Response Channel
logic        bvalid;
logic        bready;
id_t         bid;
resp_t       bresp;

//  Read Address Channel
logic        arvalid;
logic        arready;
addr_t       araddr;
id_t         arid;
len_t        arlen;
burst_t      arburst;
size_t       arsize;
cache_t      arcache;
lock_t       arlock;
prot_t       arprot;
qos_t        arqos;

//  Read Data Channel
logic        rvalid;
logic        rready;
data_t       rdata;
id_t         rid;
logic        rlast;
resp_t       rresp;

//--------------------------------------------------------------------
modport m
(
    output  awvalid,
    input   awready,
    output  awaddr,
    output  awid,
    output  awlen,
    output  awburst,
    output  awsize,
    output  awcache,
    output  awlock,
    output  awprot,
    output  awqos,

    output  wvalid,
    input   wready,
    output  wdata,
    output  wid,
    output  wlast,
    output  wstrb,

    input   bvalid,
    output  bready,
    input   bid,
    input   bresp,

    output  arvalid,
    input   arready,
    output  araddr,
    output  arid,
    output  arlen,
    output  arburst,
    output  arsize,
    output  arcache,
    output  arlock,
    output  arprot,
    output  arqos,

    input   rvalid,
    output  rready,
    input   rdata,
    input   rid,
    input   rlast,
    input   rresp
);

modport s
(
    input   awvalid,
    output  awready,
    input   awaddr,
    input   awid,
    input   awlen,
    input   awburst,
    input   awsize,
    input   awcache,
    input   awlock,
    input   awprot,
    input   awqos,

    input   wvalid,
    output  wready,
    input   wdata,
    input   wid,
    input   wlast,
    input   wstrb,

    output  bvalid,
    input   bready,
    output  bid,
    output  bresp,

    input   arvalid,
    output  arready,
    input   araddr,
    input   arid,
    input   arlen,
    input   arburst,
    input   arsize,
    input   arcache,
    input   arlock,
    input   arprot,
    input   arqos,

    output  rvalid,
    input   rready,
    output  rdata,
    output  rid,
    output  rlast,
    output  rresp
);

endinterface : axi3_if
//------------------------------------------------------------------------------

