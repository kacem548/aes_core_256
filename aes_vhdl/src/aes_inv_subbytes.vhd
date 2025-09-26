library ieee;
use ieee.std_logic_1164.all;
use work.aes_pkg.all;

entity aes_inv_subbytes is
  port (
    state_i : in  std_logic_vector(127 downto 0);
    state_o : out std_logic_vector(127 downto 0)
  );
end entity aes_inv_subbytes;

architecture rtl of aes_inv_subbytes is
begin
  state_o <= inv_sub_bytes_128(state_i);
end architecture rtl;

