library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_pkg.all;

-- AES-256 Key Expansion (iterative). Provides 15 round keys (0..14) for AES-256.
-- Interface: load 256-bit key as 32 bytes (state_t for low 16 + state_t for high 16), then pulse start.
-- Outputs round_key valid for each round index, with round_idx from 0..14.
entity keyexpansion is
  port(
    clk        : in  std_logic;
    rst        : in  std_logic;
    start      : in  std_logic;
    key_low    : in  state_t;  -- bytes 0..15
    key_high   : in  state_t;  -- bytes 16..31
    round_key  : out state_t;  -- current 128-bit round key (as state bytes)
    round_idx  : out unsigned(4 downto 0);
    valid      : out std_logic;
    done       : out std_logic
  );
end entity;

architecture rtl of keyexpansion is
  type word_t is array (0 to 7) of std_logic_vector(31 downto 0); -- 8 words of 32-bit (AES-256 nk=8)
  signal w      : word_t;
  signal i_round: unsigned(4 downto 0); -- 0..14
  signal busy   : std_logic;

  function pack32(b3,b2,b1,b0 : byte_t) return std_logic_vector is
  begin
    return b3 & b2 & b1 & b0;
  end function;

  function subword(x : std_logic_vector(31 downto 0)) return std_logic_vector is
    variable y : std_logic_vector(31 downto 0);
  begin
    y(31 downto 24) := sbox(x(31 downto 24));
    y(23 downto 16) := sbox(x(23 downto 16));
    y(15 downto  8) := sbox(x(15 downto  8));
    y( 7 downto  0) := sbox(x( 7 downto  0));
    return y;
  end function;

  function rotword(x : std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    return x(23 downto 0) & x(31 downto 24);
  end function;

  -- Convert 4 words to state bytes (column-major): words are w[i], w[i+1], w[i+2], w[i+3]
  function words_to_state(a,b,c,d : std_logic_vector(31 downto 0)) return state_t is
    variable s : state_t;
  begin
    -- AES state stores columns; each word is a column [b31..b0] -> bytes [b31..24,b23..16,b15..8,b7..0]
    s(0)  := a(31 downto 24);
    s(1)  := a(23 downto 16);
    s(2)  := a(15 downto  8);
    s(3)  := a( 7 downto  0);
    s(4)  := b(31 downto 24);
    s(5)  := b(23 downto 16);
    s(6)  := b(15 downto  8);
    s(7)  := b( 7 downto  0);
    s(8)  := c(31 downto 24);
    s(9)  := c(23 downto 16);
    s(10) := c(15 downto  8);
    s(11) := c( 7 downto  0);
    s(12) := d(31 downto 24);
    s(13) := d(23 downto 16);
    s(14) := d(15 downto  8);
    s(15) := d( 7 downto  0);
    return s;
  end function;

  signal rk_state : state_t;
  signal vld      : std_logic;
  signal done_i   : std_logic;
begin
  round_key <= rk_state;
  round_idx <= i_round;
  valid     <= vld;
  done      <= done_i;

  process(clk, rst)
    variable temp   : std_logic_vector(31 downto 0);
    variable rcon_b : byte_t;
    variable rcon_w : std_logic_vector(31 downto 0);
    -- local copies
    variable w0,w1,w2,w3,w4,w5,w6,w7 : std_logic_vector(31 downto 0);
    variable n0,n1,n2,n3,n4,n5,n6,n7 : std_logic_vector(31 downto 0);
  begin
    if rst = '1' then
      w <= (others => (others => '0'));
      i_round <= (others => '0');
      busy <= '0';
      rk_state <= (others => (others => '0'));
      vld <= '0';
      done_i <= '0';
    elsif rising_edge(clk) then
      vld <= '0';
      done_i <= '0';
      if start = '1' and busy = '0' then
        -- Load initial 256-bit key into w[0..7]
        -- key_low  bytes 0..15 -> w0..w3; key_high bytes 16..31 -> w4..w7
        w0 := pack32(key_low(0), key_low(1), key_low(2), key_low(3));
        w1 := pack32(key_low(4), key_low(5), key_low(6), key_low(7));
        w2 := pack32(key_low(8), key_low(9), key_low(10), key_low(11));
        w3 := pack32(key_low(12), key_low(13), key_low(14), key_low(15));
        w4 := pack32(key_high(0), key_high(1), key_high(2), key_high(3));
        w5 := pack32(key_high(4), key_high(5), key_high(6), key_high(7));
        w6 := pack32(key_high(8), key_high(9), key_high(10), key_high(11));
        w7 := pack32(key_high(12), key_high(13), key_high(14), key_high(15));
        w(0) <= w0; w(1) <= w1; w(2) <= w2; w(3) <= w3; w(4) <= w4; w(5) <= w5; w(6) <= w6; w(7) <= w7;
        i_round <= to_unsigned(0, i_round'length);
        rk_state <= words_to_state(w0,w1,w2,w3);
        vld <= '1';
        busy <= '1';
      elsif busy = '1' then
        -- Generate next 8 words for AES-256: total of 60 words (w0..w59)
        -- Snapshot current words
        w0 := w(0); w1 := w(1); w2 := w(2); w3 := w(3); w4 := w(4); w5 := w(5); w6 := w(6); w7 := w(7);
        -- temp = w7
        temp := w7;
        -- w8 = w0 xor SubWord(RotWord(w7)) xor Rcon
        rcon_b := rcon(to_integer(i_round)+1);
        rcon_w := rcon_b & x"000000";
        n0 := std_logic_vector(unsigned(w0) xor unsigned(subword(rotword(temp))) xor unsigned(rcon_w));
        -- w9 = w1 xor w8
        n1 := std_logic_vector(unsigned(w1) xor unsigned(n0));
        -- w10 = w2 xor w9
        n2 := std_logic_vector(unsigned(w2) xor unsigned(n1));
        -- w11 = w3 xor w10
        n3 := std_logic_vector(unsigned(w3) xor unsigned(n2));
        -- w12 = w4 xor SubWord(w11)
        n4 := std_logic_vector(unsigned(w4) xor unsigned(subword(n3)));
        -- w13 = w5 xor w12
        n5 := std_logic_vector(unsigned(w5) xor unsigned(n4));
        -- w14 = w6 xor w13
        n6 := std_logic_vector(unsigned(w6) xor unsigned(n5));
        -- w15 = w7 xor w14
        n7 := std_logic_vector(unsigned(w7) xor unsigned(n6));

        -- Update window to next 8 words
        w(0) <= n0; w(1) <= n1; w(2) <= n2; w(3) <= n3; w(4) <= n4; w(5) <= n5; w(6) <= n6; w(7) <= n7;

        i_round <= i_round + 1;
        rk_state <= words_to_state(n0,n1,n2,n3);
        vld <= '1';
        if i_round = to_unsigned(14, i_round'length) then
          done_i <= '1';
          busy <= '0';
        end if;
      end if;
    end if;
  end process;
end architecture;

