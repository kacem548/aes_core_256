library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package aes_tboxes_pkg is
  subtype u8  is std_logic_vector(7 downto 0);
  subtype u32 is std_logic_vector(31 downto 0);

  type tbox32_t is array (0 to 255) of u32;
  type tbox8_t  is array (0 to 255) of u8;

  -- Encryption T-boxes (from OpenSSL Te0..Te3)
  constant Te0 : tbox32_t;
  constant Te1 : tbox32_t;
  constant Te2 : tbox32_t;
  constant Te3 : tbox32_t;
  -- S-box for final round (equivalent to Te4)
  constant Te4 : tbox8_t;

  -- Decryption T-boxes (Td0..Td3) and Td4 (inverse S)
  constant Td0 : tbox32_t;
  constant Td1 : tbox32_t;
  constant Td2 : tbox32_t;
  constant Td3 : tbox32_t;
  constant Td4 : tbox8_t;

end package;

package body aes_tboxes_pkg is

  -- Placeholders; to be filled with OpenSSL constants
  constant Te0 : tbox32_t := (others => (others => '0'));
  constant Te1 : tbox32_t := (others => (others => '0'));
  constant Te2 : tbox32_t := (others => (others => '0'));
  constant Te3 : tbox32_t := (others => (others => '0'));
  constant Te4 : tbox8_t  := (others => (others => '0'));

  constant Td0 : tbox32_t := (others => (others => '0'));
  constant Td1 : tbox32_t := (others => (others => '0'));
  constant Td2 : tbox32_t := (others => (others => '0'));
  constant Td3 : tbox32_t := (others => (others => '0'));
  constant Td4 : tbox8_t  := (others => (others => '0'));

end package body;

