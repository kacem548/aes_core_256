library ieee;
use ieee.std_logic_1164.all;

entity add_round_key is
  port (
    state_in  : in  std_logic_vector(127 downto 0);
    round_key : in  std_logic_vector(127 downto 0);
    state_out : out std_logic_vector(127 downto 0)
  );
end entity add_round_key;

architecture rtl of add_round_key is
begin
  state_out <= state_in xor round_key;
end architecture rtl;

