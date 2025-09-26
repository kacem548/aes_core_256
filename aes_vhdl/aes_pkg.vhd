library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package aes_pkg is

  subtype byte_t is std_logic_vector(7 downto 0);
  subtype word_t is std_logic_vector(31 downto 0);
  subtype state128_t is std_logic_vector(127 downto 0);

  type byte_matrix_t is array (0 to 3, 0 to 3) of byte_t; -- (row, col)
  type round_keys_t is array (0 to 14) of state128_t; -- AES-256: Nr=14 -> 15 round keys

  -- Rijndael S-box (forward)
  type sbox_t is array (0 to 255) of byte_t;
  constant SBOX : sbox_t := (
    x"63", x"7c", x"77", x"7b", x"f2", x"6b", x"6f", x"c5",
    x"30", x"01", x"67", x"2b", x"fe", x"d7", x"ab", x"76",
    x"ca", x"82", x"c9", x"7d", x"fa", x"59", x"47", x"f0",
    x"ad", x"d4", x"a2", x"af", x"9c", x"a4", x"72", x"c0",
    x"b7", x"fd", x"93", x"26", x"36", x"3f", x"f7", x"cc",
    x"34", x"a5", x"e5", x"f1", x"71", x"d8", x"31", x"15",
    x"04", x"c7", x"23", x"c3", x"18", x"96", x"05", x"9a",
    x"07", x"12", x"80", x"e2", x"eb", x"27", x"b2", x"75",
    x"09", x"83", x"2c", x"1a", x"1b", x"6e", x"5a", x"a0",
    x"52", x"3b", x"d6", x"b3", x"29", x"e3", x"2f", x"84",
    x"53", x"d1", x"00", x"ed", x"20", x"fc", x"b1", x"5b",
    x"6a", x"cb", x"be", x"39", x"4a", x"4c", x"58", x"cf",
    x"d0", x"ef", x"aa", x"fb", x"43", x"4d", x"33", x"85",
    x"45", x"f9", x"02", x"7f", x"50", x"3c", x"9f", x"a8",
    x"51", x"a3", x"40", x"8f", x"92", x"9d", x"38", x"f5",
    x"bc", x"b6", x"da", x"21", x"10", x"ff", x"f3", x"d2",
    x"cd", x"0c", x"13", x"ec", x"5f", x"97", x"44", x"17",
    x"c4", x"a7", x"7e", x"3d", x"64", x"5d", x"19", x"73",
    x"60", x"81", x"4f", x"dc", x"22", x"2a", x"90", x"88",
    x"46", x"ee", x"b8", x"14", x"de", x"5e", x"0b", x"db",
    x"e0", x"32", x"3a", x"0a", x"49", x"06", x"24", x"5c",
    x"c2", x"d3", x"ac", x"62", x"91", x"95", x"e4", x"79",
    x"e7", x"c8", x"37", x"6d", x"8d", x"d5", x"4e", x"a9",
    x"6c", x"56", x"f4", x"ea", x"65", x"7a", x"ae", x"08",
    x"ba", x"78", x"25", x"2e", x"1c", x"a6", x"b4", x"c6",
    x"e8", x"dd", x"74", x"1f", x"4b", x"bd", x"8b", x"8a",
    x"70", x"3e", x"b5", x"66", x"48", x"03", x"f6", x"0e",
    x"61", x"35", x"57", x"b9", x"86", x"c1", x"1d", x"9e",
    x"e1", x"f8", x"98", x"11", x"69", x"d9", x"8e", x"94",
    x"9b", x"1e", x"87", x"e9", x"ce", x"55", x"28", x"df",
    x"8c", x"a1", x"89", x"0d", x"bf", x"e6", x"42", x"68",
    x"41", x"99", x"2d", x"0f", x"b0", x"54", x"bb", x"16"
  );

  -- Rcon for AES key expansion (word_t: RC,00,00,00)
  type rcon_t is array (0 to 9) of word_t;
  constant RCON : rcon_t := (
    x"01000000", x"02000000", x"04000000", x"08000000",
    x"10000000", x"20000000", x"40000000", x"80000000",
    x"1B000000", x"36000000"
  );

  -- Utility functions
  function sbox_lookup(b : byte_t) return byte_t;
  function rot_word(w : word_t) return word_t;
  function sub_word(w : word_t) return word_t;

  function xtime(b : byte_t) return byte_t;  -- multiply by 02 in GF(2^8)
  function gm2(b : byte_t) return byte_t;
  function gm3(b : byte_t) return byte_t;

  function to_matrix(s : state128_t) return byte_matrix_t;
  function from_matrix(m : byte_matrix_t) return state128_t;

  function mix_single_column(a0, a1, a2, a3 : byte_t)
    return byte_t;  -- overloaded via records? We will return a0' after mixing; not used

  procedure mix_columns(
    signal s_in  : in  state128_t;
    signal s_out : out state128_t
  );

  -- AES-256 key schedule expansion
  function expand_key_256(key256 : std_logic_vector(255 downto 0)) return round_keys_t;

end package;

