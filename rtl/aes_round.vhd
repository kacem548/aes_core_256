library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_pkg.all;

entity aes_round is
  port(
    state_in  : in  state_t;
    round_key : in  state_t;
    last      : in  std_logic; -- '1' to bypass MixColumns
    state_out : out state_t
  );
end entity;

architecture rtl of aes_round is
  signal sb_o  : state_t;
  signal sr_o  : state_t;
  signal mc_o  : state_t;
  signal ark_o : state_t;  -- AddRoundKey applied to sr_o (last round)
  signal ark2_o: state_t;  -- AddRoundKey applied to mc_o (normal round)
begin
  u_sb: entity work.subbytes port map(state_in => state_in, state_out => sb_o);
  u_sr: entity work.shiftrows port map(state_in => sb_o, state_out => sr_o);

  u_mc: entity work.mixcolumns port map(state_in => sr_o, state_out => mc_o);

  u_ark1: entity work.addroundkey
    port map(
      state_in  => sr_o,
      round_key => round_key,
      state_out => ark_o
    );

  u_ark2: entity work.addroundkey
    port map(
      state_in  => mc_o,
      round_key => round_key,
      state_out => ark2_o
    );

  -- Select between AddRoundKey(sr_o, key) for last round and AddRoundKey(mc_o, key) otherwise
  state_out <= ark_o when last = '1' else ark2_o;
end architecture;

