library ieee;
use ieee.std_logic_1164.all;

entity aes_round_enc is
  generic (
    IS_FINAL : boolean := false
  );
  port (
    state_in  : in  std_logic_vector(127 downto 0);
    round_key : in  std_logic_vector(127 downto 0);
    state_out : out std_logic_vector(127 downto 0)
  );
end entity aes_round_enc;

architecture rtl of aes_round_enc is
  component subbytes is
    port ( state_in : in std_logic_vector(127 downto 0); state_out : out std_logic_vector(127 downto 0) );
  end component;
  component shiftrows is
    port ( state_in : in std_logic_vector(127 downto 0); state_out : out std_logic_vector(127 downto 0) );
  end component;
  component mixcolumns is
    port ( state_in : in std_logic_vector(127 downto 0); state_out : out std_logic_vector(127 downto 0) );
  end component;
  component add_round_key is
    port ( state_in : in std_logic_vector(127 downto 0); round_key : in std_logic_vector(127 downto 0); state_out : out std_logic_vector(127 downto 0) );
  end component;

  signal s1, s2, s3, s4 : std_logic_vector(127 downto 0);
begin
  u_sb: subbytes port map(state_in => state_in, state_out => s1);
  u_sr: shiftrows port map(state_in => s1, state_out => s2);

  gen_non_final: if not IS_FINAL generate
    u_mc: mixcolumns port map(state_in => s2, state_out => s3);
    u_ark: add_round_key port map(state_in => s3, round_key => round_key, state_out => s4);
    state_out <= s4;
  end generate;

  gen_final: if IS_FINAL generate
    u_ark_f: add_round_key port map(state_in => s2, round_key => round_key, state_out => s4);
    state_out <= s4;
  end generate;
end architecture rtl;

