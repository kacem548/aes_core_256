library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity aes_encrypt_core is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    start_i    : in  std_logic;
    key_i      : in  std_logic_vector(255 downto 0);
    block_i    : in  std_logic_vector(127 downto 0);
    ready_o    : out std_logic;
    valid_o    : out std_logic;
    block_o    : out std_logic_vector(127 downto 0)
  );
end entity aes_encrypt_core;

architecture rtl of aes_encrypt_core is
  component aes_key_schedule_256 is
    port (
      key_i    : in  std_logic_vector(255 downto 0);
      round_i  : in  std_logic_vector(3 downto 0);
      rkey_o   : out std_logic_vector(127 downto 0)
    );
  end component;

  component aes_enc_round is
    port (
      state_i      : in  std_logic_vector(127 downto 0);
      rkey_i       : in  std_logic_vector(127 downto 0);
      last_round_i : in  std_logic;
      state_o      : out std_logic_vector(127 downto 0)
    );
  end component;

  type fsm_t is (IDLE, INIT_ADD, ROUND);
  signal fsm_s       : fsm_t;
  signal round_cnt   : unsigned(3 downto 0); -- 0..14, where 0 used in INIT_ADD
  signal rkey_idx_s  : std_logic_vector(3 downto 0);
  signal state_reg   : std_logic_vector(127 downto 0);
  signal round_out_s : std_logic_vector(127 downto 0);
  signal rkey_s      : std_logic_vector(127 downto 0);
  signal last_round  : std_logic;
  signal ready_s     : std_logic;
  signal valid_s     : std_logic;

begin

  key_sched_i : aes_key_schedule_256
    port map (
      key_i   => key_i,
      round_i => rkey_idx_s,
      rkey_o  => rkey_s
    );

  round_i : aes_enc_round
    port map (
      state_i      => state_reg,
      rkey_i       => rkey_s,
      last_round_i => last_round,
      state_o      => round_out_s
    );

  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        round_cnt <= (others => '0');
        state_reg <= (others => '0');
        fsm_s     <= IDLE;
        ready_s   <= '1';
        valid_s   <= '0';
      else
        valid_s <= '0';
        case fsm_s is
          when IDLE =>
            ready_s <= '1';
            if start_i = '1' then
              -- Prepare initial AddRoundKey with round key 0
              state_reg <= block_i;
              round_cnt <= to_unsigned(0, 4);
              fsm_s     <= INIT_ADD;
              ready_s   <= '0';
            end if;

          when INIT_ADD =>
            -- Perform initial AddRoundKey: state := state xor rkey[0]
            state_reg <= state_reg xor rkey_s;
            round_cnt <= to_unsigned(1, 4);
            fsm_s     <= ROUND;

          when ROUND =>
            -- Apply round with rkey[round_cnt]
            state_reg <= round_out_s;
            if round_cnt = to_unsigned(14, 4) then
              -- finished final round this cycle
              valid_s <= '1';
              fsm_s   <= IDLE;
            else
              round_cnt <= round_cnt + 1;
            end if;
        end case;
      end if;
    end if;
  end process;

  -- key index selection
  rkey_idx_s <= std_logic_vector(round_cnt) when (fsm_s = ROUND) else x"0";
  last_round <= '1' when (fsm_s = ROUND and round_cnt = to_unsigned(14, 4)) else '0';

  -- Drive output block when valid; otherwise pass through current round output
  block_o <= state_reg when valid_s = '1' else round_out_s;
  ready_o <= ready_s;
  valid_o <= valid_s;

end architecture rtl;

