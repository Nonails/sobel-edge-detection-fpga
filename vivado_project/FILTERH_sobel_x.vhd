---------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2014 03:46:24 PM
-- Design Name: 
-- Module Name: FIR_Horizontal - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-----------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL; --package needed for SIGNED
-----------------------------------------------------------------
ENTITY FIR_Horizontal IS
    PORT (clk, rst: IN STD_LOGIC;
--        load: IN STD_LOGIC; --to enter new coefficient values
        run: IN STD_LOGIC; --to compute the output
        x_input, coef_input: IN SIGNED(8 DOWNTO 0);
        y: OUT SIGNED(17 DOWNTO 0);
        overflow: OUT STD_LOGIC);
END FIR_horizontal;
-----------------------------------------------------------------
ARCHITECTURE Behavioral OF FIR_horizontal IS
--SIGNAL n: INTEGER := 3;
--SIGNAL m: INTEGER := 9;
TYPE internal_array IS ARRAY (1 TO 3) OF SIGNED(8 DOWNTO 0);
SIGNAL c: internal_array := ("000000001","000000000","111111111");--stored coefficients
SIGNAL x: internal_array; --stored input values

BEGIN
PROCESS (clk, rst)
    VARIABLE prod, acc: SIGNED(17 DOWNTO 0) := (OTHERS=>'0');
    VARIABLE sign_prod, sign_acc: STD_LOGIC;
    BEGIN
        --Reset:---------------------------------
        IF (rst='0') THEN
            FOR i IN 1 TO 3 LOOP
                FOR j IN 8 DOWNTO 0 LOOP
                    x(i)(j) <= '0';
                END LOOP;
            END LOOP;
        --Shift registers:-----------------------
        ELSIF rising_edge(clk) THEN
--            IF (load='1') THEN
--                c <= (coef_input & c(1 TO n-1));
--            ELSIF (run='1') THEN
--                x <= (x_input & x(1 TO n-1));
--            END IF;
              IF (run='1') THEN
                x <= (x_input & x(1 TO 2));
              END IF;
        END IF;

        --MACs and output (w/ overflow check):---
        acc := (OTHERS=>'0');
        FOR i IN 1 TO 3 LOOP
            prod := x(i)*c(i);
            sign_prod := prod(17);
            sign_acc := acc(17);
            acc := prod + acc;
            IF (sign_prod=sign_acc AND acc(17)/=sign_acc) THEN
                overflow <= '1';
            ELSE
            overflow <= '0';
            END IF;
        END LOOP;
    IF rising_edge(clk) THEN
        y <= acc;
    END IF;
END PROCESS;
END Behavioral;
-----------------------------------------------------------------
