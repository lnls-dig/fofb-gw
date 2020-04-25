-------------------------------------------------------------------------------
-- Title      : Open Communication Controller package
-- Project    : Open Communication Controller
-------------------------------------------------------------------------------
-- Author     : Daniel Tavares
-- Company    : CNPEM LNLS-DIG
-- Created    : 2020-04-24
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Copyright (c) 2020 CNPEM
--
-- This source describes open hardware and is licensed under the CERN-OHL-W v2.
--
-- You may redistribute and modify this documentation and make products using
-- it under the terms of the CERN-OHL-W v2 (https:/cern.ch/cern-ohl), or (at
-- your option) any later version. This documentation is distributed WITHOUT
-- ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY
-- QUALITY AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN-OHL-W v2
-- for applicable conditions.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package occ_pkg is

  constant c_PACKET_WIDTH       : integer := 128;
  constant c_DEVID_WIDTH        : integer := 10;

  type t_packet_header is record
    time_frame_count  : std_logic_vector(15 downto 0);
    time_frame_start  : std_logic;
    reserved          : std_logic_vector(4 downto 0);
    devid             : std_logic_vector(9 downto 0);
  end record;

  type t_packet is record
    header    : t_packet_header;
    datax     : std_logic_vector(31 downto 0);
    datay     : std_logic_vector(31 downto 0);
    timestamp : std_logic_vector(31 downto 0);
  end record t_packet;

end occ_pkg;
