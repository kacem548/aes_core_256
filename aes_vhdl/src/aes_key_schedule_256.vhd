library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_pkg.all;

entity aes_key_schedule_256 is
  port (
    key_i    : in  std_logic_vector(255 downto 0);
    round_i  : in  std_logic_vector(3 downto 0); -- 0..14
    rkey_o   : out std_logic_vector(127 downto 0)
  );
end entity aes_key_schedule_256;

architecture rtl of aes_key_schedule_256 is
  signal words_s      : word_array_60_t;
  signal roundkeys_s  : roundkey_array_t;
begin
  words_s     <= expand_key_256(key_i);
  roundkeys_s <= build_roundkeys(words_s);

  process(roundkeys_s, round_i)
    variable idx : integer;
  begin
    idx := to_integer(unsigned(round_i));
    if idx >= 0 and idx <= 14 then
      rkey_o <= roundkeys_s(idx);
    else
      rkey_o <= (others => '0');
    end if;
  end process;
end architecture rtl;

