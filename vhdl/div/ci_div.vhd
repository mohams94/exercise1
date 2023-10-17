-- altera vhdl_input_version vhdl_2008
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library lpm;
use lpm.lpm_components.all;

entity ci_div is
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
end entity;


architecture arch of ci_div is

	component alt_fwft_fifo is
		generic (
			DATA_WIDTH : integer := 32;
			NUM_ELEMENTS : integer 
			);
		port (
			aclr		: IN STD_LOGIC ;
			clock		: IN STD_LOGIC ;
			data		: IN STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
			rdreq		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			empty		: OUT STD_LOGIC ;
			full		: OUT STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0)
			);
	end component;

	signal fifo_q, fifo_data : std_logic_vector(31 downto 0);
	signal dividend, divisor, result_wire : std_logic_vector(31 downto 0);
	signal fifo_empty, fifo_full, fifo_rd, fifo_wr : std_logic;
	constant STAGES : integer := 48;
	
begin

	done <= '0';
	dividend <= (others => '0');
	divisor <= (others => '0');
	--result <= result_wire;

	divider : lpm_divide
	generic map(
		LPM_WIDTHN => STAGES,
		LPM_WIDTHD => STAGES,
		LPM_PIPELINE => STAGES,
		LPM_DREPRESENTATION => "SIGNED",
		LPM_NREPRESENTATION => "SIGNED")
	port map(
		clock => clk,
		clken => '1',
		numer => dividend,
		denom => divisor,
		quotient => result,
		remain => open
	);

		fifo : alt_fwft_fifo
	generic map(DATA_WIDTH => 32,
		NUM_ELEMENTS => 128)

	port map(
		aclr => reset,
		clock => clk,
		data => result_wire(31 downto 0),
		rdreq => fifo_rd,
		wrreq => fifo_wr,
		empty => fifo_empty,
		full => fifo_full,
		q => fifo_q
	);

end architecture;

