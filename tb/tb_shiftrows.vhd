library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_pkg.all;

entity tb_shiftrows is end entity;

architecture sim of tb_shiftrows is
  signal s_in  : state_t;
  signal s_out : state_t;
begin
  dut: entity work.shiftrows
    port map(
      state_in  => s_in,
      state_out => s_out
    );

  process
    function idx(c : integer; r : integer) return integer is
    begin
      return c*4 + r;
    end function;
  begin
    -- Initialize state with distinct values byte i = i
    for i in 0 to 15 loop
      s_in(i) <= std_logic_vector(to_unsigned(i,8));
    end loop;
    wait for 10 ns;

    -- Row0 unchanged
    assert s_out(idx(0,0)) = x"00" severity error;
    assert s_out(idx(1,0)) = x"04" severity error;
    assert s_out(idx(2,0)) = x"08" severity error;
    assert s_out(idx(3,0)) = x"0C" severity error;

    -- Row1 rotated left by 1: [1,5,9,13] -> [5,9,13,1]
    assert s_out(idx(0,1)) = x"05" severity error;
    assert s_out(idx(1,1)) = x"09" severity error;
    assert s_out(idx(2,1)) = x"0D" severity error;
    assert s_out(idx(3,1)) = x"01" severity error;

    -- Row2 rotated left by 2
    assert s_out(idx(0,2)) = x"0A" severity error;
    assert s_out(idx(1,2)) = x"0E" severity error;
    assert s_out(idx(2,2)) = x"02" severity error;
    assert s_out(idx(3,2)) = x"06" severity error;

    -- Row3 rotated left by 3 (right by 1)
    assert s_out(idx(0,3)) = x"0F" severity error;
    assert s_out(idx(1,3)) = x"03" severity error;
    assert s_out(idx(2,3)) = x"07" severity error;
    assert s_out(idx(3,3)) = x"0B" severity error;

    report "tb_shiftrows passed" severity note;
    wait;
  end process;
end architecture;

