library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_pkg.all;

-- ShiftRows on state array; state is column-major [0..15]
-- Rows are indices by byte index modulo 4; columns are groups of 4
entity shiftrows is
  port(
    state_in  : in  state_t;
    state_out : out state_t
  );
end entity;

architecture rtl of shiftrows is
  function idx(col : integer; row : integer) return integer is
  begin
    return col*4 + row;
  end function;
begin
  -- Row 0 unchanged
  state_out(idx(0,0)) <= state_in(idx(0,0));
  state_out(idx(1,0)) <= state_in(idx(1,0));
  state_out(idx(2,0)) <= state_in(idx(2,0));
  state_out(idx(3,0)) <= state_in(idx(3,0));

  -- Row 1 left rotate by 1
  state_out(idx(0,1)) <= state_in(idx(1,1));
  state_out(idx(1,1)) <= state_in(idx(2,1));
  state_out(idx(2,1)) <= state_in(idx(3,1));
  state_out(idx(3,1)) <= state_in(idx(0,1));

  -- Row 2 left rotate by 2
  state_out(idx(0,2)) <= state_in(idx(2,2));
  state_out(idx(1,2)) <= state_in(idx(3,2));
  state_out(idx(2,2)) <= state_in(idx(0,2));
  state_out(idx(3,2)) <= state_in(idx(1,2));

  -- Row 3 left rotate by 3
  state_out(idx(0,3)) <= state_in(idx(3,3));
  state_out(idx(1,3)) <= state_in(idx(0,3));
  state_out(idx(2,3)) <= state_in(idx(1,3));
  state_out(idx(3,3)) <= state_in(idx(2,3));
end architecture;

