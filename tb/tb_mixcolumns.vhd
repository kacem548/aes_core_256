library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_pkg.all;

entity tb_mixcolumns is end entity;

architecture sim of tb_mixcolumns is
  signal s_in  : state_t;
  signal s_out : state_t;
begin
  dut: entity work.mixcolumns
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
    -- Test first column with FIPS-197 example: input [db 13 53 45] -> output [8e 4d a1 bc]
    -- Place it as column 0; other columns zeros
    for i in 0 to 15 loop s_in(i) <= (others => '0'); end loop;
    s_in(idx(0,0)) <= x"db"; s_in(idx(0,1)) <= x"13"; s_in(idx(0,2)) <= x"53"; s_in(idx(0,3)) <= x"45";
    wait for 10 ns;
    assert s_out(idx(0,0)) = x"8e" severity error;
    assert s_out(idx(0,1)) = x"4d" severity error;
    assert s_out(idx(0,2)) = x"a1" severity error;
    assert s_out(idx(0,3)) = x"bc" severity error;

    report "tb_mixcolumns passed" severity note;
    wait;
  end process;
end architecture;

