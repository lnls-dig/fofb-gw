target = "xilinx"
action = "simulation"
sim_tool = "modelsim"
top_module = "wb_occf_source_tb"
syn_device = "xc7a200t"
fetchto = "../../../ip_cores"

vlog_opt="+incdir+. +incdir+../../../sim +incdir+../../../modules/fabric"

include_dirs = [
    ".",
    "../../../sim",
    "../../../modules/fabric",
    "../../../ip_cores/general-cores/modules/wishbone/wb_lm32/src",
    "../../../ip_cores/general-cores/modules/wishbone/wb_lm32/platform/generic",
    "../../../ip_cores/general-cores/modules/wishbone/wb_spi_bidir",
    "../../../ip_cores/general-cores/modules/wishbone/wb_spi"
]

files = [
    "wb_occf_source_tb.sv",
    "clk_rst.v"
]

modules = {
    "local" : [
        "../../../ip_cores/general-cores",
        "../../../modules/fabric",
    ]
}
