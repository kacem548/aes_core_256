library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_aes256 is
end entity;

architecture sim of tb_aes256 is
	component aes256_core is
		port(
			enc_dec   : in  std_logic; -- '1' encrypt, '0' decrypt
			key256    : in  std_logic_vector(255 downto 0);
			data_in   : in  std_logic_vector(127 downto 0);
			data_out  : out std_logic_vector(127 downto 0)
		);
	end component;

	signal enc_dec   : std_logic := '1';
	signal key256    : std_logic_vector(255 downto 0);
	signal data_in   : std_logic_vector(127 downto 0);
	signal data_out  : std_logic_vector(127 downto 0);

begin
	duv: aes256_core port map(enc_dec => enc_dec, key256 => key256, data_in => data_in, data_out => data_out);

	stim: process
		-- NIST AES-256 KAT (SP 800-38A F.5.5):
		-- key = 000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F
		-- pt  = 00112233445566778899AABBCCDDEEFF
		-- ct  = 8EA2B7CA516745BFEAFC49904B496089
	begin
		key256  <= x"000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F";
		data_in <= x"00112233445566778899AABBCCDDEEFF";
		enc_dec <= '1';
		wait for 1 ns;
		assert data_out = x"8EA2B7CA516745BFEAFC49904B496089" report "AES-256 encrypt failed" severity error;

		-- Decrypt check
		data_in <= x"8EA2B7CA516745BFEAFC49904B496089";
		enc_dec <= '0';
		wait for 1 ns;
		assert data_out = x"00112233445566778899AABBCCDDEEFF" report "AES-256 decrypt failed" severity error;

		report "All tests passed" severity note;
		wait;
	end process;

end architecture;

