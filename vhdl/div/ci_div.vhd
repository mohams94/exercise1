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
	
		-- constant for setting the number of pipeline stages
	constant STAGES : integer := 48;
	
	-- signals for the components
	signal fifo_q, fifo_data, dividend, divisor : std_logic_vector(31 downto 0) := (others => '0');
	signal result_wire : std_logic_vector(STAGES-1 downto 0) := (others => '0');
	signal fifo_empty, fifo_full, fifo_rd, fifo_wr : std_logic := '0';
	
	
begin
	--result <= result_wire;

	  process(clk)
	  begin
		 if rising_edge(clk) then
			-- State machine for custom instruction
			if reset = '0' then
				--done <= '0';
				--dividend <= (others => '0');
				--divisor <= (others => '0');
				--fifo_data <= (others => '0');
				--fifo_q <= (others => '0');
				--result_wire <= (others => '0');
				--fifo_empty <= '0';
				--fifo_full <= '0';
				--fifo_rd <= '0';
				--fifo_wr <= '0';
			else
				if start = '1' then
					case n(0) is
					  when '0' =>	-- DIV_WRITE
						 -- Issue dataa and datab to division pipeline
						 if fifo_full = '0' then
							 dividend <= dataa;
							 divisor <= datab;
							 fifo_wr <= '1';
							 done <= '1';
						 end if;
						 --State <= DIV_READ;

					  when '1' =>	-- DIV_READ
						 if fifo_empty = '1' then
							-- Wait for result in the FIFO
							done <= '0';
						 else
							-- Read result from FIFO
							result <= fifo_q;
							done <= '1';
							fifo_rd <= '1';
							--State <= IDLE;
						 end if;

					  when others =>
						 --State <= IDLE;
					end case;
				else
					done <= '0';
				end if;
				-- stop writing after one cycle
				if fifo_wr ='1' then
					fifo_wr <= '0';
				end if;
			end if;
		 end if;
	  end process;

	divider : lpm_divide
	generic map(
		LPM_WIDTHN => 32,
		LPM_WIDTHD => 32,
		LPM_PIPELINE => STAGES,
		LPM_DREPRESENTATION => "SIGNED",
		LPM_NREPRESENTATION => "SIGNED")
		
	port map(
		clock => clk,
		clken => '1',
		numer => dividend,
		denom => divisor,
		quotient => result_wire(31 downto 0),
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
