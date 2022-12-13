----------------------------------------------------------------------------------
-- Company: Clarkson University 
-- Engineer: Zander Poole
-- 
-- Create Date: 11/15/2022 02:58:53 PM
-- Design Name: LCD
-- Module Name: LCD_master - Behavioral
-- Project Name: TakeHomeExam2
-- Target Devices: Trenz ZyncBerry
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity LCD_master is
    Generic(CONSTANT CntMax : integer := 83333); 
    Port (  clk             : IN STD_LOGIC;
            iReset_n        : IN STD_LOGIC;
            LCD_DATA_IBUF   : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
            iEna            : IN STD_LOGIC;
            oBusy           : OUT STD_LOGIC;
            LCD_DATA_OBUF   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            LCD_RS_OBUF     : OUT STD_LOGIC;
            LCD_EN_OBUF     : OUT STD_LOGIC
    );
end LCD_master;

architecture Behavioral of LCD_master is

    type stateType is (Ready, Inititalize, Prepare, Write, Done);
    signal state    : stateType;	    
    signal cnt      : integer range 0 to CntMax; --use CntMax
	signal clock_en : std_logic;
    signal Data     : std_logic_vector(8 downto 0);
    
    attribute mark_debug : string; 
    attribute mark_debug of clock_en : signal is "TRUE";   
    attribute mark_debug of LCD_DATA_IBUF : signal is "TRUE"; 
    attribute mark_debug of LCD_RS_OBUF : signal is "TRUE";   
    attribute mark_debug of LCD_EN_OBUF : signal is "TRUE"; 
    attribute mark_debug of iReset_n : signal is "TRUE";

begin

--    Data            <= LCD_DATA_IBUF;
--    LCD_DATA_OBUF   <= Data;

            Data            <= LCD_DATA_IBUF;
            LCD_DATA_OBUF   <= Data(7 downto 0);
            LCD_RS_OBUF		<= Data(8);       

Clock_Enable:
process(clk, iReset_n)
begin
  if iReset_n = '0' then 
	    cnt<=0;
	    clock_en<='0';
  elsif rising_edge(clk) then
	if cnt = CntMax then      --Use CntMax 
		  clock_en <= '1';
		  cnt <=0;
	else
		  clock_en <= '0';
		  cnt <= cnt+1;
	end if;
end if;
end process;


LCD_state_machine:
process(clk, iReset_n, clock_en)
begin
if iReset_n ='0' then
    LCD_RS_OBUF <= '0';
    LCD_EN_OBUF <= '0';
    oBusy       <= '1';
    state       <= Ready;
elsif rising_edge(clk) and clock_en = '1' then 
    case state is 
        when Ready => 
--            Data            <= LCD_DATA_IBUF;
--            LCD_DATA_OBUF   <= Data(7 downto 0);
--            LCD_RS_OBUF		<= Data(8);       
            if iEna = '0' then
                oBusy   <= '0';
                state   <= Ready;
            else
                oBusy           <= '1';
                state           <= Inititalize;
            end if;
        when Inititalize =>
            LCD_EN_OBUF     <= '0';
            state   <= Prepare;
        when Prepare => 
            LCD_EN_OBUF     <= '1';
            state           <= Write;
        when Write => 
            LCD_EN_OBUF     <= '0';
            state           <= Done;
        when Done =>
            oBusy <= '0';
            state <= Ready;
        when others =>
            state <= Ready;
    end case;        
end if;
end process;
end Behavioral;
