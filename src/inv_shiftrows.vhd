library ieee;
use ieee.std_logic_1164.all;

entity inv_shiftrows is
  port (
    state_in  : in  std_logic_vector(127 downto 0);
    state_out : out std_logic_vector(127 downto 0)
  );
end entity inv_shiftrows;

architecture rtl of inv_shiftrows is
  signal s : std_logic_vector(127 downto 0);
begin
  -- Row 0: no shift
  s(127 downto 120) <= state_in(127 downto 120);
  s(95 downto 88)   <= state_in(95 downto 88);
  s(63 downto 56)   <= state_in(63 downto 56);
  s(31 downto 24)   <= state_in(31 downto 24);

  -- Row 1: right shift by 1
  s(119 downto 112) <= state_in(23 downto 16);
  s(87 downto 80)   <= state_in(119 downto 112);
  s(55 downto 48)   <= state_in(87 downto 80);
  s(23 downto 16)   <= state_in(55 downto 48);

  -- Row 2: right shift by 2
  s(111 downto 104) <= state_in(47 downto 40);
  s(79 downto 72)   <= state_in(15 downto 8);
  s(47 downto 40)   <= state_in(111 downto 104);
  s(15 downto 8)    <= state_in(79 downto 72);

  -- Row 3: right shift by 3 (left by 1)
  s(103 downto 96)  <= state_in(71 downto 64);
  s(71 downto 64)   <= state_in(39 downto 32);
  s(39 downto 32)   <= state_in(7 downto 0);
  s(7 downto 0)     <= state_in(103 downto 96);

  state_out <= s;
end architecture rtl;

