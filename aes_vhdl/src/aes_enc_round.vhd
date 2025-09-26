library ieee;
use ieee.std_logic_1164.all;
use work.aes_pkg.all;

entity aes_enc_round is
  port (
    state_i      : in  std_logic_vector(127 downto 0);
    rkey_i       : in  std_logic_vector(127 downto 0);
    last_round_i : in  std_logic;
    state_o      : out std_logic_vector(127 downto 0)
  );
end entity aes_enc_round;

architecture rtl of aes_enc_round is
  signal s1, s2, s3 : std_logic_vector(127 downto 0);
begin
  s1 <= sub_bytes_128(state_i);
  s2 <= shift_rows(s1);
  s3 <= mix_columns(s2);
  state_o <= (s2 xor rkey_i) when last_round_i = '1' else (s3 xor rkey_i);
end architecture rtl;

