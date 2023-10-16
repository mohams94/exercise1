
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
	--if you want to add further inputs/outputs, use the input/output
	-- names already defined in the pin planner
	port (
		clk    : in std_logic;
		
		keys : in std_logic_vector(3 downto 0);
		ledg : out std_logic_vector(8 downto 0);
		ledr : out std_logic_vector(17 downto 0)
	);
end entity;

architecture arch of top is

    component gettoknow is
        port (
            clk_clk       : in std_logic := 'X'; -- clk
            reset_reset_n : in std_logic := 'X'  -- reset_n
        );
    end component gettoknow;
	 
begin
    u0 : component gettoknow
        port map (
            clk_clk       => clk,       --   clk.clk
            reset_reset_n => keys(0)  -- reset.reset_n
        );
	-- create an instance of your Platform Desginer system here.
	-- use "Generate"->"Show Instantiation Template" 
	
	-- use key(0) as reset for the Platform Desginer system
	ledg <= (others=>'0');
	ledr <= (others=>'0');
end architecture;

