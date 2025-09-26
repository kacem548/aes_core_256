library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_pkg.all;

entity aes256_encrypt is
	port(
		key256    : in  std_logic_vector(255 downto 0);
		plaintext : in  std_logic_vector(127 downto 0);
		ciphertext: out std_logic_vector(127 downto 0)
	);
end entity;

architecture rtl of aes256_encrypt is
begin
	process(key256, plaintext)
		variable rk : round_keys_t;
		variable s  : std_logic_vector(127 downto 0);
	begin
		rk := key_expand_256(key256);
		-- Initial AddRoundKey with rk(0)
		s := add_round_key(plaintext, rk(0));
		-- 13 main rounds
		for r in 1 to 13 loop
			s := aes_pkg.sub_bytes(s);
			s := aes_pkg.shift_rows(s);
			s := aes_pkg.mix_columns(s);
			s := add_round_key(s, rk(r));
		end loop;
		-- Final round (no MixColumns)
		s := aes_pkg.sub_bytes(s);
		s := aes_pkg.shift_rows(s);
		s := add_round_key(s, rk(14));
		ciphertext <= s;
	end process;
end architecture;

