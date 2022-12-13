----------------------------------------------------------------------------------
-- Company: Clarkson University 
-- Engineer: Zander Poole
-- 
-- Create Date: 11/15/2022 02:58:53 PM
-- Design Name: LCD
-- Module Name: Hex2ASCII - Behavioral
-- Project Name: TakeHomeExam2
-- Target Devices: Trenz ZyncBerry
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

Entity Hex2ASCII is
    Port ( HEX      : in STD_LOGIC_VECTOR (3 downto 0);
           ASCII    : out STD_LOGIC_VECTOR (7 downto 0));
END Hex2ASCII;

architecture Behavioral of Hex2ASCII is

Begin

ASCII		<=	X"30" when HEX = X"0" else
				X"31" when HEX = X"1" else
				X"32" when HEX = X"2" else
				X"33" when HEX = X"3" else
				X"34" when HEX = X"4" else
				X"35" when HEX = X"5" else
				X"36" when HEX = X"6" else
				X"37" when HEX = X"7" else
				X"38" when HEX = X"8" else
				X"39" when HEX = X"9" else
				X"41" when HEX = X"A" else
				X"42" when HEX = X"B" else
				X"43" when HEX = X"C" else
				X"44" when HEX = X"D" else
				X"45" when HEX = X"E" else
				X"46" when HEX = X"F" else
				X"00";
				
End Behavioral;