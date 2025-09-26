library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_pkg.all;

entity tb_aes256_core is end entity;

architecture sim of tb_aes256_core is
  signal clk        : std_logic := '0';
  signal rst        : std_logic := '1';
  signal start      : std_logic := '0';
  signal pt         : state_t;
  signal key_low    : state_t;
  signal key_high   : state_t;
  signal ct         : state_t;
  signal done       : std_logic;

  constant PERIOD : time := 10 ns;
begin
  clk <= not clk after PERIOD/2;

  dut: entity work.aes256_core
    port map(
      clk        => clk,
      rst        => rst,
      start      => start,
      plaintext  => pt,
      key_low    => key_low,
      key_high   => key_high,
      ciphertext => ct,
      done       => done
    );

  process
    -- FIPS-197 C.3 AES-256 test vector
    constant key256 : std_logic_vector(255 downto 0) :=
      x"000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F";
    constant plain  : std_logic_vector(127 downto 0) := x"00112233445566778899AABBCCDDEEFF";
    constant exp_ct : std_logic_vector(127 downto 0) := x"8EA2B7CA516745BFEAFC49904B496089";
  begin
    rst <= '1';
    wait for 3*PERIOD;
    rst <= '0';

    -- drive inputs
    pt <= slv128_to_state(plain);
    for i in 0 to 15 loop
      key_low(i)  <= key256(255 - i*8 downto 248 - i*8);
      key_high(i) <= key256(127 - i*8 downto 120 - i*8);
    end loop;

    wait for PERIOD;
    start <= '1';
    wait for PERIOD;
    start <= '0';

    wait until done = '1';
    assert state_to_slv128(ct) = exp_ct report "AES-256 core ciphertext mismatch" severity error;
    report "tb_aes256_core passed" severity note;
    wait;
  end process;
end architecture;

