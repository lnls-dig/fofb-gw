------------------------------------------------------------------------------
-- Title      : OCC FWFT FIFO conversion
-- Project    : Open Communication Controller
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2020-05-20
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Module for converting a standard FIFO into a FWFT (First word
--                fall through) FIFO
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
-- Genrams cores
use work.genram_pkg.all;

entity occf_fwft_fifo is
generic
(
  g_DATA_WIDTH                              : natural := 64;
  g_SIZE                                    : natural := 64;

  g_WITH_RD_EMPTY                           : boolean := true;
  g_WITH_RD_FULL                            : boolean := false;
  g_WITH_RD_ALMOST_EMPTY                    : boolean := false;
  g_WITH_RD_ALMOST_FULL                     : boolean := false;
  g_WITH_RD_COUNT                           : boolean := false;

  g_WITH_WR_EMPTY                           : boolean := false;
  g_WITH_WR_FULL                            : boolean := true;
  g_WITH_WR_ALMOST_EMPTY                    : boolean := false;
  g_WITH_WR_ALMOST_FULL                     : boolean := false;
  g_WITH_WR_COUNT                           : boolean := false;

  g_WITH_FIFO_INFERRED                      : boolean := false;

  g_ALMOST_EMPTY_THRESHOLD                  : integer;
  g_ALMOST_FULL_THRESHOLD                   : integer;
  g_ASYNC                                   : boolean := true
);
port
(
  -- Write clock
  wr_clk_i                                  : in  std_logic;
  wr_rst_n_i                                : in  std_logic;

  wr_data_i                                 : in  std_logic_vector(g_data_width-1 downto 0);
  wr_en_i                                   : in  std_logic;
  wr_full_o                                 : out std_logic;
  wr_count_o                                : out std_logic_vector(f_log2_size(g_size)-1 downto 0);
  wr_almost_empty_o                         : out std_logic;
  wr_almost_full_o                          : out std_logic;

  -- Read clock
  rd_clk_i                                  : in  std_logic;
  rd_rst_n_i                                : in  std_logic;

  rd_data_o                                 : out std_logic_vector(g_data_width-1 downto 0);
  rd_valid_o                                : out std_logic;
  rd_en_i                                   : in  std_logic;
  rd_empty_o                                : out std_logic;
  rd_count_o                                : out std_logic_vector(f_log2_size(g_size)-1 downto 0);
  rd_almost_empty_o                         : out std_logic;
  rd_almost_full_o                          : out std_logic
);
end occf_fwft_fifo;

architecture rtl of occf_fwft_fifo is

  -- Signals
  signal fwft_rd_en                         : std_logic;
  signal fwft_rd_valid                      : std_logic;
  signal fwft_rd_empty                      : std_logic;

  signal fifo_count_int                     : std_logic_vector(f_log2_size(g_size)-1 downto 0);
  signal fifo_almost_empty_int              : std_logic;
  signal fifo_almost_full_int               : std_logic;