package body aes_pkg is

  function sbox_lookup(b : byte_t) return byte_t is
  begin
    return SBOX(to_integer(unsigned(b)));
  end function;

  function rot_word(w : word_t) return word_t is
  begin
    return w(23 downto 0) & w(31 downto 24);
  end function;

  function sub_word(w : word_t) return word_t is
    variable r : word_t;
  begin
    r(31 downto 24) := sbox_lookup(w(31 downto 24));
    r(23 downto 16) := sbox_lookup(w(23 downto 16));
    r(15 downto 8)  := sbox_lookup(w(15 downto 8));
    r(7 downto 0)   := sbox_lookup(w(7 downto 0));
    return r;
  end function;

  function xtime(b : byte_t) return byte_t is
    variable x : unsigned(7 downto 0) := unsigned(b);
  begin
    if b(7) = '1' then
      return std_logic_vector( (x sll 1) xor to_unsigned(16#1B#, 8) );
    else
      return std_logic_vector( x sll 1 );
    end if;
  end function;

  function gm2(b : byte_t) return byte_t is
  begin
    return xtime(b);
  end function;

  function gm3(b : byte_t) return byte_t is
  begin
    return std_logic_vector(unsigned(xtime(b)) xor unsigned(b));
  end function;

  function to_matrix(s : state128_t) return byte_matrix_t is
    variable m : byte_matrix_t;
    variable idx : integer := 0; -- byte index 0..15, col-major
  begin
    for c in 0 to 3 loop
      for r in 0 to 3 loop
        m(r, c) := s(127 - 8*idx downto 120 - 8*idx);
        idx := idx + 1;
      end loop;
    end loop;
    return m;
  end function;

  function from_matrix(m : byte_matrix_t) return state128_t is
    variable s : state128_t := (others => '0');
    variable idx : integer := 0;
  begin
    for c in 0 to 3 loop
      for r in 0 to 3 loop
        s(127 - 8*idx downto 120 - 8*idx) := m(r, c);
        idx := idx + 1;
      end loop;
    end loop;
    return s;
  end function;

  -- Return value unused; helper kept for completeness
  function mix_single_column(a0, a1, a2, a3 : byte_t) return byte_t is
    variable r0, r1, r2, r3 : byte_t;
  begin
    r0 := std_logic_vector(unsigned(gm2(a0)) xor unsigned(gm3(a1)) xor unsigned(a2) xor unsigned(a3));
    r1 := std_logic_vector(unsigned(a0) xor unsigned(gm2(a1)) xor unsigned(gm3(a2)) xor unsigned(a3));
    r2 := std_logic_vector(unsigned(a0) xor unsigned(a1) xor unsigned(gm2(a2)) xor unsigned(gm3(a3)));
    r3 := std_logic_vector(unsigned(gm3(a0)) xor unsigned(a1) xor unsigned(a2) xor unsigned(gm2(a3)));
    return r0; -- not used by caller; full mix done in procedure below
  end function;

  procedure mix_columns(
    signal s_in  : in  state128_t;
    signal s_out : out state128_t
  ) is
    variable m  : byte_matrix_t := to_matrix(s_in);
    variable mo : byte_matrix_t;
  begin
    for c in 0 to 3 loop
      mo(0,c) := std_logic_vector(unsigned(gm2(m(0,c))) xor unsigned(gm3(m(1,c))) xor unsigned(m(2,c)) xor unsigned(m(3,c)));
      mo(1,c) := std_logic_vector(unsigned(m(0,c)) xor unsigned(gm2(m(1,c))) xor unsigned(gm3(m(2,c))) xor unsigned(m(3,c)));
      mo(2,c) := std_logic_vector(unsigned(m(0,c)) xor unsigned(m(1,c)) xor unsigned(gm2(m(2,c))) xor unsigned(gm3(m(3,c))));
      mo(3,c) := std_logic_vector(unsigned(gm3(m(0,c))) xor unsigned(m(1,c)) xor unsigned(m(2,c)) xor unsigned(gm2(m(3,c))));
    end loop;
    s_out <= from_matrix(mo);
  end procedure;

  -- AES-256 key expansion
  function expand_key_256(key256 : std_logic_vector(255 downto 0)) return round_keys_t is
    type words60_t is array (0 to 59) of word_t;
    variable W : words60_t;
    variable rk : round_keys_t;
    variable i  : integer;
    variable temp : word_t;
  begin
    -- Load initial 8 words from key (big-endian words)
    for k in 0 to 7 loop
      W(k) := key256(255 - 32*k downto 224 - 32*k);
    end loop;

    i := 8;
    while i <= 59 loop
      temp := W(i-1);
      if (i mod 8) = 0 then
        temp := sub_word(rot_word(temp)) xor RCON((i/8) - 1);
      elsif (i mod 8) = 4 then
        temp := sub_word(temp);
      end if;
      W(i) := std_logic_vector(unsigned(W(i-8)) xor unsigned(temp));
      i := i + 1;
    end loop;

    -- Pack round keys: 15 keys of 128 bits (4 words each)
    for r in 0 to 14 loop
      rk(r) := W(4*r) & W(4*r + 1) & W(4*r + 2) & W(4*r + 3);
    end loop;
    return rk;
  end function;

end package body;

