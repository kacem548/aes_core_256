library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package aes_types_pkg is
  subtype u8  is std_logic_vector(7 downto 0);
  subtype u32 is std_logic_vector(31 downto 0);
  subtype u128 is std_logic_vector(127 downto 0);
  subtype u256 is std_logic_vector(255 downto 0);

  type u32x4 is array (0 to 3) of u32;
  type roundkey_array_t is array (0 to 14) of u128; -- AES-256 has Nr=14

  -- Rcon as 32-bit words for key expansion
  constant RCON : array (0 to 9) of u32 := (
    x"01000000", x"02000000", x"04000000", x"08000000",
    x"10000000", x"20000000", x"40000000", x"80000000",
    x"1B000000", x"36000000"
  );

end package;

package body aes_types_pkg is
end package body;

