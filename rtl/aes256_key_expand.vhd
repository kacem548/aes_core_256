library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aes_types_pkg.all;
use work.aes_tboxes_pkg.all;

entity aes256_key_expand is
  port (
    clk       : in  std_logic;
    rst_n     : in  std_logic;
    start     : in  std_logic;
    key_256   : in  u256;
    done      : out std_logic;
    roundkeys : out roundkey_array_t
  );
end entity;

architecture rtl of aes256_key_expand is

  -- using u256 from aes_types_pkg

  function sub_word32(w : u32) return u32 is
    variable r : u32;
  begin
    r(31 downto 24) := Te4(to_integer(unsigned(w(31 downto 24))));
    r(23 downto 16) := Te4(to_integer(unsigned(w(23 downto 16))));
    r(15 downto 8)  := Te4(to_integer(unsigned(w(15 downto 8))));
    r(7 downto 0)   := Te4(to_integer(unsigned(w(7 downto 0))));
    return r;
  end function;

  function rot_word32(w : u32) return u32 is
  begin
    return w(23 downto 0) & w(31 downto 24);
  end function;

  type state_t is (IDLE, RUN, FINISH);
  signal st : state_t := IDLE;

  signal W : array (0 to 59) of u32; -- AES-256 expands to 60 words
  signal rk : roundkey_array_t;
  signal idx : integer range 0 to 59 := 0;

begin

  process(clk, rst_n)
  begin
    if rst_n = '0' then
      st   <= IDLE;
      idx  <= 0;
      done <= '0';
      rk   <= (others => (others => '0'));
    elsif rising_edge(clk) then
      case st is
        when IDLE =>
          done <= '0';
          if start = '1' then
            -- load initial key words
            W(0) <= key_256(255 downto 224);
            W(1) <= key_256(223 downto 192);
            W(2) <= key_256(191 downto 160);
            W(3) <= key_256(159 downto 128);
            W(4) <= key_256(127 downto 96);
            W(5) <= key_256(95 downto 64);
            W(6) <= key_256(63 downto 32);
            W(7) <= key_256(31 downto 0);
            idx  <= 8;
            st   <= RUN;
          end if;

        when RUN =>
          -- compute W(idx) based on AES-256 schedule
          -- temp depends on idx mod 8
          variable temp : u32;
          variable rconi : u32;
        begin
          temp := W(idx-1);
          if (idx mod 8) = 0 then
            rconi := RCON((idx/8)-1);
            temp := std_logic_vector(unsigned(sub_word32(rot_word32(W(idx-1)))) xor unsigned(rconi));
          elsif (idx mod 8) = 4 then
            temp := sub_word32(W(idx-1));
          end if;
          W(idx) <= std_logic_vector(unsigned(W(idx-8)) xor unsigned(temp));

          if idx = 59 then
            -- pack into round keys
            rk(0)  <= W(0) & W(1) & W(2) & W(3);
            rk(1)  <= W(4) & W(5) & W(6) & W(7);
            rk(2)  <= W(8) & W(9) & W(10) & W(11);
            rk(3)  <= W(12) & W(13) & W(14) & W(15);
            rk(4)  <= W(16) & W(17) & W(18) & W(19);
            rk(5)  <= W(20) & W(21) & W(22) & W(23);
            rk(6)  <= W(24) & W(25) & W(26) & W(27);
            rk(7)  <= W(28) & W(29) & W(30) & W(31);
            rk(8)  <= W(32) & W(33) & W(34) & W(35);
            rk(9)  <= W(36) & W(37) & W(38) & W(39);
            rk(10) <= W(40) & W(41) & W(42) & W(43);
            rk(11) <= W(44) & W(45) & W(46) & W(47);
            rk(12) <= W(48) & W(49) & W(50) & W(51);
            rk(13) <= W(52) & W(53) & W(54) & W(55);
            rk(14) <= W(56) & W(57) & W(58) & W(59);
            st     <= FINISH;
          else
            idx <= idx + 1;
          end if;

        when FINISH =>
          done      <= '1';
          roundkeys <= rk;
          st        <= IDLE;
        when others => null;
      end case;
    end if;
  end process;

end architecture;

