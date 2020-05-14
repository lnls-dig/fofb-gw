target = "xilinx"
action = "simulation"
sim_tool = "modelsim"
top_module = "main"
syn_device = "xc7a200t"
fetchto = "../../../../../../ip_cores"

include_dirs = [ "..","../../../../../../sim" ]

modules = {
    "local" : [
        "..",
        "../../../../../../platform/xilinx/occ_phy",
    ]
}
