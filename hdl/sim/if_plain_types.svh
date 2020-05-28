//----------------------------------------------------------------------------
// Title      : Simple Packet Types Definitions
// Project    : Open Communication Controller
//----------------------------------------------------------------------------
// Author     : Lucas Maziero Russo
// Company    : CNPEM LNLS-DIG
// Created    : 2020-05-27
// Platform   : FPGA-generic
//-----------------------------------------------------------------------------
// Description: Simple Packet Types DefinitionsSoftware simple packet interface unit for testbenches
//-----------------------------------------------------------------------------
// Copyright (c) 2020 CNPEM
//
// This source describes open hardware and is licensed under the CERN-OHL-W v2.
//
// You may redistribute and modify this documentation and make products using
// it under the terms of the CERN-OHL-W v2 (https:/cern.ch/cern-ohl), or (at
// your option) any later version. This documentation is distributed WITHOUT
// ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY
// QUALITY AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN-OHL-W v2
// for applicable conditions.
//-----------------------------------------------------------------------------

`ifndef __IF_PL_TYPES_SVH
`define __IF_PL_TYPES_SVH

`include "simdrv_defs.svh"

typedef enum
{
    PL_R_OK = 0,
    PL_R_ERROR
} pl_cycle_result_t;

typedef enum {
    PL_WORD = 0,
    PL_BYTE = 1
} pl_address_granularity_t;

typedef struct {
    large_word_t a;
    large_word_t d;
    int size;
    sel_word_t sel;
} pl_xfer_t;

typedef struct  {
    pl_xfer_t data[$];
    pl_cycle_result_t result;
} pl_cycle_t;

typedef enum
{
    PL_RETRY = 0,
    PL_STALL
} pla_sim_event_t;

typedef enum
{
    PL_RANDOM = (1<<0),
    PL_DELAYED = (1<<1)
} pla_sim_behavior_t;

`endif //  `ifndef __IF_PL_TYPES_SVH
