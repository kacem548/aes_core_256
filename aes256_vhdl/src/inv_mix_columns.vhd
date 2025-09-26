library ieee;
use ieee.std_logic_1164.all;
use work.aes_pkg.all;

entity inv_mix_columns is
	port(
		state_in  : in  std_logic_vector(127 downto 0);
		state_out : out std_logic_vector(127 downto 0)
	);
end entity;

architecture rtl of inv_mix_columns is
begin
	state_out <= aes_pkg.inv_mix_columns(state_in);
end architecture;

