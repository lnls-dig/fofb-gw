files = [
];

if (syn_device[0:4].upper()=="XC7A"): # Family 7 GTP (Artix 7)
    files.extend(["family7-gtp/occ_gtp_phy_family7.vhd",
                  "family7-gtp/occ_gtpe2_tile.vhd",
                  "family7-gtp/gtrxreset_seq.vhd",
                  "family7-gtp/gtrxreset_seq_sim.vhd",
                  "family7-gtp/sync_block.vhd" ]);
