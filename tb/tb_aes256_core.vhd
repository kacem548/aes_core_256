library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_aes256_core is
end entity;

architecture sim of tb_aes256_core is
  component aes256_core is
    port (
      clk      : in  std_logic;
      rst      : in  std_logic;
      start    : in  std_logic;
      enc_n    : in  std_logic;
      key      : in  std_logic_vector(255 downto 0);
      data_in  : in  std_logic_vector(127 downto 0);
      data_out : out std_logic_vector(127 downto 0);
      ready    : out std_logic
    );
  end component;

  signal clk      : std_logic := '0';
  signal rst      : std_logic := '1';
  signal start    : std_logic := '0';
  signal enc_n    : std_logic := '1';
  signal key      : std_logic_vector(255 downto 0);
  signal data_in  : std_logic_vector(127 downto 0);
  signal data_out : std_logic_vector(127 downto 0);
  signal ready    : std_logic;

  constant CLK_PERIOD : time := 10 ns;

  -- NIST AES-256 Known Answer Test (SP 800-38A F.5.5 CBC, first block ECB)
  constant K256 : std_logic_vector(255 downto 0) := x"603deb1015ca71be2b73aef0857d7781" & x"1f352c073b6108d72d9810a30914dff4";
  constant P    : std_logic_vector(127 downto 0) := x"6bc1bee22e409f96e93d7e117393172a";
  constant C    : std_logic_vector(127 downto 0) := x"f3eed1bdb5d2a03c064b5a7e3db181f8";

begin
  -- clock
  clk <= not clk after CLK_PERIOD/2;

  -- DUT
  dut: aes256_core
    port map (
      clk => clk,
      rst => rst,
      start => start,
      enc_n => enc_n,
      key => key,
      data_in => data_in,
      data_out => data_out,
      ready => ready
    );

  -- Stimulus
  process
  begin
    key <= K256;
    data_in <= P;
    wait for 5*CLK_PERIOD;
    rst <= '0';
    wait for 2*CLK_PERIOD;

    -- Encrypt
    enc_n <= '1';
    start <= '1';
    wait for CLK_PERIOD;
    start <= '0';
    -- Wait until ready
    wait until ready = '1';
    assert data_out = C report "AES-256 encrypt mismatch" severity failure;

    -- Decrypt
    data_in <= C;
    enc_n <= '0';
    start <= '1';
    wait for CLK_PERIOD;
    start <= '0';
    wait until ready = '1';
    assert data_out = P report "AES-256 decrypt mismatch" severity failure;

    report "All tests passed" severity note;
    wait;
  end process;

end architecture sim;

