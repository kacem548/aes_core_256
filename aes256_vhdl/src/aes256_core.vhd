library ieee;
use ieee.std_logic_1164.all;

entity aes256_core is
	port(
		enc_dec   : in  std_logic; -- '1' encrypt, '0' decrypt
		key256    : in  std_logic_vector(255 downto 0);
		data_in   : in  std_logic_vector(127 downto 0);
		data_out  : out std_logic_vector(127 downto 0)
	);
end entity;

architecture rtl of aes256_core is
	component aes256_encrypt is
		port(
			key256    : in  std_logic_vector(255 downto 0);
			plaintext : in  std_logic_vector(127 downto 0);
			ciphertext: out std_logic_vector(127 downto 0)
		);
	end component;

	component aes256_decrypt is
		port(
			key256     : in  std_logic_vector(255 downto 0);
			ciphertext : in  std_logic_vector(127 downto 0);
			plaintext  : out std_logic_vector(127 downto 0)
		);
	end component;

	signal enc_out, dec_out : std_logic_vector(127 downto 0);
begin
	enc_i: aes256_encrypt port map(key256 => key256, plaintext => data_in, ciphertext => enc_out);
	dec_i: aes256_decrypt port map(key256 => key256, ciphertext => data_in, plaintext => dec_out);

	data_out <= enc_out when enc_dec = '1' else dec_out;
end architecture;

