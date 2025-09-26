library ieee;
use ieee.std_logic_1164.all;

entity aes_top is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    start_i    : in  std_logic;
    enc_i      : in  std_logic; -- '1' encrypt, '0' decrypt
    key_i      : in  std_logic_vector(255 downto 0);
    block_i    : in  std_logic_vector(127 downto 0);
    ready_o    : out std_logic;
    valid_o    : out std_logic;
    block_o    : out std_logic_vector(127 downto 0)
  );
end entity aes_top;

architecture rtl of aes_top is
  component aes_encrypt_core is
    port (
      clk_i   : in  std_logic;
      rst_i   : in  std_logic;
      start_i : in  std_logic;
      key_i   : in  std_logic_vector(255 downto 0);
      block_i : in  std_logic_vector(127 downto 0);
      ready_o : out std_logic;
      valid_o : out std_logic;
      block_o : out std_logic_vector(127 downto 0)
    );
  end component;

  component aes_decrypt_core is
    port (
      clk_i   : in  std_logic;
      rst_i   : in  std_logic;
      start_i : in  std_logic;
      key_i   : in  std_logic_vector(255 downto 0);
      block_i : in  std_logic_vector(127 downto 0);
      ready_o : out std_logic;
      valid_o : out std_logic;
      block_o : out std_logic_vector(127 downto 0)
    );
  end component;

  signal ready_enc, ready_dec : std_logic;
  signal valid_enc, valid_dec : std_logic;
  signal block_enc, block_dec : std_logic_vector(127 downto 0);

begin

  u_enc : aes_encrypt_core
    port map (
      clk_i   => clk_i,
      rst_i   => rst_i,
      start_i => start_i and enc_i,
      key_i   => key_i,
      block_i => block_i,
      ready_o => ready_enc,
      valid_o => valid_enc,
      block_o => block_enc
    );

  u_dec : aes_decrypt_core
    port map (
      clk_i   => clk_i,
      rst_i   => rst_i,
      start_i => start_i and not enc_i,
      key_i   => key_i,
      block_i => block_i,
      ready_o => ready_dec,
      valid_o => valid_dec,
      block_o => block_dec
    );

  ready_o <= ready_enc when enc_i = '1' else ready_dec;
  valid_o <= valid_enc when enc_i = '1' else valid_dec;
  block_o <= block_enc when enc_i = '1' else block_dec;

end architecture rtl;

