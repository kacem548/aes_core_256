library ieee;
use ieee.std_logic_1164.all;

entity aes_round_dec is
  generic (
    IS_FINAL : boolean := false
  );
  port (
    state_in  : in  std_logic_vector(127 downto 0);
    round_key : in  std_logic_vector(127 downto 0);
    state_out : out std_logic_vector(127 downto 0)
  );
end entity aes_round_dec;

architecture rtl of aes_round_dec is
  component inv_shiftrows is
    port ( state_in : in std_logic_vector(127 downto 0); state_out : out std_logic_vector(127 downto 0) );
  end component;
  component inv_subbytes is
    port ( state_in : in std_logic_vector(127 downto 0); state_out : out std_logic_vector(127 downto 0) );
  end component;
  component inv_mixcolumns is
    port ( state_in : in std_logic_vector(127 downto 0); state_out : out std_logic_vector(127 downto 0) );
  end component;
  component add_round_key is
    port ( state_in : in std_logic_vector(127 downto 0); round_key : in std_logic_vector(127 downto 0); state_out : out std_logic_vector(127 downto 0) );
  end component;

  signal s_isr, s_isb, s_ark, s_out : std_logic_vector(127 downto 0);
begin
  -- Decryption round: InvShiftRows -> InvSubBytes -> AddRoundKey -> InvMixColumns (except final: no InvMix)
  u_isr: inv_shiftrows port map(state_in => state_in, state_out => s_isr);
  u_isb: inv_subbytes port map(state_in => s_isr, state_out => s_isb);
  u_ark: add_round_key port map(state_in => s_isb, round_key => round_key, state_out => s_ark);

  gen_non_final: if not IS_FINAL generate
    u_imc: inv_mixcolumns port map(state_in => s_ark, state_out => s_out);
    state_out <= s_out;
  end generate;

  gen_final: if IS_FINAL generate
    state_out <= s_ark;
  end generate;
end architecture rtl;

