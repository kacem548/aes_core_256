library ieee;
use ieee.std_logic_1164.all;

entity shiftrows is
  port (
    state_in  : in  std_logic_vector(127 downto 0);
    state_out : out std_logic_vector(127 downto 0)
  );
end entity shiftrows;

architecture rtl of shiftrows is
  -- State is arranged as 4x4 bytes column-major per AES spec.
  -- Bytes: s[r,c] where r=row(0..3), c=col(0..3)
  -- Mapping helper function to slice bits for s[r,c]
  function idx(r : integer; c : integer) return integer is
  begin
    -- byte index (0..15) in column-major: b = 4*c + r; msb first
    return 15 - (4*c + r);
  end function;

  signal s : std_logic_vector(127 downto 0);
begin
  -- Row 0: no shift
  s(127 downto 120) <= state_in(127 downto 120); -- s[0,0]
  s(95 downto 88)   <= state_in(95 downto 88);   -- s[0,1]
  s(63 downto 56)   <= state_in(63 downto 56);   -- s[0,2]
  s(31 downto 24)   <= state_in(31 downto 24);   -- s[0,3]

  -- Row 1: left shift by 1
  s(119 downto 112) <= state_in(87 downto 80);   -- s[1,1] <= s[1,0]
  s(87 downto 80)   <= state_in(55 downto 48);   -- s[1,2] <= s[1,1]
  s(55 downto 48)   <= state_in(23 downto 16);   -- s[1,3] <= s[1,2]
  s(23 downto 16)   <= state_in(119 downto 112); -- s[1,0] <= s[1,3]

  -- Row 2: left shift by 2
  s(111 downto 104) <= state_in(47 downto 40);   -- s[2,2] <= s[2,0]
  s(79 downto 72)   <= state_in(15 downto 8);    -- s[2,3] <= s[2,1]
  s(47 downto 40)   <= state_in(111 downto 104); -- s[2,0] <= s[2,2]
  s(15 downto 8)    <= state_in(79 downto 72);   -- s[2,1] <= s[2,3]

  -- Row 3: left shift by 3 (right by 1)
  s(103 downto 96)  <= state_in(7 downto 0);     -- s[3,3] <= s[3,0]
  s(71 downto 64)   <= state_in(103 downto 96);  -- s[3,0] <= s[3,1]
  s(39 downto 32)   <= state_in(71 downto 64);   -- s[3,1] <= s[3,2]
  s(7 downto 0)     <= state_in(39 downto 32);   -- s[3,2] <= s[3,3]

  state_out <= s;
end architecture rtl;

