library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package aes_pkg is

  subtype byte_t is std_logic_vector(7 downto 0);
  subtype word_t is std_logic_vector(31 downto 0);

  type byte_array16_t is array (0 to 15) of byte_t;
  type word_array_60_t is array (0 to 59) of word_t;
  type roundkey_array_t is array (0 to 14) of std_logic_vector(127 downto 0);

  -- AES S-Box and inverse S-Box
  type sbox_t is array (0 to 255) of byte_t;

  constant AES_SBOX : sbox_t := (
    x"63", x"7C", x"77", x"7B", x"F2", x"6B", x"6F", x"C5", x"30", x"01", x"67", x"2B", x"FE", x"D7", x"AB", x"76",
    x"CA", x"82", x"C9", x"7D", x"FA", x"59", x"47", x"F0", x"AD", x"D4", x"A2", x"AF", x"9C", x"A4", x"72", x"C0",
    x"B7", x"FD", x"93", x"26", x"36", x"3F", x"F7", x"CC", x"34", x"A5", x"E5", x"F1", x"71", x"D8", x"31", x"15",
    x"04", x"C7", x"23", x"C3", x"18", x"96", x"05", x"9A", x"07", x"12", x"80", x"E2", x"EB", x"27", x"B2", x"75",
    x"09", x"83", x"2C", x"1A", x"1B", x"6E", x"5A", x"A0", x"52", x"3B", x"D6", x"B3", x"29", x"E3", x"2F", x"84",
    x"53", x"D1", x"00", x"ED", x"20", x"FC", x"B1", x"5B", x"6A", x"CB", x"BE", x"39", x"4A", x"4C", x"58", x"CF",
    x"D0", x"EF", x"AA", x"FB", x"43", x"4D", x"33", x"85", x"45", x"F9", x"02", x"7F", x"50", x"3C", x"9F", x"A8",
    x"51", x"A3", x"40", x"8F", x"92", x"9D", x"38", x"F5", x"BC", x"B6", x"DA", x"21", x"10", x"FF", x"F3", x"D2",
    x"CD", x"0C", x"13", x"EC", x"5F", x"97", x"44", x"17", x"C4", x"A7", x"7E", x"3D", x"64", x"5D", x"19", x"73",
    x"60", x"81", x"4F", x"DC", x"22", x"2A", x"90", x"88", x"46", x"EE", x"B8", x"14", x"DE", x"5E", x"0B", x"DB",
    x"E0", x"32", x"3A", x"0A", x"49", x"06", x"24", x"5C", x"C2", x"D3", x"AC", x"62", x"91", x"95", x"E4", x"79",
    x"E7", x"C8", x"37", x"6D", x"8D", x"D5", x"4E", x"A9", x"6C", x"56", x"F4", x"EA", x"65", x"7A", x"AE", x"08",
    x"BA", x"78", x"25", x"2E", x"1C", x"A6", x"B4", x"C6", x"E8", x"DD", x"74", x"1F", x"4B", x"BD", x"8B", x"8A",
    x"70", x"3E", x"B5", x"66", x"48", x"03", x"F6", x"0E", x"61", x"35", x"57", x"B9", x"86", x"C1", x"1D", x"9E",
    x"E1", x"F8", x"98", x"11", x"69", x"D9", x"8E", x"94", x"9B", x"1E", x"87", x"E9", x"CE", x"55", x"28", x"DF",
    x"8C", x"A1", x"89", x"0D", x"BF", x"E6", x"42", x"68", x"41", x"99", x"2D", x"0F", x"B0", x"54", x"BB", x"16"
  );

  constant AES_INV_SBOX : sbox_t := (
    x"52", x"09", x"6A", x"D5", x"30", x"36", x"A5", x"38", x"BF", x"40", x"A3", x"9E", x"81", x"F3", x"D7", x"FB",
    x"7C", x"E3", x"39", x"82", x"9B", x"2F", x"FF", x"87", x"34", x"8E", x"43", x"44", x"C4", x"DE", x"E9", x"CB",
    x"54", x"7B", x"94", x"32", x"A6", x"C2", x"23", x"3D", x"EE", x"4C", x"95", x"0B", x"42", x"FA", x"C3", x"4E",
    x"08", x"2E", x"A1", x"66", x"28", x"D9", x"24", x"B2", x"76", x"5B", x"A2", x"49", x"6D", x"8B", x"D1", x"25",
    x"72", x"F8", x"F6", x"64", x"86", x"68", x"98", x"16", x"D4", x"A4", x"5C", x"CC", x"5D", x"65", x"B6", x"92",
    x"6C", x"70", x"48", x"50", x"FD", x"ED", x"B9", x"DA", x"5E", x"15", x"46", x"57", x"A7", x"8D", x"9D", x"84",
    x"90", x"D8", x"AB", x"00", x"8C", x"BC", x"D3", x"0A", x"F7", x"E4", x"58", x"05", x"B8", x"B3", x"45", x"06",
    x"D0", x"2C", x"1E", x"8F", x"CA", x"3F", x"0F", x"02", x"C1", x"AF", x"BD", x"03", x"01", x"13", x"8A", x"6B",
    x"3A", x"91", x"11", x"41", x"4F", x"67", x"DC", x"EA", x"97", x"F2", x"CF", x"CE", x"F0", x"B4", x"E6", x"73",
    x"96", x"AC", x"74", x"22", x"E7", x"AD", x"35", x"85", x"E2", x"F9", x"37", x"E8", x"1C", x"75", x"DF", x"6E",
    x"47", x"F1", x"1A", x"71", x"1D", x"29", x"C5", x"89", x"6F", x"B7", x"62", x"0E", x"AA", x"18", x"BE", x"1B",
    x"FC", x"56", x"3E", x"4B", x"C6", x"D2", x"79", x"20", x"9A", x"DB", x"C0", x"FE", x"78", x"CD", x"5A", x"F4",
    x"1F", x"DD", x"A8", x"33", x"88", x"07", x"C7", x"31", x"B1", x"12", x"10", x"59", x"27", x"80", x"EC", x"5F",
    x"60", x"51", x"7F", x"A9", x"19", x"B5", x"4A", x"0D", x"2D", x"E5", x"7A", x"9F", x"93", x"C9", x"9C", x"EF",
    x"A0", x"E0", x"3B", x"4D", x"AE", x"2A", x"F5", x"B0", x"C8", x"EB", x"BB", x"3C", x"83", x"53", x"99", x"61",
    x"17", x"2B", x"04", x"7E", x"BA", x"77", x"D6", x"26", x"E1", x"69", x"14", x"63", x"55", x"21", x"0C", x"7D"
  );

  -- Round constants Rcon[i] for i=1..14 (only first 7 used for AES-256)
  type rcon_array_t is array (1 to 14) of word_t;
  constant AES_RCON : rcon_array_t := (
    1 => x"01000000", 2 => x"02000000", 3 => x"04000000", 4 => x"08000000",
    5 => x"10000000", 6 => x"20000000", 7 => x"40000000", 8 => x"80000000",
    9 => x"1B000000", 10 => x"36000000", 11 => x"6C000000", 12 => x"D8000000",
    13 => x"AB000000", 14 => x"4D000000"
  );

  -- GF(2^8) helpers
  function xtime(b : byte_t) return byte_t;
  function gf_mul(a : byte_t; b : byte_t) return byte_t;

  -- Byte substitution helpers
  function sub_byte(b : byte_t) return byte_t;
  function inv_sub_byte(b : byte_t) return byte_t;

  -- Word helpers for key schedule
  function rot_word(w : word_t) return word_t;
  function sub_word(w : word_t) return word_t;

  -- State helpers
  function sub_bytes_128(state_in : std_logic_vector(127 downto 0)) return std_logic_vector;
  function inv_sub_bytes_128(state_in : std_logic_vector(127 downto 0)) return std_logic_vector;
  function shift_rows(state_in : std_logic_vector(127 downto 0)) return std_logic_vector;
  function inv_shift_rows(state_in : std_logic_vector(127 downto 0)) return std_logic_vector;
  function mix_columns(state_in : std_logic_vector(127 downto 0)) return std_logic_vector;
  function inv_mix_columns(state_in : std_logic_vector(127 downto 0)) return std_logic_vector;

  -- Key expansion (AES-256)
  function expand_key_256(key_in : std_logic_vector(255 downto 0)) return word_array_60_t;
  function build_roundkeys(words : word_array_60_t) return roundkey_array_t;

