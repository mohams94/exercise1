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
	
	-- signals for the components
	signal fifo_q, fifo_data, sqrt_result, sqrt_input, sqrt_remainder : std_logic_vector(31 downto 0);
	signal fifo_empty, fifo_full, fifo_rd, fifo_wr : std_logic;
	
	-- constant for setting the number of pipeline stages
	constant STAGES : integer := 16;

begin
    process (clk)
    begin
       if res_n = '0' then
			fifo_data <= (others => '0');
			fifo_q <= (others => '0');
			sqrt_result <= (others => '0');
			sqrt_input <= (others => '0');
			sqrt_remainder <= (others => '0');
			fifo_empty <= '0';
			fifo_full <= '0';
			fifo_rd <= '0';
			fifo_wr <= '0';
		 elsif rising_edge(clk) then
            if write = '1' then
					if address(0) = '0' then
						sqrt_input <= writedata;
					end if;
                -- Write a new value to the module
                -- Implement your FIFO write logic here
            end if;
            
            if read = '1' then
                -- Read the result, if data is available
                if fifo_empty = '0' and address(0) = '0' then
                    sqrt_result <= (others => 'X');  -- Undefined result
                else
                    --sqrt_result <= -- Implement your FIFO read logic here
                end if;
            end if;
            
            -- Determine if data is available to be read from the core
            --data_available <= -- Implement your FIFO empty flag logic here
        end if;
    end process;

    -- Connect ALTSQRT IP core to your design
    -- Instantiate and connect the ALTSQRT IP core here

    -- Output data based on the read address
    readdata <= sqrt_result when read = '1' else (others => 'X');
	 
	 
	sqrt: altsqrt
	generic map(
		pipeline => STAGES,
		width => 32
	)
	port map(
		aclr => res_n,
		clk => clk,
		q => sqrt_result,
		radical => sqrt_input,
		remainder => sqrt_remainder
	);
	
	fifo : alt_fwft_fifo
	generic map(DATA_WIDTH => 32,

		NUM_ELEMENTS => 128)

	port map(
		aclr => res_n,
		clock => clk,
		data => sqrt_result,
		rdreq => fifo_rd,
		wrreq => fifo_wr,
		empty => fifo_empty,
		full => fifo_full,
		q => fifo_q
	);
	 
end architecture;
