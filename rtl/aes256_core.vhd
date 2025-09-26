library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_pkg.all;

-- Iterative AES-256 encrypt core
entity aes256_core is
  port(
    clk       : in  std_logic;
    rst       : in  std_logic;
    start     : in  std_logic;
    plaintext : in  state_t;
    key_low   : in  state_t;
    key_high  : in  state_t;
    ciphertext: out state_t;
    done      : out std_logic
  );
end entity;

architecture rtl of aes256_core is
  signal state      : state_t;
  signal rk_state   : state_t;
  signal round      : unsigned(4 downto 0);
  signal running    : std_logic;

  -- key expansion
  signal ke_valid   : std_logic;
  signal ke_done    : std_logic;
  signal ke_round   : unsigned(4 downto 0);
begin
  u_ke: entity work.keyexpansion
    port map(
      clk       => clk,
      rst       => rst,
      start     => start,
      key_low   => key_low,
      key_high  => key_high,
      round_key => rk_state,
      round_idx => ke_round,
      valid     => ke_valid,
      done      => ke_done
    );

  process(clk, rst)
    variable ark_out : state_t;
  begin
    if rst = '1' then
      state <= (others => (others => '0'));
      round <= (others => '0');
      running <= '0';
      ciphertext <= (others => (others => '0'));
      done <= '0';
    elsif rising_edge(clk) then
      done <= '0';
      if start = '1' and running = '0' then
        running <= '1';
      end if;

      if ke_valid = '1' then
        if ke_round = to_unsigned(0, 5) then
          -- initial AddRoundKey
          u_ark: for i in 0 to 15 loop
            state(i) <= std_logic_vector(unsigned(plaintext(i)) xor unsigned(rk_state(i)));
          end loop;
          round <= to_unsigned(1, 5);
        elsif ke_round < to_unsigned(14,5) then
          -- rounds 1..13
          -- Combinational round using aes_round, last='0'
          -- Inline round to avoid extra latency: compute next state
          variable sb,sr,mc,ark : state_t;
        else
          null;
        end if;
      end if;
    end if;
  end process;

  -- Simpler approach: separate small FSM for rounds using aes_round module and capturing rk_state when valid
  type fsm_t is (IDLE, INIT, ROUND, LAST);
  signal fsm : fsm_t;
  signal next_state : state_t;
  signal last_flag : std_logic;

  u_round: entity work.aes_round
    port map(
      state_in  => state,
      round_key => rk_state,
      last      => last_flag,
      state_out => next_state
    );

  process(clk, rst)
  begin
    if rst = '1' then
      fsm <= IDLE;
      round <= (others => '0');
      state <= (others => (others => '0'));
      done <= '0';
      last_flag <= '0';
    elsif rising_edge(clk) then
      done <= '0';
      case fsm is
        when IDLE =>
          if start = '1' then
            fsm <= INIT;
          end if;
        when INIT =>
          -- wait for round_key 0 valid, apply initial AddRoundKey
          if ke_valid = '1' and ke_round = to_unsigned(0,5) then
            for i in 0 to 15 loop
              state(i) <= std_logic_vector(unsigned(plaintext(i)) xor unsigned(rk_state(i)));
            end loop;
            round <= to_unsigned(1,5);
            fsm <= ROUND;
          end if;
        when ROUND =>
          if ke_valid = '1' then
            if ke_round = to_unsigned(14,5) then
              -- last round key is arriving next state needs last='1'
              last_flag <= '1';
            else
              last_flag <= '0';
            end if;
            -- compute round with current rk_state
            state <= next_state;
            if round = to_unsigned(13,5) then
              fsm <= LAST;
            end if;
            round <= round + 1;
          end if;
        when LAST =>
          -- ke_round=14 should have been used with last_flag='1'
          ciphertext <= state;
          done <= '1';
          fsm <= IDLE;
      end case;
    end if;
  end process;
end architecture;

