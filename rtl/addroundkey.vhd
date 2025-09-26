library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_pkg.all;

-- AddRoundKey: XOR state with 128-bit round key
entity addroundkey is
  port(
    state_in  : in  state_t;
    round_key : in  state_t; -- as 16 bytes
    state_out : out state_t
  );
end entity;

architecture rtl of addroundkey is
begin
  gen: for i in 0 to 15 generate
    state_out(i) <= std_logic_vector(unsigned(state_in(i)) xor unsigned(round_key(i)));
  end generate;
end architecture;

