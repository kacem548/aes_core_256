library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Iterative AES-256 core with simple handshaking.
-- Encrypt or decrypt 128-bit block using 256-bit key.
entity aes256_core is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    start     : in  std_logic;
    enc_n     : in  std_logic; -- '1' for encrypt, '0' for decrypt
    key       : in  std_logic_vector(255 downto 0);
    data_in   : in  std_logic_vector(127 downto 0);
    data_out  : out std_logic_vector(127 downto 0);
    ready     : out std_logic
  );
end entity aes256_core;

architecture rtl of aes256_core is
  component key_expand_aes256 is
    port ( key_in : in std_logic_vector(255 downto 0); round_keys_flat : out std_logic_vector((15*128)-1 downto 0) );
  end component;
  component aes_round_enc is
    generic ( IS_FINAL : boolean := false );
    port ( state_in : in std_logic_vector(127 downto 0); round_key : in std_logic_vector(127 downto 0); state_out : out std_logic_vector(127 downto 0) );
  end component;
  component aes_round_dec is
    generic ( IS_FINAL : boolean := false );
    port ( state_in : in std_logic_vector(127 downto 0); round_key : in std_logic_vector(127 downto 0); state_out : out std_logic_vector(127 downto 0) );
  end component;
  component add_round_key is
    port ( state_in : in std_logic_vector(127 downto 0); round_key : in std_logic_vector(127 downto 0); state_out : out std_logic_vector(127 downto 0) );
  end component;

  type state_t is (IDLE, EXPAND, INIT_ADDKEY, ROUND, FINAL, DONE);
  signal cs, ns : state_t;

  signal rk_flat : std_logic_vector((15*128)-1 downto 0);
  type rk_array_t is array (0 to 14) of std_logic_vector(127 downto 0);
  signal rks : rk_array_t;

  signal round_idx  : integer range 0 to 14;
  signal state_reg  : std_logic_vector(127 downto 0);
  signal ark_init   : std_logic_vector(127 downto 0);
  signal round_out_nf_enc : std_logic_vector(127 downto 0);
  signal round_out_f_enc  : std_logic_vector(127 downto 0);
  signal round_out_nf_dec : std_logic_vector(127 downto 0);
  signal round_out_f_dec  : std_logic_vector(127 downto 0);
  signal rk_nf     : std_logic_vector(127 downto 0);
  signal rk_final  : std_logic_vector(127 downto 0);

begin
  -- key expansion
  u_kexp: key_expand_aes256 port map(key_in => key, round_keys_flat => rk_flat);

  -- unpack keys: rk[0]..rk[14]
  gen_rk: for i in 0 to 14 generate
  begin
    rks(i) <= rk_flat(((15-1-i)*128)+127 downto ((15-1-i)*128));
  end generate;

  -- initial add round key depends on enc/dec
  ark_init <= data_in xor (rks(0)) when enc_n = '1' else data_in xor (rks(14));

  -- encryption and decryption rounds (combinational), selected in FSM
  -- Encryption rounds
  u_enc_round_nf: aes_round_enc
    generic map(IS_FINAL => false)
    port map(state_in => state_reg, round_key => rk_nf, state_out => round_out_nf_enc);
  u_enc_round_f: aes_round_enc
    generic map(IS_FINAL => true)
    port map(state_in => state_reg, round_key => rk_final, state_out => round_out_f_enc);

  -- Decryption rounds
  u_dec_round_nf: aes_round_dec
    generic map(IS_FINAL => false)
    port map(state_in => state_reg, round_key => rk_nf, state_out => round_out_nf_dec);
  u_dec_round_f: aes_round_dec
    generic map(IS_FINAL => true)
    port map(state_in => state_reg, round_key => rk_final, state_out => round_out_f_dec);

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        cs <= IDLE;
        round_idx <= 0;
        state_reg <= (others => '0');
      else
        cs <= ns;
        case cs is
          when INIT_ADDKEY =>
            state_reg <= ark_init;
          when ROUND =>
            if enc_n = '1' then
              state_reg <= round_out_nf_enc;
            else
              state_reg <= round_out_nf_dec;
            end if;
          when FINAL =>
            if enc_n = '1' then
              state_reg <= round_out_f_enc;
            else
              state_reg <= round_out_f_dec;
            end if;
          when others => null;
        end case;
      end if;
    end if;
  end process;

  -- simple next-state logic
  process(cs, start, enc_n, round_idx)
  begin
    ns    <= cs;
    case cs is
      when IDLE =>
        if start = '1' then
          ns <= EXPAND;  -- expansion combinational, advance immediately
        end if;
      when EXPAND =>
        ns <= INIT_ADDKEY;
      when INIT_ADDKEY =>
        ns <= ROUND;
      when ROUND =>
        if enc_n = '1' then
          if round_idx = 13 then
            ns <= FINAL;
          else
            ns <= ROUND;
          end if;
        else
          if round_idx = 1 then
            ns <= FINAL;
          else
            ns <= ROUND;
          end if;
        end if;
      when FINAL =>
        ns <= DONE;
      when DONE =>
        ns <= IDLE;
      when others => ns <= IDLE;
    end case;
  end process;

  -- round index control
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        round_idx <= 0;
      else
        if cs = INIT_ADDKEY then
          if enc_n = '1' then
            round_idx <= 1;     -- enc: start at K1
          else
            round_idx <= 13;    -- dec: start at K13
          end if;
        elsif cs = ROUND then
          if enc_n = '1' then
            if round_idx < 13 then
              round_idx <= round_idx + 1;
            end if;
          else
            if round_idx > 1 then
              round_idx <= round_idx - 1;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;

  -- Select round keys for non-final and final
  rk_nf    <= rks(round_idx);
  rk_final <= rks(14) when enc_n = '1' else rks(0);

  -- final output and ready
  data_out <= state_reg;
  ready <= '1' when cs = DONE else '0';

end architecture rtl;

