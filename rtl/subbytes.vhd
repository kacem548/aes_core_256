library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_pkg.all;

-- Byte-wise SubBytes using S-box on state array
entity subbytes is
  port(
    state_in  : in  state_t;
    state_out : out state_t
  );
end entity;

architecture rtl of subbytes is
begin
  gen: for i in 0 to 15 generate
    state_out(i) <= sbox(state_in(i));
  end generate;
end architecture;

