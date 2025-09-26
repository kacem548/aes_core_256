library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_pkg.all;

entity tb_addroundkey is end entity;

architecture sim of tb_addroundkey is
  signal s_in  : state_t;
  signal rk    : state_t;
  signal s_out : state_t;
begin
  dut: entity work.addroundkey
    port map(
      state_in  => s_in,
      round_key => rk,
      state_out => s_out
    );

  process
  begin
    for i in 0 to 15 loop
      s_in(i) <= std_logic_vector(to_unsigned(i*3 mod 256, 8));
      rk(i)   <= std_logic_vector(to_unsigned(255 - i, 8));
    end loop;
    wait for 10 ns;

    for i in 0 to 15 loop
      assert s_out(i) = std_logic_vector(unsigned(s_in(i)) xor unsigned(rk(i)))
        report "XOR mismatch at byte" severity error;
    end loop;
    report "tb_addroundkey passed" severity note;
    wait;
  end process;
end architecture;

