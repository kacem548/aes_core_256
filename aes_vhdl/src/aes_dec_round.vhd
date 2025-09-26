library ieee;
use ieee.std_logic_1164.all;
use work.aes_pkg.all;

entity aes_dec_round is
  port (
    state_i      : in  std_logic_vector(127 downto 0);
    rkey_i       : in  std_logic_vector(127 downto 0);
    last_round_i : in  std_logic;
    state_o      : out std_logic_vector(127 downto 0)
  );
end entity aes_dec_round;

architecture rtl of aes_dec_round is
  signal s1, s2 : std_logic_vector(127 downto 0);
begin
  s1 <= inv_shift_rows(inv_sub_bytes_128(state_i));
  s2 <= s1 xor rkey_i;
  state_o <= s2 when last_round_i = '1' else inv_mix_columns(s2);
end architecture rtl;

