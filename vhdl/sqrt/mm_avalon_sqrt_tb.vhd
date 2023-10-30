library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
--use work.tb_util_pkg.all;
--use ieee.fixed_pkg.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

entity avalon_mm_sqrt_tb is
end entity;

architecture bench of avalon_mm_sqrt_tb is

	component avalon_mm_sqrt is
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
	end component;

	signal clk, res_n, write, read : std_logic := '0';
	signal address   :  std_logic_vector(0 downto 0);
	signal writedata, readdata : std_logic_vector(31 downto 0);
	constant CLK_PERIOD : time := 10 ns;
	constant stop_clock : boolean := false;
	--variable a, b, c, d, e, f : real;

begin

	uut : avalon_mm_sqrt
		port map (
			clk   => clk,
			res_n => res_n,
			address => address,
			write  => write,
			read => read,
			writedata => writedata,
			readdata => readdata
		);

	stimulus : process
	begin
		wait for CLK_PERIOD * 5;
		res_n <= '1';
		wait until rising_edge(clk);
		res_n <= '0';											
		wait until rising_edge(clk);
		res_n <= '1';
		read <= '0';
		write <= '0';
		wait for CLK_PERIOD * 2;
		address(0) <= '0';
		write <= '1';
		writedata <= x"00040000";
		wait until rising_edge(clk);
		write <= '0';
		wait for CLK_PERIOD * 2;
		write <= '1';
		writedata <= x"00090000";
		wait until rising_edge(clk);
		write <= '0';
		wait for CLK_PERIOD * 20;
		read <= '1';
		wait for CLK_PERIOD * 2;
		read <= '0';
		wait for CLK_PERIOD * 5;
		address(0) <= '1';
		wait until rising_edge(clk);
		read <= '1';
		wait for CLK_PERIOD * 2;
		read <= '0';
		wait for CLK_PERIOD * 20;
		read <= '1';
		wait for CLK_PERIOD * 2;
		read <= '0';
		wait for CLK_PERIOD * 5;
		
		wait;
	end process;

	
	
	generate_clk : process
	begin
		while not stop_clock loop
			clk <= '0', '1' after CLK_PERIOD / 2;
			wait for CLK_PERIOD;
		end loop;
		wait;
	end process;

end architecture;