begin

  gen_async_fifo : if (g_async) generate
    cmp_fwft_async_fifo : generic_async_fifo
    generic map (
      g_data_width                            => g_DATA_WIDTH,
      g_size                                  => g_SIZE,

      g_with_rd_empty                         => g_WITH_RD_EMPTY,
      g_with_rd_full                          => g_WITH_RD_FULL,
      g_with_rd_almost_empty                  => g_WITH_RD_ALMOST_EMPTY,
      g_with_rd_almost_full                   => g_WITH_RD_ALMOST_FULL,
      g_with_rd_count                         => g_WITH_RD_COUNT,

      g_with_wr_empty                         => g_WITH_WR_EMPTY,
      g_with_wr_full                          => g_WITH_WR_FULL,
      g_with_wr_almost_empty                  => g_WITH_WR_ALMOST_EMPTY,
      g_with_wr_almost_full                   => g_WITH_WR_ALMOST_FULL,
      g_with_wr_count                         => g_WITH_WR_COUNT,

      g_with_fifo_inferred                    => g_WITH_FIFO_INFERRED,

      g_almost_empty_threshold                => g_ALMOST_EMPTY_THRESHOLD,
      g_almost_full_threshold                 => g_ALMOST_FULL_THRESHOLD
    )
    port map(
      rst_n_i                                 => wr_rst_n_i,

      clk_wr_i                                => wr_clk_i,
      d_i                                     => wr_data_i,
      we_i                                    => wr_en_i,
      wr_count_o                              => wr_count_o,
      wr_almost_empty_o                       => wr_almost_empty_o,
      wr_almost_full_o                        => wr_almost_full_o,

      clk_rd_i                                => rd_clk_i,
      q_o                                     => rd_data_o,
      rd_i                                    => fwft_rd_en,
      rd_count_o                              => rd_count_o,
      rd_almost_empty_o                       => rd_almost_empty_o,
      rd_almost_full_o                        => rd_almost_full_o,

      rd_empty_o                              => fwft_rd_empty,
      wr_full_o                               => wr_full_o
    );
  end generate;

  gen_sync_fifo : if (not g_ASYNC) generate
    cmp_fwft_sync_fifo : generic_sync_fifo
    generic map (
      g_data_width                            => g_DATA_WIDTH,
      g_size                                  => g_SIZE,

      g_with_empty                            => g_WITH_RD_EMPTY or g_WITH_WR_EMPTY,
      g_with_full                             => g_WITH_RD_FULL or g_WITH_WR_FULL,
      g_with_almost_empty                     => g_WITH_RD_ALMOST_EMPTY or g_WITH_WR_ALMOST_EMPTY,
      g_with_almost_full                      => g_WITH_RD_ALMOST_FULL or g_WITH_WR_ALMOST_FULL,
      g_with_count                            => g_WITH_RD_COUNT or g_WITH_WR_COUNT,

      g_with_fifo_inferred                    => g_WITH_FIFO_INFERRED,

      g_almost_empty_threshold                => g_ALMOST_EMPTY_THRESHOLD,
      g_almost_full_threshold                 => g_ALMOST_FULL_THRESHOLD
    )
    port map(
      rst_n_i                                 => wr_rst_n_i,

      clk_i                                   => wr_clk_i,
      d_i                                     => wr_data_i,
      we_i                                    => wr_en_i,
      count_o                                 => fifo_count_int,

      q_o                                     => rd_data_o,
      rd_i                                    => fwft_rd_en,

      empty_o                                 => fwft_rd_empty,
      full_o                                  => wr_full_o,

      almost_empty_o                          => fifo_almost_empty_int,
      almost_full_o                           => fifo_almost_full_int
    );

    wr_count_o <= fifo_count_int;
    rd_count_o <= fifo_count_int;

    wr_almost_empty_o <= fifo_almost_empty_int;
    rd_almost_empty_o <= fifo_almost_empty_int;

    wr_almost_full_o <= fifo_almost_full_int;
    rd_almost_full_o <= fifo_almost_full_int;

  end generate;

  -- First Word Fall Through (FWFT) implementation
  fwft_rd_en <= not(fwft_rd_empty) and (not(fwft_rd_valid) or rd_en_i);

  p_fwft_rd_valid : process (rd_clk_i) is
  begin
    if rising_edge(rd_clk_i) then
      if rd_rst_n_i = '0' then
         fwft_rd_valid <= '0';
      else
        if fwft_rd_en = '1' then
           fwft_rd_valid <= '1';
        elsif rd_en_i = '1' then
           fwft_rd_valid <= '0';
        end if;
      end if;
    end if;
  end process;

  -- This is the actual valid flag for this FIFO
  rd_valid_o <= fwft_rd_valid;

  -- Output assignments
  rd_empty_o <= fwft_rd_empty;

end rtl;
