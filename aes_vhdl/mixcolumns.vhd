library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aes_pkg.all;

entity mixcolumns is
  port (
    s_in  : in  state128_t;
    s_out : out state128_t
  );
end entity;

architecture rtl of mixcolumns is
begin
  process(s_in)
    variable tmp : state128_t;
  begin
    mix_columns(s_in, tmp);
    s_out <= tmp;
  end process;
end architecture;

