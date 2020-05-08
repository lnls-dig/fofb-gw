target = "xilinx"
action = "simulation"
sim_tool = "modelsim"
top_module = "occ_gtpe2_reset_tb"
syn_device = "xc7a200t"
fetchto = "../../../../../ip_cores"

files = [
    "occ_gtpe2_reset_tb.v",
    "glbl.v",
]

include_dirs = [ "../../../../../sim" ]

modules = {
    "local" : [
        "../../../../..",
    ]
}
