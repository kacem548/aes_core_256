library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_pkg.all;

-- MixColumns on state
entity mixcolumns is
  port(
    state_in  : in  state_t;
    state_out : out state_t
  );
end entity;

architecture rtl of mixcolumns is
  function idx(col : integer; row : integer) return integer is
  begin
    return col*4 + row;
  end function;
begin
  process(state_in)
    variable s : state_t;
    variable t : state_t;
    variable a0,a1,a2,a3 : byte_t;
  begin
    s := state_in;
    for c in 0 to 3 loop
      a0 := s(idx(c,0));
      a1 := s(idx(c,1));
      a2 := s(idx(c,2));
      a3 := s(idx(c,3));
      t(idx(c,0)) := std_logic_vector(
        unsigned(gmul(a0,2)) xor unsigned(gmul(a1,3)) xor unsigned(a2) xor unsigned(a3));
      t(idx(c,1)) := std_logic_vector(
        unsigned(a0) xor unsigned(gmul(a1,2)) xor unsigned(gmul(a2,3)) xor unsigned(a3));
      t(idx(c,2)) := std_logic_vector(
        unsigned(a0) xor unsigned(a1) xor unsigned(gmul(a2,2)) xor unsigned(gmul(a3,3)));
      t(idx(c,3)) := std_logic_vector(
        unsigned(gmul(a0,3)) xor unsigned(a1) xor unsigned(a2) xor unsigned(gmul(a3,2)));
    end loop;
    state_out <= t;
  end process;
end architecture;

