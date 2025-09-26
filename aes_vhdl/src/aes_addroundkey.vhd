library ieee;
use ieee.std_logic_1164.all;

entity aes_addroundkey is
  port (
    state_i : in  std_logic_vector(127 downto 0);
    rkey_i  : in  std_logic_vector(127 downto 0);
    state_o : out std_logic_vector(127 downto 0)
  );
end entity aes_addroundkey;

architecture rtl of aes_addroundkey is
begin
  state_o <= state_i xor rkey_i;
end architecture rtl;

