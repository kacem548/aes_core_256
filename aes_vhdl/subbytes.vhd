library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aes_pkg.all;

entity subbytes is
  port (
    s_in  : in  state128_t;
    s_out : out state128_t
  );
end entity;

architecture rtl of subbytes is
begin
  process(s_in)
    variable m  : byte_matrix_t;
    variable mo : byte_matrix_t;
  begin
    m := to_matrix(s_in);
    for c in 0 to 3 loop
      for r in 0 to 3 loop
        mo(r,c) := sbox_lookup(m(r,c));
      end loop;
    end loop;
    s_out <= from_matrix(mo);
  end process;
end architecture;