end package aes_pkg;

package body aes_pkg is

  function xtime(b : byte_t) return byte_t is
    variable result : byte_t;
  begin
    result := std_logic_vector(shift_left(unsigned(b), 1));
    if b(7) = '1' then
      result := result xor x"1B";
    end if;
    return result;
  end function;

  function gf_mul(a : byte_t; b : byte_t) return byte_t is
    variable res  : byte_t := (others => '0');
    variable temp : byte_t := a;
    variable bv   : unsigned(7 downto 0) := unsigned(b);
  begin
    for i in 0 to 7 loop
      if bv(i) = '1' then
        res := res xor temp;
      end if;
      temp := xtime(temp);
    end loop;
    return res;
  end function;

  function sub_byte(b : byte_t) return byte_t is
  begin
    return AES_SBOX(to_integer(unsigned(b)));
  end function;

  function inv_sub_byte(b : byte_t) return byte_t is
  begin
    return AES_INV_SBOX(to_integer(unsigned(b)));
  end function;

  function rot_word(w : word_t) return word_t is
  begin
    return w(23 downto 0) & w(31 downto 24);
  end function;

  function sub_word(w : word_t) return word_t is
    variable b0, b1, b2, b3 : byte_t;
  begin
    b3 := sub_byte(w(31 downto 24));
    b2 := sub_byte(w(23 downto 16));
    b1 := sub_byte(w(15 downto 8));
    b0 := sub_byte(w(7 downto 0));
    return b3 & b2 & b1 & b0;
  end function;

  function sub_bytes_128(state_in : std_logic_vector(127 downto 0)) return std_logic_vector is
    variable out_state : std_logic_vector(127 downto 0);
    variable hi, lo    : integer;
    variable b         : byte_t;
  begin
    for i in 0 to 15 loop
      hi := 127 - 8*i;
      lo := hi - 7;
      b := state_in(hi downto lo);
      out_state(hi downto lo) := sub_byte(b);
    end loop;
    return out_state;
  end function;

  function inv_sub_bytes_128(state_in : std_logic_vector(127 downto 0)) return std_logic_vector is
    variable out_state : std_logic_vector(127 downto 0);
    variable hi, lo    : integer;
    variable b         : byte_t;
  begin
    for i in 0 to 15 loop
      hi := 127 - 8*i;
      lo := hi - 7;
      b := state_in(hi downto lo);
      out_state(hi downto lo) := inv_sub_byte(b);
    end loop;
    return out_state;
  end function;

  function shift_rows(state_in : std_logic_vector(127 downto 0)) return std_logic_vector is
    variable in_b  : byte_array16_t;
    variable out_b : byte_array16_t := (others => (others => '0'));
    variable hi, lo : integer;
    variable res    : std_logic_vector(127 downto 0) := (others => '0');
    variable src_idx : integer;
  begin
    -- unpack
    for i in 0 to 15 loop
      hi := 127 - 8*i;
      lo := hi - 7;
      in_b(i) := state_in(hi downto lo);
    end loop;
    -- shift rows (left by row index)
    for r in 0 to 3 loop
      for c in 0 to 3 loop
        src_idx := 4*((c + r) mod 4) + r;
        out_b(4*c + r) := in_b(src_idx);
      end loop;
    end loop;
    -- pack
    for i in 0 to 15 loop
      hi := 127 - 8*i;
      lo := hi - 7;
      res(hi downto lo) := out_b(i);
    end loop;
    return res;
  end function;

  function inv_shift_rows(state_in : std_logic_vector(127 downto 0)) return std_logic_vector is
    variable in_b  : byte_array16_t;
    variable out_b : byte_array16_t := (others => (others => '0'));
    variable hi, lo : integer;
    variable res    : std_logic_vector(127 downto 0) := (others => '0');
    variable src_idx : integer;
  begin
    -- unpack
    for i in 0 to 15 loop
      hi := 127 - 8*i;
      lo := hi - 7;
      in_b(i) := state_in(hi downto lo);
    end loop;
    -- inverse shift rows (right by row index)
    for r in 0 to 3 loop
      for c in 0 to 3 loop
        src_idx := 4*((c - r + 4) mod 4) + r;
        out_b(4*c + r) := in_b(src_idx);
      end loop;
    end loop;
    -- pack
    for i in 0 to 15 loop
      hi := 127 - 8*i;
      lo := hi - 7;
      res(hi downto lo) := out_b(i);
    end loop;
    return res;
  end function;

  function mix_columns(state_in : std_logic_vector(127 downto 0)) return std_logic_vector is
    variable in_b  : byte_array16_t;
    variable out_b : byte_array16_t := (others => (others => '0'));
    variable hi, lo : integer;
    variable res    : std_logic_vector(127 downto 0) := (others => '0');
    variable a0, a1, a2, a3 : byte_t;
  begin
    -- unpack
    for i in 0 to 15 loop
      hi := 127 - 8*i;
      lo := hi - 7;
      in_b(i) := state_in(hi downto lo);
    end loop;
    -- per column
    for c in 0 to 3 loop
      a0 := in_b(4*c + 0);
      a1 := in_b(4*c + 1);
      a2 := in_b(4*c + 2);
      a3 := in_b(4*c + 3);
      out_b(4*c + 0) := gf_mul(a0, x"02") xor gf_mul(a1, x"03") xor a2 xor a3;
      out_b(4*c + 1) := a0 xor gf_mul(a1, x"02") xor gf_mul(a2, x"03") xor a3;
      out_b(4*c + 2) := a0 xor a1 xor gf_mul(a2, x"02") xor gf_mul(a3, x"03");
      out_b(4*c + 3) := gf_mul(a0, x"03") xor a1 xor a2 xor gf_mul(a3, x"02");
    end loop;
    -- pack
    for i in 0 to 15 loop
      hi := 127 - 8*i;
      lo := hi - 7;
      res(hi downto lo) := out_b(i);
    end loop;
    return res;
  end function;

  function inv_mix_columns(state_in : std_logic_vector(127 downto 0)) return std_logic_vector is
    variable in_b  : byte_array16_t;
    variable out_b : byte_array16_t := (others => (others => '0'));
    variable hi, lo : integer;
    variable res    : std_logic_vector(127 downto 0) := (others => '0');
    variable a0, a1, a2, a3 : byte_t;
  begin
    -- unpack
    for i in 0 to 15 loop
      hi := 127 - 8*i;
      lo := hi - 7;
      in_b(i) := state_in(hi downto lo);
    end loop;
    -- per column
    for c in 0 to 3 loop
      a0 := in_b(4*c + 0);
      a1 := in_b(4*c + 1);
      a2 := in_b(4*c + 2);
      a3 := in_b(4*c + 3);
      out_b(4*c + 0) := gf_mul(a0, x"0E") xor gf_mul(a1, x"0B") xor gf_mul(a2, x"0D") xor gf_mul(a3, x"09");
      out_b(4*c + 1) := gf_mul(a0, x"09") xor gf_mul(a1, x"0E") xor gf_mul(a2, x"0B") xor gf_mul(a3, x"0D");
      out_b(4*c + 2) := gf_mul(a0, x"0D") xor gf_mul(a1, x"09") xor gf_mul(a2, x"0E") xor gf_mul(a3, x"0B");
      out_b(4*c + 3) := gf_mul(a0, x"0B") xor gf_mul(a1, x"0D") xor gf_mul(a2, x"09") xor gf_mul(a3, x"0E");
    end loop;
    -- pack
    for i in 0 to 15 loop
      hi := 127 - 8*i;
      lo := hi - 7;
      res(hi downto lo) := out_b(i);
    end loop;
    return res;
  end function;

  function expand_key_256(key_in : std_logic_vector(255 downto 0)) return word_array_60_t is
    variable w : word_array_60_t;
    variable temp : word_t;
    variable i : integer;
  begin
    -- initial 8 words from key_in (MSB first)
    for k in 0 to 7 loop
      w(k) := key_in(255 - 32*k downto 224 - 32*k);
    end loop;
    i := 8;
    while i < 60 loop
      temp := w(i - 1);
      if (i mod 8) = 0 then
        temp := sub_word(rot_word(temp)) xor AES_RCON(i/8);
      elsif (i mod 8) = 4 then
        temp := sub_word(temp);
      end if;
      w(i) := std_logic_vector(unsigned(w(i - 8)) xor unsigned(temp));
      i := i + 1;
    end loop;
    return w;
  end function;

  function build_roundkeys(words : word_array_60_t) return roundkey_array_t is
    variable rk : roundkey_array_t;
    variable base : integer;
  begin
    for r in 0 to 14 loop
      base := 4*r;
      rk(r) := words(base)(31 downto 0) & words(base+1)(31 downto 0) & words(base+2)(31 downto 0) & words(base+3)(31 downto 0);
      -- Note: words(base) is already big-endian word; concatenation forms 128-bit round key
    end loop;
    return rk;
  end function;

end package body aes_pkg;

