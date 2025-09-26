library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aes_types_pkg.all;

entity tb_aes256_core is
end entity;

architecture tb of tb_aes256_core is
  constant CLK_PERIOD : time := 10 ns;

  signal clk      : std_logic := '0';
  signal rst_n    : std_logic := '0';
  signal start    : std_logic := '0';
  signal decrypt  : std_logic := '0';
  signal key      : u256 := (others => '0');
  signal din      : u128 := (others => '0');
  signal dout     : u128;
  signal done     : std_logic;

  -- NIST SP 800-38A AES-256 ECB example 1
  constant K256 : u256 := x"603deb1015ca71be2b73aef0857d778" & x"1f352c073b6108d72d9810a30914dff4";
  constant PT   : u128 := x"6bc1bee22e409f96e93d7e117393172a";
  constant CT   : u128 := x"f3eed1bdb5d2a03c064b5a7e3db181f8";

begin
  clk <= not clk after CLK_PERIOD/2;

  uut: entity work.aes256_core
    port map (
      clk      => clk,
      rst_n    => rst_n,
      start    => start,
      decrypt  => decrypt,
      key      => key,
      data_in  => din,
      done     => done,
      data_out => dout
    );

  stim: process
  begin
    rst_n <= '0';
    wait for 5*CLK_PERIOD;
    rst_n <= '1';
    wait for 2*CLK_PERIOD;

    -- Encrypt
    key   <= K256;
    din   <= PT;
    decrypt <= '0';
    start <= '1';
    wait for CLK_PERIOD;
    start <= '0';
    wait until done = '1';
    assert dout = CT report "AES-256 encrypt mismatch" severity failure;

    -- Decrypt
    din   <= CT;
    decrypt <= '1';
    start <= '1';
    wait for CLK_PERIOD;
    start <= '0';
    wait until done = '1';
    assert dout = PT report "AES-256 decrypt mismatch" severity failure;

    report "AES-256 enc/dec tests passed" severity note;
    wait;
  end process;

end architecture;

