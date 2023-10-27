library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
--use work.tb_util_pkg.all;
--use ieee.fixed_pkg.all;

LIBRARY lpm;
USE lpm.lpm_components.all;

entity ci_div_tb is
end entity;

architecture bench of ci_div_tb is

	component ci_div is
	port (
		clk   : in std_logic;
		clk_en : in std_logic;
		reset : in std_logic;
		
		dataa : in std_logic_vector(31 downto 0); 
		datab : in std_logic_vector(31 downto 0);
		result : out std_logic_vector(31 downto 0);

		start : in std_logic;
		done : out std_logic;
		
		n : in std_logic_vector(0 downto 0)
	);
	end component;

	signal clk, clk_en, reset, start, done : std_logic := '0';
	signal dataa, datab, result : std_logic_vector(31 downto 0);
	signal n : std_logic_vector(0 downto 0);
	constant CLK_PERIOD : time := 10 ns;
	constant stop_clock : boolean := false;
	--variable a, b, c, d, e, f : real;

begin

	uut : ci_div
		port map (
			clk   => clk,
			clk_en => '1',
			reset => reset,
			dataa => dataa,
			datab  => datab,
			n => n,
			done => done,
			start => start,
			result => result
		);

	stimulus : process
	begin
		dataa <= (others=>'1');
		datab <= (others=>'1');
		wait for CLK_PERIOD * 5;
		reset <= '0';
		wait until rising_edge(clk);
		reset <= '1';
		wait until rising_edge(clk);
		reset <= '0';
		n(0) <= '0';
		start <= '0';
		wait until rising_edge(clk);
		start <= '1';
		wait until rising_edge(clk);
		start <= '0';
		wait until rising_edge(clk);
		dataa <= x"12345678";
		datab <= x"12345678";
		start <= '1';
		wait until rising_edge(clk);
		start <= '0';
		wait for CLK_PERIOD*5;
		n(0) <= '1';
		start <= '1';
		wait until rising_edge(clk);
		start <= '0';
		--wait for CLK_PERIOD*70;

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