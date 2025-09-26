library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aes_types_pkg.all;
use work.aes_tboxes_pkg.all;

package aes_round_pkg is

  function enc_full_round(state : u128; rk : u128) return u128;
  function enc_final_round(state : u128; rk : u128) return u128;

  function dec_full_round(state : u128; rk : u128) return u128;
  function dec_final_round(state : u128; rk : u128) return u128;

end package;

package body aes_round_pkg is

  function word_xor(a, b : u32) return u32 is
  begin
    return std_logic_vector(unsigned(a) xor unsigned(b));
  end function;

  function get_w(b3, b2, b1, b0 : u8) return u32 is
  begin
    return b3 & b2 & b1 & b0;
  end function;

  procedure split_state(state : in u128; s0, s1, s2, s3 : out u32) is
  begin
    s0 := state(127 downto 96);
    s1 := state(95 downto 64);
    s2 := state(63 downto 32);
    s3 := state(31 downto 0);
  end procedure;

  function enc_full_round(state : u128; rk : u128) return u128 is
    variable s0, s1, s2, s3 : u32;
    variable t0, t1, t2, t3 : u32;
    variable r0, r1, r2, r3 : u32;
  begin
    split_state(state, s0, s1, s2, s3);
    t0 := word_xor(word_xor(word_xor(Te0(to_integer(unsigned(s0(31 downto 24)))), Te1(to_integer(unsigned(s1(23 downto 16))))), word_xor(Te2(to_integer(unsigned(s2(15 downto 8)))), Te3(to_integer(unsigned(s3(7 downto 0)))))), rk(127 downto 96));
    t1 := word_xor(word_xor(word_xor(Te0(to_integer(unsigned(s1(31 downto 24)))), Te1(to_integer(unsigned(s2(23 downto 16))))), word_xor(Te2(to_integer(unsigned(s3(15 downto 8)))), Te3(to_integer(unsigned(s0(7 downto 0)))))), rk(95 downto 64));
    t2 := word_xor(word_xor(word_xor(Te0(to_integer(unsigned(s2(31 downto 24)))), Te1(to_integer(unsigned(s3(23 downto 16))))), word_xor(Te2(to_integer(unsigned(s0(15 downto 8)))), Te3(to_integer(unsigned(s1(7 downto 0)))))), rk(63 downto 32));
    t3 := word_xor(word_xor(word_xor(Te0(to_integer(unsigned(s3(31 downto 24)))), Te1(to_integer(unsigned(s0(23 downto 16))))), word_xor(Te2(to_integer(unsigned(s1(15 downto 8)))), Te3(to_integer(unsigned(s2(7 downto 0)))))), rk(31 downto 0));
    return t0 & t1 & t2 & t3;
  end function;

  function enc_final_round(state : u128; rk : u128) return u128 is
    variable s0, s1, s2, s3 : u32;
    variable t0, t1, t2, t3 : u32;
  begin
    split_state(state, s0, s1, s2, s3);
    t0 := get_w(Te4(to_integer(unsigned(s0(31 downto 24)))), Te4(to_integer(unsigned(s1(23 downto 16)))), Te4(to_integer(unsigned(s2(15 downto 8)))), Te4(to_integer(unsigned(s3(7 downto 0)))));
    t1 := get_w(Te4(to_integer(unsigned(s1(31 downto 24)))), Te4(to_integer(unsigned(s2(23 downto 16)))), Te4(to_integer(unsigned(s3(15 downto 8)))), Te4(to_integer(unsigned(s0(7 downto 0)))));
    t2 := get_w(Te4(to_integer(unsigned(s2(31 downto 24)))), Te4(to_integer(unsigned(s3(23 downto 16)))), Te4(to_integer(unsigned(s0(15 downto 8)))), Te4(to_integer(unsigned(s1(7 downto 0)))));
    t3 := get_w(Te4(to_integer(unsigned(s3(31 downto 24)))), Te4(to_integer(unsigned(s0(23 downto 16)))), Te4(to_integer(unsigned(s1(15 downto 8)))), Te4(to_integer(unsigned(s2(7 downto 0)))));
    return (word_xor(t0, rk(127 downto 96))) & (word_xor(t1, rk(95 downto 64))) & (word_xor(t2, rk(63 downto 32))) & (word_xor(t3, rk(31 downto 0)));
  end function;

  function dec_full_round(state : u128; rk : u128) return u128 is
    variable s0, s1, s2, s3 : u32;
    variable t0, t1, t2, t3 : u32;
    variable r0, r1, r2, r3 : u32;
  begin
    split_state(state, s0, s1, s2, s3);
    t0 := word_xor(word_xor(word_xor(Td0(to_integer(unsigned(s0(31 downto 24)))), Td1(to_integer(unsigned(s3(23 downto 16))))), word_xor(Td2(to_integer(unsigned(s2(15 downto 8)))), Td3(to_integer(unsigned(s1(7 downto 0)))))), rk(127 downto 96));
    t1 := word_xor(word_xor(word_xor(Td0(to_integer(unsigned(s1(31 downto 24)))), Td1(to_integer(unsigned(s0(23 downto 16))))), word_xor(Td2(to_integer(unsigned(s3(15 downto 8)))), Td3(to_integer(unsigned(s2(7 downto 0)))))), rk(95 downto 64));
    t2 := word_xor(word_xor(word_xor(Td0(to_integer(unsigned(s2(31 downto 24)))), Td1(to_integer(unsigned(s1(23 downto 16))))), word_xor(Td2(to_integer(unsigned(s0(15 downto 8)))), Td3(to_integer(unsigned(s3(7 downto 0)))))), rk(63 downto 32));
    t3 := word_xor(word_xor(word_xor(Td0(to_integer(unsigned(s3(31 downto 24)))), Td1(to_integer(unsigned(s2(23 downto 16))))), word_xor(Td2(to_integer(unsigned(s1(15 downto 8)))), Td3(to_integer(unsigned(s0(7 downto 0)))))), rk(31 downto 0));
    return t0 & t1 & t2 & t3;
  end function;

  function dec_final_round(state : u128; rk : u128) return u128 is
    variable s0, s1, s2, s3 : u32;
    variable t0, t1, t2, t3 : u32;
  begin
    split_state(state, s0, s1, s2, s3);
    t0 := get_w(Td4(to_integer(unsigned(s0(31 downto 24)))), Td4(to_integer(unsigned(s3(23 downto 16)))), Td4(to_integer(unsigned(s2(15 downto 8)))), Td4(to_integer(unsigned(s1(7 downto 0)))));
    t1 := get_w(Td4(to_integer(unsigned(s1(31 downto 24)))), Td4(to_integer(unsigned(s0(23 downto 16)))), Td4(to_integer(unsigned(s3(15 downto 8)))), Td4(to_integer(unsigned(s2(7 downto 0)))));
    t2 := get_w(Td4(to_integer(unsigned(s2(31 downto 24)))), Td4(to_integer(unsigned(s1(23 downto 16)))), Td4(to_integer(unsigned(s0(15 downto 8)))), Td4(to_integer(unsigned(s3(7 downto 0)))));
    t3 := get_w(Td4(to_integer(unsigned(s3(31 downto 24)))), Td4(to_integer(unsigned(s2(23 downto 16)))), Td4(to_integer(unsigned(s1(15 downto 8)))), Td4(to_integer(unsigned(s0(7 downto 0)))));
    return (word_xor(t0, rk(127 downto 96))) & (word_xor(t1, rk(95 downto 64))) & (word_xor(t2, rk(63 downto 32))) & (word_xor(t3, rk(31 downto 0)));
  end function;

end package body;

