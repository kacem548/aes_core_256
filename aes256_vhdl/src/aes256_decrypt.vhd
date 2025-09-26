library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_pkg.all;

entity aes256_decrypt is
	port(
		key256     : in  std_logic_vector(255 downto 0);
		ciphertext : in  std_logic_vector(127 downto 0);
		plaintext  : out std_logic_vector(127 downto 0)
	);
end entity;

architecture rtl of aes256_decrypt is
begin
	process(key256, ciphertext)
		variable rk : round_keys_t;
		variable s  : std_logic_vector(127 downto 0);
	begin
		rk := key_expand_256(key256);
		-- Initial AddRoundKey with last key
		s := add_round_key(ciphertext, rk(14));
		-- 13 main inverse rounds
		for r in 13 downto 1 loop
			s := aes_pkg.inv_shift_rows(s);
			s := aes_pkg.inv_sub_bytes(s);
			s := add_round_key(s, rk(r));
			s := aes_pkg.inv_mix_columns(s);
		end loop;
		-- Final inverse round
		s := aes_pkg.inv_shift_rows(s);
		s := aes_pkg.inv_sub_bytes(s);
		s := add_round_key(s, rk(0));
		plaintext <= s;
	end process;
end architecture;

