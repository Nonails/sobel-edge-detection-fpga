library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sobel_y_2nd_trail_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXIS
		C_S00_AXIS_TDATA_WIDTH	: integer	:= 32;

		-- Parameters of Axi Master Bus Interface M00_AXIS
		C_M00_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M00_AXIS_START_COUNT	: integer	:= 32
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXIS
		s00_axis_aclk	: in std_logic;
		s00_axis_aresetn	: in std_logic;
		s00_axis_tready	: out std_logic;
		s00_axis_tdata	: in std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
		s00_axis_tstrb	: in std_logic_vector((C_S00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		s00_axis_tlast	: in std_logic;
		s00_axis_tvalid	: in std_logic;

		-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_aclk	: in std_logic;
		m00_axis_aresetn	: in std_logic;
		m00_axis_tvalid	: out std_logic;
		m00_axis_tdata	: out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
		m00_axis_tstrb	: out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m00_axis_tlast	: out std_logic;
		m00_axis_tready	: in std_logic
	);
end sobel_y_2nd_trail_v1_0;

architecture arch_imp of sobel_y_2nd_trail_v1_0 is

	-- component declaration
--	component mynewFilter_v1_0_S00_AXIS is
--		generic (
--		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
--		);
--		port (
--		S_AXIS_ACLK	: in std_logic;
--		S_AXIS_ARESETN	: in std_logic;
--		S_AXIS_TREADY	: out std_logic;
--		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
--		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
--		S_AXIS_TLAST	: in std_logic;
--		S_AXIS_TVALID	: in std_logic
--		);
--	end component mynewFilter_v1_0_S00_AXIS;

--	component mynewFilter_v1_0_M00_AXIS is
--		generic (
--		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
--		C_M_START_COUNT	: integer	:= 32
--		);
--		port (
--		M_AXIS_ACLK	: in std_logic;
--		M_AXIS_ARESETN	: in std_logic;
--		M_AXIS_TVALID	: out std_logic;
--		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
--		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
--		M_AXIS_TLAST	: out std_logic;
--		M_AXIS_TREADY	: in std_logic
--		);
--	end component mynewFilter_v1_0_M00_AXIS;
----- Filter component declarations:
component FIR_horizontal_y IS
    PORT (clk, rst: IN STD_LOGIC;
--        load: IN STD_LOGIC; --to enter new coefficient values
        run: IN STD_LOGIC; --to compute the output
        x_input, coef_input: IN SIGNED(8 DOWNTO 0);
        y: OUT SIGNED(17 DOWNTO 0);
        overflow: OUT STD_LOGIC);
END component;

component FIR_vertical_y IS
PORT (
    clk		:	IN STD_LOGIC;
    rst		: 	IN STD_LOGIC;
--    load	: 	IN  STD_LOGIC;
    run		:  IN	STD_LOGIC;
    x_input  :  IN SIGNED(8 DOWNTO 0);
    coef_input	: 	IN SIGNED(8 DOWNTO 0);
    y			: 	OUT SIGNED(17 DOWNTO 0);
    overflow    : OUT STD_LOGIC
);
END component;
----------------------------
-- INTERNAL SIGNALS:
signal run, overflowh, overflowv: std_logic;
signal coef_input_signed_horizontal	: signed(8 downto 0) := "000000000";
signal coef_input_signed_vertical : signed(8 downto 0) := "000000000";
signal sobel_in :  signed(8 DOWNTO 0) := "000000000";
signal sobel_out_signed_horizontal :  signed(17 DOWNTO 0);
signal sobel_out_signed_vertical :  signed(17 DOWNTO 0);
signal data_sobel : std_logic_vector(17 downto 0);
signal data_out: STD_LOGIC_VECTOR(7 downto 0);

-------------------------------

begin

-- Instantiation of Axi Bus Interface S00_AXIS
--mynewFilter_v1_0_S00_AXIS_inst : mynewFilter_v1_0_S00_AXIS
--	generic map (
--		C_S_AXIS_TDATA_WIDTH	=> C_S00_AXIS_TDATA_WIDTH
--	)
--	port map (
--		S_AXIS_ACLK	=> s00_axis_aclk,
--		S_AXIS_ARESETN	=> s00_axis_aresetn,
--		S_AXIS_TREADY	=> s00_axis_tready,
--		S_AXIS_TDATA	=> s00_axis_tdata,
--		S_AXIS_TSTRB	=> s00_axis_tstrb,
--		S_AXIS_TLAST	=> s00_axis_tlast,
--		S_AXIS_TVALID	=> s00_axis_tvalid
--	);

---- Instantiation of Axi Bus Interface M00_AXIS
--mynewFilter_v1_0_M00_AXIS_inst : mynewFilter_v1_0_M00_AXIS
--	generic map (
--		C_M_AXIS_TDATA_WIDTH	=> C_M00_AXIS_TDATA_WIDTH,
--		C_M_START_COUNT	=> C_M00_AXIS_START_COUNT
--	)
--	port map (
--		M_AXIS_ACLK	=> m00_axis_aclk,
--		M_AXIS_ARESETN	=> m00_axis_aresetn,
--		M_AXIS_TVALID	=> m00_axis_tvalid,
--		M_AXIS_TDATA	=> m00_axis_tdata,
--		M_AXIS_TSTRB	=> m00_axis_tstrb,
--		M_AXIS_TLAST	=> m00_axis_tlast,
--		M_AXIS_TREADY	=> m00_axis_tready
--	);

	-- Add user logic here
-- Instantiation of Filters:
sobel_horizontal_inst : FIR_Horizontal_y 
port map (
    clk=>s00_axis_aclk,
    rst=>s00_axis_aresetn,
    run=>run,
--    load=>load,
    x_input=>sobel_out_signed_vertical(8 downto 0),
    coef_input=>coef_input_signed_horizontal,
    y=>sobel_out_signed_horizontal,
    overflow=>overflowh);

sobel_vertical_inst : FIR_vertical_y 
port map (
    clk=>s00_axis_aclk,
    rst=>s00_axis_aresetn,
    run=>run,
--    load=>load,
    --x_input=>sobel_out_signed_horizontal(8 downto 0),
    x_input=>sobel_in,
--    x_input  => sobel_in,  -- testing vertical 
    coef_input=>coef_input_signed_vertical,
    y=>sobel_out_signed_vertical,
    overflow => overflowv );

--- connecting filter inputs and outputs to Stream data components
sobel_in<=SIGNED(s00_axis_tdata(8 downto 0));
data_sobel<=STD_LOGIC_VECTOR((sobel_out_signed_horizontal/8)+128);
data_out <= data_sobel(7 downto 0);
m00_axis_tdata <= "000000000000000000000000" & data_out;

--- run signal comes from tvalid on the slave (input) 
run<=s00_axis_tvalid;

-- connect through the other AXIS signals from Slave to Master:
m00_axis_tvalid <= s00_axis_tvalid;
m00_axis_tstrb <= s00_axis_tstrb;
m00_axis_tlast <= s00_axis_tlast;
s00_axis_tready <= m00_axis_tready;
	-- User logic ends


end arch_imp;
