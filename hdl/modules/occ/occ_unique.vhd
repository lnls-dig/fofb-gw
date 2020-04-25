-------------------------------------------------------------------------------
-- Title      : Unique packet forwarding
-- Project    : Open Communication Controller
-------------------------------------------------------------------------------
-- Author     : Daniel Tavares
-- Company    : CNPEM LNLS-DIG
-- Created    : 2020-04-24
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Forwards incoming packets which has not been forwarded before 
--              within the present time frame.
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

library work;
use work.occ_pkg.all;

entity occ_unique is
port
(
  clk_i               : in  std_logic;
  rst_i               : in  std_logic;
  frame_i             : in  std_logic;
  packet_i            : in  t_packet;
  packet_valid_i      : in  std_logic;
  packet_o            : out t_packet;
  packet_valid_o      : out std_logic
);
end occ_unique;

architecture rtl of occ_unique is

  signal forwarded_devices     : std_logic_vector(2**c_DEVID_WIDTH-1 downto 0) := (others => '0');
  signal packet_valid_i_reg   : std_logic;

begin

  -- Check if the packet has been already processed within the present time frame
  p_unique_packet : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if (rst_i = '1') then
          forwarded_devices <= (others => '0');
          packet_valid_i_reg <= '0';
      else
          if (frame_i = '1') then
              forwarded_devices <= (others => '0');
          elsif (packet_valid_i = '1') then
              forwarded_devices(to_integer(unsigned(packet_i.header.devid))) <= '1';
          end if;

          packet_valid_i_reg <= packet_valid_i;
      end if;
    end if;
  end process;

  -- Forward the packet if it has not been forwarded before
  p_forward : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if (rst_i = '1') then
        packet_valid_o <= '0';
      else
        packet_o <= packet_i;
        packet_valid_o <= packet_valid_i_reg and not forwarded_devices(to_integer(unsigned(packet_i.header.devid)));
      end if;
    end if;
  end process;

end rtl;
