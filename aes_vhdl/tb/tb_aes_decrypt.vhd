library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_aes_decrypt is
end entity;

architecture sim of tb_aes_decrypt is
  component aes_top is
    port (
      clk_i      : in  std_logic;
      rst_i      : in  std_logic;
      start_i    : in  std_logic;
      enc_i      : in  std_logic;
      key_i      : in  std_logic_vector(255 downto 0);
      block_i    : in  std_logic_vector(127 downto 0);
      ready_o    : out std_logic;
      valid_o    : out std_logic;
      block_o    : out std_logic_vector(127 downto 0)
    );
  end component;

  signal clk   : std_logic := '0';
  signal rst   : std_logic := '1';
  signal start : std_logic := '0';
  signal enc   : std_logic := '0';
  signal key   : std_logic_vector(255 downto 0);
  signal din   : std_logic_vector(127 downto 0);
  signal ready : std_logic;
  signal valid : std_logic;
  signal dout  : std_logic_vector(127 downto 0);

  constant C_KEY  : std_logic_vector(255 downto 0) := x"000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f";
  constant C_PTXT : std_logic_vector(127 downto 0) := x"00112233445566778899aabbccddeeff";
  constant C_CTXT : std_logic_vector(127 downto 0) := x"8ea2b7ca516745bfeafc49904b496089";

begin
  -- clock
  clk <= not clk after 5 ns;

  uut : aes_top
    port map (
      clk_i   => clk,
      rst_i   => rst,
      start_i => start,
      enc_i   => enc,
      key_i   => key,
      block_i => din,
      ready_o => ready,
      valid_o => valid,
      block_o => dout
    );

  stim : process
  begin
    key <= C_KEY;
    din <= C_CTXT;
    wait for 20 ns;
    rst <= '0';
    wait for 20 ns;
    wait until rising_edge(clk);
    if ready = '1' then
      start <= '1';
    end if;
    wait until rising_edge(clk);
    start <= '0';

    -- wait for result
    wait until valid = '1';
    assert dout = C_PTXT report "AES-256 DEC mismatch" severity error;
    report "AES-256 DEC OK" severity note;

    wait for 50 ns;
    assert false report "SIM DONE" severity failure;
  end process;

end architecture sim;

