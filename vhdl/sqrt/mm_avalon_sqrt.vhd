-- altera vhdl_input_version vhdl_2008
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
USE lpm.lpm_components.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

entity avalon_mm_sqrt is
	port (
		clk   : in std_logic;
		res_n : in std_logic;
		
		--memory mapped slave
		address   : in  std_logic_vector(0 downto 0);
		write     : in  std_logic;
		read      : in  std_logic;
		writedata : in  std_logic_vector(31 downto 0);
		readdata  : out std_logic_vector(31 downto 0)
	);
end entity;


architecture rtl of avalon_mm_sqrt is
begin
end architecture;

