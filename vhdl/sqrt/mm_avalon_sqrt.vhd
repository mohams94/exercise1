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
	
	-- constant for setting the number of pipeline stages
	constant STAGES : integer := 16;
	-- signals for the components
	signal fifo_q, fifo_data : std_logic_vector(31 downto 0) := (others => '0');
	signal sqrt_input : std_logic_vector(63 downto 0) := (others => '0');
	signal sqrt_result : std_logic_vector(31 downto 0) := (others => '0');
	signal fifo_full, fifo_rd, fifo_wr : std_logic := '0';
	signal fifo_empty : std_logic := '1';
	signal error_flag : std_logic := '0';
	signal sqrt_remainder : std_logic_vector(32 downto 0) := (others => '0');
	signal count, count_next : Integer := 0;
	signal shift_reg : std_logic_vector(STAGES-1 downto 0) := (others => '0');
	
	-- flag for second read cycle
	signal read_flag, write_flag, division_flag : std_logic := '0';

begin

	readdata <= (others => '0') when (address(0) ='0' and fifo_empty = '0') else
				(fifo_q) when (address(0) = '1') else
				(others => 'X');
				
    process (all)
    begin
			if rising_edge(clk) then
				if res_n = '0' then
					--fifo_q <= (others => '0');
					sqrt_input <= (others => '0');
					--readdata <= (others => 'X');
					division_flag <= '0';
					fifo_rd <= '0';
					read_flag <= '0';
					fifo_wr <= '0';
					shift_reg <= (others => '0');
					error_flag <= '0';
					--fifo_empty <= '1';
					--fifo_full <= '0';
				else
					if write = '1' and address(0) = '0' then
						sqrt_input <= x"00000000" & writedata;--x"000" & "00" & writedata & "00" & x"0000";
						division_flag <= '1';
					else
						division_flag <= '0';
					end if;
					
					if read = '1' and fifo_empty = '1' then
						--readdata <= (others => 'X');
					elsif read = '1' and fifo_empty = '0' and read_flag = '0' then
						 read_flag <= '1';
						 fifo_rd <= '1';
--						 if address(0) = '0' then
--							   readdata <= x"0000000" & "000" & fifo_empty;
--						 else
--							   readdata <= fifo_q;
--						 end if;
					else
						read_flag <= '0';
						fifo_rd <= '0';
					end if;
					
					if shift_reg(0) = '1' and fifo_full = '0' then
						fifo_wr <= '1';
					else
						fifo_wr <= '0';
					end if;
					shift_reg <= division_flag & shift_reg(STAGES-1 downto 1);
				end if;
        end if;
    end process;

	sqrt: altsqrt
	generic map(
		pipeline => STAGES,
		width => 64,
		Q_PORT_WIDTH => 32,
		R_PORT_WIDTH => 33
	)
	port map(
		--aclr => res_n,
		clk => clk,
		q => sqrt_result,
		radical => sqrt_input,
		remainder => sqrt_remainder
	);
	
	fifo : alt_fwft_fifo
	generic map(DATA_WIDTH => 32,

		NUM_ELEMENTS => 128)

	port map(
		aclr => (not res_n),
		clock => clk,
		data => sqrt_result,
		rdreq => fifo_rd,
		wrreq => fifo_wr,
		empty => fifo_empty,
		full => fifo_full,
		q => fifo_q
	);
	 
end architecture;

