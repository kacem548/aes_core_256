library ieee;
use ieee.std_logic_1164.all;
use work.aes_pkg.all;

entity shift_rows is
	port(
		state_in  : in  std_logic_vector(127 downto 0);
		state_out : out std_logic_vector(127 downto 0)
	);
end entity;

architecture rtl of shift_rows is
begin
	state_out <= aes_pkg.shift_rows(state_in);
end architecture;

