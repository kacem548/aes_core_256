library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aes_types_pkg.all;
use work.aes_tboxes_pkg.all;
use work.aes_round_pkg.all;

entity aes256_core is
  port (
    clk      : in  std_logic;
    rst_n    : in  std_logic;
    start    : in  std_logic;
    decrypt  : in  std_logic; -- '0' encrypt, '1' decrypt
    key      : in  u256;
    data_in  : in  u128;
    done     : out std_logic;
    data_out : out u128
  );
end entity;

architecture rtl of aes256_core is

  component aes256_key_expand is
    port (
      clk       : in  std_logic;
      rst_n     : in  std_logic;
      start     : in  std_logic;
      key_256   : in  u256;
      done      : out std_logic;
      roundkeys : out roundkey_array_t
    );
  end component;

  signal rk_done  : std_logic := '0';
  signal rks      : roundkey_array_t := (others => (others => '0'));

  type state_t is (IDLE, EXPAND, ADDRK, ROUNDS, FINAL, OUTP);
  signal st : state_t := IDLE;
  signal round_idx : integer range 0 to 14 := 0;
  signal state_reg : u128 := (others => '0');

begin

  keyexp: aes256_key_expand
    port map (
      clk       => clk,
      rst_n     => rst_n,
      start     => (start and (st = IDLE)),
      key_256   => key,
      done      => rk_done,
      roundkeys => rks
    );

  process(clk, rst_n)
  begin
    if rst_n = '0' then
      st        <= IDLE;
      done      <= '0';
      state_reg <= (others => '0');
      round_idx <= 0;
    elsif rising_edge(clk) then
      case st is
        when IDLE =>
          done <= '0';
          if start = '1' then
            st <= EXPAND;
          end if;

        when EXPAND =>
          if rk_done = '1' then
            if decrypt = '0' then
              state_reg <= data_in xor rks(0);
            else
              state_reg <= data_in xor rks(14);
            end if;
            round_idx <= 1;
            st <= ROUNDS;
          end if;

        when ROUNDS =>
          if round_idx < 14 then
            if decrypt = '0' then
              state_reg <= enc_full_round(state_reg, rks(round_idx));
            else
              state_reg <= dec_full_round(state_reg, rks(14 - round_idx));
            end if;
            round_idx <= round_idx + 1;
          else
            st <= FINAL;
          end if;

        when FINAL =>
          if decrypt = '0' then
            data_out <= enc_final_round(state_reg, rks(14));
          else
            data_out <= dec_final_round(state_reg, rks(0));
          end if;
          st <= OUTP;

        when OUTP =>
          done <= '1';
          st   <= IDLE;
        when others => null;
      end case;
    end if;
  end process;

end architecture;

