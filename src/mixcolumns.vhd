library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aes_pkg.all;

entity mixcolumns is
  port (
    state_in  : in  std_logic_vector(127 downto 0);
    state_out : out std_logic_vector(127 downto 0)
  );
end entity mixcolumns;

architecture rtl of mixcolumns is
  function mix_col(a0, a1, a2, a3 : byte_t) return std_logic_vector is
    variable r0, r1, r2, r3 : byte_t;
    variable r : std_logic_vector(31 downto 0);
  begin
    r0 := std_logic_vector(unsigned(gmul2(a0)) xor unsigned(gmul3(a1)) xor unsigned(a2) xor unsigned(a3));
    r1 := std_logic_vector(unsigned(a0) xor unsigned(gmul2(a1)) xor unsigned(gmul3(a2)) xor unsigned(a3));
    r2 := std_logic_vector(unsigned(a0) xor unsigned(a1) xor unsigned(gmul2(a2)) xor unsigned(gmul3(a3)));
    r3 := std_logic_vector(unsigned(gmul3(a0)) xor unsigned(a1) xor unsigned(a2) xor unsigned(gmul2(a3)));
    r := r0 & r1 & r2 & r3;
    return r;
  end function;

  function get_byte(v : std_logic_vector(127 downto 0); byte_index : integer) return byte_t is
    variable hi : integer := 127 - (byte_index*8);
    variable lo : integer := hi - 7;
  begin
    return v(hi downto lo);
  end function;

  function set_bytes(b0,b1,b2,b3 : byte_t) return std_logic_vector is
  begin
    return b0 & b1 & b2 & b3;
  end function;

  signal s : std_logic_vector(127 downto 0);
  signal o : std_logic_vector(127 downto 0);
begin
  s <= state_in;

  -- Column 0 (bytes 0,4,8,12 in state when arranged column-major)
  o(127 downto 96) <= mix_col(s(127 downto 120), s(95 downto 88), s(63 downto 56), s(31 downto 24));

  -- Column 1
  o(95 downto 64)  <= mix_col(s(119 downto 112), s(87 downto 80), s(55 downto 48), s(23 downto 16));

  -- Column 2
  o(63 downto 32)  <= mix_col(s(111 downto 104), s(79 downto 72), s(47 downto 40), s(15 downto 8));

  -- Column 3
  o(31 downto 0)   <= mix_col(s(103 downto 96), s(71 downto 64), s(39 downto 32), s(7 downto 0));

  state_out <= o;
end architecture rtl;

