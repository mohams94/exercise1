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
	signal fifo_data, result_wire, dividend, divisor : std_logic_vector(31 downto 0) := (others => '0');
	signal fifo_empty, fifo_full, fifo_rd, fifo_wr : std_logic := '0';
	signal fifo_q : std_logic_vector(31 downto 0) := (others => '0');
	
	type State_Type_0 is (IDLE, STALL);
	type State_Type_1 is (IDLE, DIV_READ, SLEEP);
	signal state_0, next_state_0 : State_Type_0 := IDLE;
	signal state_1, next_state_1 : State_Type_1 := SLEEP;
   signal counter : Integer := 0;
	
	
begin
	--result <= result_wire;
	  process(clk)
	  begin
		 if rising_edge(clk) then
		-- ################# div_write
			if n(0) = '0' then
			state_0 <= next_state_0;
				case state_0 is
					when IDLE =>
						done <= '0';
						fifo_wr <= '0';
						if start = '1' then
							dividend <= dataa;
							divisor <= datab;
						end if;
						counter <= 0;
						next_state_0 <= STALL;
					when STALL =>
						if counter = STAGES then	-- state machine delayed by 2 clock cycles
							done <= '1';
							fifo_wr <= '1';
							fifo_data <= result_wire;
							result <= result_wire;
							next_state_0 <= IDLE;
						else
							counter <= counter + 1;
							next_state_0 <= STALL;
						end if;
					when others =>
						next_state_0 <= IDLE;
				end case;
			-- #################   div_read
			else	
			state_1 <= next_state_1;
				case state_1 is
					when SLEEP =>
						if start = '1' then
							next_state_1 <= IDLE;
						end if;
					when IDLE =>
						fifo_rd <= '0';
						if fifo_empty = '0' then
							next_state_1 <= DIV_READ;
						else
							next_state_1 <= IDLE;
						end if;
					when DIV_READ =>
						fifo_rd <= '1';
						result <= fifo_q;
						next_state_1 <= SLEEP;
						done <= '1';
					when others =>
						next_state_1 <= SLEEP;
				end case;
			end if;
				
			
--			if reset = '0' then
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
--			else
--				if start = '1' then
--					if n(0) = '0' then
--						-- Issue dataa and datab to division pipeline
--						 if fifo_full = '0' then
--							 dividend <= x"0000" & dataa;
--							 divisor <= x"0000" & datab;
--							 result <= fifo_q;
--							 fifo_wr <= '1';
--							 done <= '1';
--						 end if;
--						else
--							if fifo_empty = '1' then
--							-- Wait for result in the FIFO
--							done <= '0';
--						 else
--							-- Read result from FIFO
--							result <= fifo_q;
--							done <= '1';
--							fifo_rd <= '1';
--							--State <= IDLE;
--						 end if;
--					end if;
--				else
--					done <= '0';
--				end if;
--				-- stop writing after one cycle
--				if fifo_wr ='1' then
--					fifo_wr <= '0';
--					done <= '1';
--				end if;
--				if fifo_rd ='1' then
--					fifo_rd <= '0';
--					done <= '1';
--				end if;
--				
--			end if;
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
		quotient => result_wire,
		remain => open
	);

	fifo : alt_fwft_fifo
	generic map(DATA_WIDTH => 32,

		NUM_ELEMENTS => 128)

	port map(
		aclr => reset,
		clock => clk,
		data => fifo_data,
		rdreq => fifo_rd,
		wrreq => fifo_wr,
		empty => fifo_empty,
		full => fifo_full,
		q => fifo_q
	);

end architecture;
