library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aes_pkg.all;

entity inv_subbytes is
  port (
    state_in  : in  std_logic_vector(127 downto 0);
    state_out : out std_logic_vector(127 downto 0)
  );
end entity inv_subbytes;

architecture rtl of inv_subbytes is
begin
  state_out(127 downto 120) <= inv_sub_byte(state_in(127 downto 120));
  state_out(119 downto 112) <= inv_sub_byte(state_in(119 downto 112));
  state_out(111 downto 104) <= inv_sub_byte(state_in(111 downto 104));
  state_out(103 downto 96)  <= inv_sub_byte(state_in(103 downto 96));
  state_out(95 downto 88)   <= inv_sub_byte(state_in(95 downto 88));
  state_out(87 downto 80)   <= inv_sub_byte(state_in(87 downto 80));
  state_out(79 downto 72)   <= inv_sub_byte(state_in(79 downto 72));
  state_out(71 downto 64)   <= inv_sub_byte(state_in(71 downto 64));
  state_out(63 downto 56)   <= inv_sub_byte(state_in(63 downto 56));
  state_out(55 downto 48)   <= inv_sub_byte(state_in(55 downto 48));
  state_out(47 downto 40)   <= inv_sub_byte(state_in(47 downto 40));
  state_out(39 downto 32)   <= inv_sub_byte(state_in(39 downto 32));
  state_out(31 downto 24)   <= inv_sub_byte(state_in(31 downto 24));
  state_out(23 downto 16)   <= inv_sub_byte(state_in(23 downto 16));
  state_out(15 downto 8)    <= inv_sub_byte(state_in(15 downto 8));
  state_out(7 downto 0)     <= inv_sub_byte(state_in(7 downto 0));
end architecture rtl;

