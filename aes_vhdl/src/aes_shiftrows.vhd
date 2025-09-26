library ieee;
use ieee.std_logic_1164.all;
use work.aes_pkg.all;

entity aes_shiftrows is
  port (
    state_i : in  std_logic_vector(127 downto 0);
    state_o : out std_logic_vector(127 downto 0)
  );
end entity aes_shiftrows;

architecture rtl of aes_shiftrows is
begin
  state_o <= shift_rows(state_i);
end architecture rtl;

