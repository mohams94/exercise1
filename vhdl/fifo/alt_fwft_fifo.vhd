

LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;

use altera_mf_components.all;

use work.math_pkg.all;

ENTITY alt_fwft_fifo IS
	generic (
		DATA_WIDTH : integer := 32;
		NUM_ELEMENTS : integer 
	);
	PORT (
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0)
	);
END entity;


ARCHITECTURE SYN OF alt_fwft_fifo IS

	SIGNAL sub_wire0	: STD_LOGIC ;
	SIGNAL sub_wire1	: STD_LOGIC ;

--	COMPONENT scfifo
--	GENERIC (
--		add_ram_output_register		: STRING;
--		intended_device_family		: STRING;
--		lpm_numwords		: NATURAL;
--		lpm_showahead		: STRING;
--		lpm_type		: STRING;
--		lpm_width		: NATURAL;
--		lpm_widthu		: NATURAL;
--		overflow_checking		: STRING;
--		underflow_checking		: STRING;
--		use_eab		: STRING
--	);
--	PORT (
--			aclr	: IN STD_LOGIC ;
--			clock	: IN STD_LOGIC ;
--			data	: IN STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
--			rdreq	: IN STD_LOGIC ;
--			wrreq	: IN STD_LOGIC ;
--			empty	: OUT STD_LOGIC ;
--			full	: OUT STD_LOGIC ;
--			q	: OUT STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0)
--	);
--	END COMPONENT;

BEGIN
	empty    <= sub_wire0;
	full    <= sub_wire1;

	scfifo_component : scfifo
	GENERIC MAP (
		add_ram_output_register => "ON",
		intended_device_family => "Cyclone IV E",
		lpm_numwords => NUM_ELEMENTS,
		lpm_showahead => "ON",
		lpm_type => "scfifo",
		lpm_width => DATA_WIDTH,
		lpm_widthu => log2c(NUM_ELEMENTS),
		overflow_checking => "ON",
		underflow_checking => "ON",
		use_eab => "ON"
	)
	PORT MAP (
		aclr => aclr,
		clock => clock,
		data => data,
		rdreq => rdreq,
		wrreq => wrreq,
		empty => sub_wire0,
		full => sub_wire1,
		q => q
	);



END SYN;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: AlmostEmpty NUMERIC "0"
-- Retrieval info: PRIVATE: AlmostEmptyThr NUMERIC "-1"
-- Retrieval info: PRIVATE: AlmostFull NUMERIC "0"
-- Retrieval info: PRIVATE: AlmostFullThr NUMERIC "-1"
-- Retrieval info: PRIVATE: CLOCKS_ARE_SYNCHRONIZED NUMERIC "0"
-- Retrieval info: PRIVATE: Clock NUMERIC "0"
-- Retrieval info: PRIVATE: Depth NUMERIC "8"
-- Retrieval info: PRIVATE: Empty NUMERIC "1"
-- Retrieval info: PRIVATE: Full NUMERIC "1"
-- Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
-- Retrieval info: PRIVATE: LE_BasedFIFO NUMERIC "0"
-- Retrieval info: PRIVATE: LegacyRREQ NUMERIC "0"
-- Retrieval info: PRIVATE: MAX_DEPTH_BY_9 NUMERIC "0"
-- Retrieval info: PRIVATE: OVERFLOW_CHECKING NUMERIC "0"
-- Retrieval info: PRIVATE: Optimize NUMERIC "1"
-- Retrieval info: PRIVATE: RAM_BLOCK_TYPE NUMERIC "0"
-- Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
-- Retrieval info: PRIVATE: UNDERFLOW_CHECKING NUMERIC "0"
-- Retrieval info: PRIVATE: UsedW NUMERIC "0"
-- Retrieval info: PRIVATE: Width NUMERIC "32"
-- Retrieval info: PRIVATE: dc_aclr NUMERIC "0"
-- Retrieval info: PRIVATE: diff_widths NUMERIC "0"
-- Retrieval info: PRIVATE: msb_usedw NUMERIC "0"
-- Retrieval info: PRIVATE: output_width NUMERIC "32"
-- Retrieval info: PRIVATE: rsEmpty NUMERIC "1"
-- Retrieval info: PRIVATE: rsFull NUMERIC "0"
-- Retrieval info: PRIVATE: rsUsedW NUMERIC "0"
-- Retrieval info: PRIVATE: sc_aclr NUMERIC "1"
-- Retrieval info: PRIVATE: sc_sclr NUMERIC "0"
-- Retrieval info: PRIVATE: wsEmpty NUMERIC "0"
-- Retrieval info: PRIVATE: wsFull NUMERIC "1"
-- Retrieval info: PRIVATE: wsUsedW NUMERIC "0"
-- Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
-- Retrieval info: CONSTANT: ADD_RAM_OUTPUT_REGISTER STRING "ON"
-- Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
-- Retrieval info: CONSTANT: LPM_NUMWORDS NUMERIC "8"
-- Retrieval info: CONSTANT: LPM_SHOWAHEAD STRING "ON"
-- Retrieval info: CONSTANT: LPM_TYPE STRING "scfifo"
-- Retrieval info: CONSTANT: LPM_WIDTH NUMERIC "32"
-- Retrieval info: CONSTANT: LPM_WIDTHU NUMERIC "3"
-- Retrieval info: CONSTANT: OVERFLOW_CHECKING STRING "ON"
-- Retrieval info: CONSTANT: UNDERFLOW_CHECKING STRING "ON"
-- Retrieval info: CONSTANT: USE_EAB STRING "ON"
-- Retrieval info: USED_PORT: aclr 0 0 0 0 INPUT NODEFVAL "aclr"
-- Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL "clock"
-- Retrieval info: USED_PORT: data 0 0 32 0 INPUT NODEFVAL "data[31..0]"
-- Retrieval info: USED_PORT: empty 0 0 0 0 OUTPUT NODEFVAL "empty"
-- Retrieval info: USED_PORT: full 0 0 0 0 OUTPUT NODEFVAL "full"
-- Retrieval info: USED_PORT: q 0 0 32 0 OUTPUT NODEFVAL "q[31..0]"
-- Retrieval info: USED_PORT: rdreq 0 0 0 0 INPUT NODEFVAL "rdreq"
-- Retrieval info: USED_PORT: wrreq 0 0 0 0 INPUT NODEFVAL "wrreq"
-- Retrieval info: CONNECT: @aclr 0 0 0 0 aclr 0 0 0 0
-- Retrieval info: CONNECT: @clock 0 0 0 0 clock 0 0 0 0
-- Retrieval info: CONNECT: @data 0 0 32 0 data 0 0 32 0
-- Retrieval info: CONNECT: @rdreq 0 0 0 0 rdreq 0 0 0 0
-- Retrieval info: CONNECT: @wrreq 0 0 0 0 wrreq 0 0 0 0
-- Retrieval info: CONNECT: empty 0 0 0 0 @empty 0 0 0 0
-- Retrieval info: CONNECT: full 0 0 0 0 @full 0 0 0 0
-- Retrieval info: CONNECT: q 0 0 32 0 @q 0 0 32 0
-- Retrieval info: GEN_FILE: TYPE_NORMAL test_fifo.vhd TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL test_fifo.inc FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL test_fifo.cmp TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL test_fifo.bsf FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL test_fifo_inst.vhd FALSE
-- Retrieval info: LIB_FILE: altera_mf
