library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aes_pkg.all;

entity shiftrows is
  port (
    s_in  : in  state128_t;
    s_out : out state128_t
  );
end entity;

architecture rtl of shiftrows is
begin
  process(s_in)
    variable m  : byte_matrix_t;
    variable mo : byte_matrix_t;
  begin
    m := to_matrix(s_in);
    -- Row 0 unchanged
    for c in 0 to 3 loop
      mo(0,c) := m(0,c);
    end loop;
    -- Row 1 left rotate by 1
    mo(1,0) := m(1,1);
    mo(1,1) := m(1,2);
    mo(1,2) := m(1,3);
    mo(1,3) := m(1,0);
    -- Row 2 left rotate by 2
    mo(2,0) := m(2,2);
    mo(2,1) := m(2,3);
    mo(2,2) := m(2,0);
    mo(2,3) := m(2,1);
    -- Row 3 left rotate by 3 (right by 1)
    mo(3,0) := m(3,3);
    mo(3,1) := m(3,0);
    mo(3,2) := m(3,1);
    mo(3,3) := m(3,2);
    s_out <= from_matrix(mo);
  end process;
end architecture;

