library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_pkg.all;

entity tb_subbytes is end entity;

architecture sim of tb_subbytes is
  signal s_in  : state_t := (others => (others => '0'));
  signal s_out : state_t;
begin
  dut: entity work.subbytes
    port map(
      state_in  => s_in,
      state_out => s_out
    );

  process
    variable ok : boolean := true;
  begin
    -- Test a known byte mapping: 0x53 -> 0xED per AES S-box
    s_in <= (others => x"00");
    s_in(0) <= x"53";
    wait for 10 ns;
    assert s_out(0) = x"ED" report "SBox mismatch for 0x53" severity error;

    -- Spot check few bytes
    s_in(0) <= x"00"; wait for 1 ns; assert s_out(0) = x"63" severity error;
    s_in(0) <= x"FF"; wait for 1 ns; assert s_out(0) = x"16" severity error;
    s_in(0) <= x"1B"; wait for 1 ns; assert s_out(0) = x"6E" severity error;

    report "tb_subbytes passed" severity note;
    wait;
  end process;
end architecture;

