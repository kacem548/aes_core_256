library ieee;
use ieee.std_logic_1164.all;

use work.aes_pkg.all;

entity addroundkey is
  port (
    s_in   : in  state128_t;
    rkey   : in  state128_t;
    s_out  : out state128_t
  );
end entity;

architecture rtl of addroundkey is
begin
  s_out <= s_in xor rkey;
end architecture;

