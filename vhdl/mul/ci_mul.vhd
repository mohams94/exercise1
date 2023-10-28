-- altera vhdl_input_version vhdl_2008
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


LIBRARY lpm;
USE lpm.lpm_components.all;

entity ci_mul is
	port (
		clk   : in std_logic;
		clk_en : in std_logic;
		reset : in std_logic;
		
		dataa : in std_logic_vector(31 downto 0); 
		datab : in std_logic_vector(31 downto 0);
		result : out std_logic_vector(31 downto 0)
	);
end entity;


architecture arch of ci_mul is 
	-- result of 32x32 bit multiplication has a width of 64 bits
	signal result_wire : std_logic_vector(63 downto 0) := (others => '0');
begin
	u1: lpm_mult
		generic map(LPM_WIDTHA => 32, LPM_WIDTHB => 32, LPM_WIDTHP => 64, LPM_PIPELINE => 1)
			port map(
						clock => clk,
						clken => clk_en,
						dataa => dataa,
						datab => datab,
						result => result_wire,
						sum => (others => '0'));

		result <= result_wire(47 downto 16);
end architecture;

