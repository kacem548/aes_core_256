library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_pkg.all;

entity tb_keyexpansion is end entity;

architecture sim of tb_keyexpansion is
  signal clk      : std_logic := '0';
  signal rst      : std_logic := '1';
  signal start    : std_logic := '0';
  signal key_low  : state_t;
  signal key_high : state_t;
  signal rk       : state_t;
  signal idx      : unsigned(4 downto 0);
  signal valid    : std_logic;
  signal done     : std_logic;

  constant PERIOD : time := 10 ns;
begin
  clk <= not clk after PERIOD/2;

  dut: entity work.keyexpansion
    port map(
      clk       => clk,
      rst       => rst,
      start     => start,
      key_low   => key_low,
      key_high  => key_high,
      round_key => rk,
      round_idx => idx,
      valid     => valid,
      done      => done
    );

  process
    -- NIST AES-256 test key (from FIPS-197 C.3) for basic sanity; we only check first round key
    constant key256 : std_logic_vector(255 downto 0) :=
      x"000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F";
    -- Expected round 0 key is simply first 128 bits of key: 00010203...0F
    constant exp_rk0 : std_logic_vector(127 downto 0) := x"000102030405060708090A0B0C0D0E0F";
  begin
    -- Reset
    rst <= '1';
    wait for 3*PERIOD;
    rst <= '0';

    -- drive key
    for i in 0 to 15 loop
      key_low(i)  <= key256(255 - i*8 downto 248 - i*8);
      key_high(i) <= key256(127 - i*8 downto 120 - i*8);
    end loop;
    wait for PERIOD;
    start <= '1';
    wait for PERIOD;
    start <= '0';

    wait until valid = '1' and idx = to_unsigned(0,5);
    assert state_to_slv128(rk) = exp_rk0 report "Round 0 key mismatch" severity error;

    wait until done = '1';
    report "tb_keyexpansion basic checks passed" severity note;
    wait;
  end process;
end architecture;

