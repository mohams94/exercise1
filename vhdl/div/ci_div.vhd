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
	signal fifo_data, fifo_q : std_logic_vector(31 downto 0) := (others => '0');
	signal dividend, divisor, remain : std_logic_vector(47 downto 0) := (others => '1');
	signal result_wire : std_logic_vector(47 downto 0) := (others => '0');
	signal fifo_empty, fifo_full, fifo_rd, fifo_wr, division_flag : std_logic := '0';
	signal shift_reg : std_logic_vector(STAGES-1 downto 0) := (others => '0');
	
	type State_Type_0 is (IDLE, CALCULATE);
	type State_Type_1 is (IDLE, DIV_READ, SLEEP);
	signal state_0, next_state_0 : State_Type_0 := IDLE;
	signal state_1, next_state_1 : State_Type_1 := SLEEP;
   signal counter : Integer := 0;
	
	
begin
	--result <= result_wire;
	--result <= fifo_q;
	  process(clk)
	  begin
		 if rising_edge(clk) then
			if reset = '1' then
				fifo_data <= (others => '0');
				--fifo_q <= (others => '0');
				dividend  <= (others => '1');
				divisor <= (others => '1');
				--result_wire <= (others => '0');
				shift_reg <= (others => '0');
				--remain <= (others => '0');
				--fifo_empty <= '0';
				--fifo_full <= '0';
				fifo_rd <= '0';
				fifo_wr <= '0';
				division_flag <= '0';
				state_0 <= IDLE;
				state_1 <= SLEEP;
				done <= '0';
			else
						 --result <= fifo_q;
			-- ################# div_write
				if n(0) = '0' then
--					done <= '0';
					--fifo_wr <= '0';
					--state_0 <= next_state_0;
--					case state_0 is
--						when IDLE =>

	--					when STALL =>
	--						if counter = STAGES then
	--							if fifo_full = '0' then
	--								done <= '1';
	--								fifo_wr <= '1';
	--								fifo_data <= result_wire;
	--								--result <= result_wire;
	--								counter <= 0;
	--								state_0 <= IDLE;
	--							end if;
	--						else
	--							counter <= counter + 1;
	--							state_0 <= STALL;
	--						end if;
--						when others =>
--							state_0 <= IDLE;
--					end case;
					
					
					if start = '1' and fifo_full = '0' then
						dividend <= dataa & x"0000";
						divisor <= x"0000" & datab;
						done <= '1';
						division_flag <= '1';
						--state_0 <= IDLE;
					else
						done <= '0';
						division_flag <= '0';
					end if;
				-- #################   div_read
				else	
					--state_0 <= IDLE;
					--done <= '0';
					--case state_1 is
					if start = '1' and fifo_empty = '0'then
						fifo_rd <= '1';
						done <= '1';
					else 
						fifo_rd <= '0';
						done <= '0';
					end if;
--						state_1 <= DIV_READ;
--					else
--						state_1 <= SLEEP;
--					end if;
--						when SLEEP =>

--						when IDLE =>
--							fifo_rd <= '0';
--							if fifo_empty = '0' then
--								state_1 <= DIV_READ;
--							else
--								state_1 <= IDLE;
--							end if;
--						when DIV_READ =>
--
--							state_1 <= SLEEP;
--						when others =>
--							state_1 <= SLEEP;
--					end case;
				end if;
				
				if shift_reg(0) = '1' and fifo_full = '0' then
					fifo_wr <= '1';
					fifo_data <= result_wire(31 downto 0);
				else
					fifo_wr <= '0';
				end if;
				shift_reg <= division_flag & shift_reg(STAGES-1 downto 1);
				end if;
		 end if;
	  end process;

	divider : lpm_divide
	generic map(
		LPM_WIDTHN => 48,
		LPM_WIDTHD => 48,
		LPM_PIPELINE => STAGES,
		LPM_DREPRESENTATION => "SIGNED",
		LPM_NREPRESENTATION => "SIGNED")
		
	port map(
		clock => clk,
		clken => '1',
		numer => dividend,
		denom => divisor,
		quotient => result_wire,
		remain => remain
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
		q => result
	);

end architecture;
