library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aes_pkg.all;

-- Combinational AES-256 key expansion. Generates 15 round keys (0..14), 128-bit each.
entity key_expand_aes256 is
  port (
    key_in          : in  std_logic_vector(255 downto 0);
    round_keys_flat : out std_logic_vector((15*128)-1 downto 0)
  );
end entity key_expand_aes256;

architecture rtl of key_expand_aes256 is
  subtype word_t is std_logic_vector(31 downto 0);
  type words60_t is array (0 to 59) of word_t;

  function rcon_word(idx : integer) return word_t is
    variable w : word_t := (others => '0');
  begin
    if idx >= 1 and idx <= 14 then
      w(31 downto 24) := RCON(idx);
    end if;
    return w;
  end function;

  function expand256(k : std_logic_vector(255 downto 0)) return std_logic_vector is
    variable w : words60_t;
    variable out_flat : std_logic_vector((15*128)-1 downto 0);
    variable temp : word_t;
  begin
    -- Initial 8 words from 256-bit key (w0..w7)
    w(0) := k(255 downto 224);
    w(1) := k(223 downto 192);
    w(2) := k(191 downto 160);
    w(3) := k(159 downto 128);
    w(4) := k(127 downto 96);
    w(5) := k(95 downto 64);
    w(6) := k(63 downto 32);
    w(7) := k(31 downto 0);

    for i in 8 to 59 loop
      temp := w(i-1);
      if (i mod 8) = 0 then
        temp := sub_word(rot_word(temp)) xor rcon_word(i/8);
      elsif (i mod 8) = 4 then
        temp := sub_word(temp);
      end if;
      w(i) := std_logic_vector(unsigned(w(i-8)) xor unsigned(temp));
    end loop;

    -- Pack into 15 round keys, each 4 words
    for r in 0 to 14 loop
      out_flat(((15-1-r)*128)+127 downto ((15-1-r)*128)) := w(4*r) & w(4*r+1) & w(4*r+2) & w(4*r+3);
    end loop;

    return out_flat;
  end function;

begin
  round_keys_flat <= expand256(key_in);
end architecture rtl;

