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

entity LCD_user_logic is
    Generic (Constant CntMax : integer:= 83333);    --50MHz/600Hz = 833333
    Port (  clk     : in STD_LOGIC;
			iData	: in STD_LOGIC_VECTOR(15 downto 0);
            LCD_RS  : out STD_LOGIC;
            LCD_EN  : out STD_LOGIC;
            LCD_DATA: out STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
end LCD_user_logic;

architecture Behavioral of LCD_user_logic is

TYPE state_type IS(start, ready, data_valid, busy_high, repeat); --needed states
signal state        : state_type;                   --state machine
signal reset_n      : STD_LOGIC;                    --active low reset
signal ena          : STD_LOGIC;                    --latch in data
signal data         : STD_LOGIC_VECTOR(8 DOWNTO 0); --data to write 
signal data_wr      : STD_LOGIC_VECTOR(8 DOWNTO 0); --data to write 
signal busy         : STD_LOGIC;                    --indicates transaction in 
signal count 	    : unsigned(27 DOWNTO 0):=X"0000000";      --X"000000F"  
--signal byteSel    : integer range 0 to 10:=0;
signal byteSel      : integer range 0 to 29:=0;
signal Sig_LCD_RS   : std_logic;
signal Sig_LCD_EN   : std_logic;
signal Sig_LCD_DATA : STD_LOGIC_VECTOR(7 DOWNTO 0);
--signal iData0       : STD_LOGIC_VECTOR(3 downto 0);
--signal iData1       : STD_LOGIC_VECTOR(3 downto 0);
--signal iData2       : STD_LOGIC_VECTOR(3 downto 0);
--signal iData3       : STD_LOGIC_VECTOR(3 downto 0);
signal DataConv0    : STD_LOGIC_VECTOR(7 downto 0);
signal DataConv1    : STD_LOGIC_VECTOR(7 downto 0);
signal DataConv2    : STD_LOGIC_VECTOR(7 downto 0);
signal DataConv3    : STD_LOGIC_VECTOR(7 downto 0);

--attribute mark_debug : string; 
--attribute mark_debug of byteSel : signal is "TRUE"; 

COMPONENT LCD_master is 
    GENERIC(CONSTANT CntMax : integer := 83333);
    Port(   clk             : IN STD_LOGIC;
            iReset_n        : IN std_logic;
            LCD_DATA_IBUF   : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
            iEna            : IN STD_LOGIC;
            oBusy           : OUT STD_LOGIC;
            LCD_DATA_OBUF   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            LCD_RS_OBUF     : OUT STD_LOGIC;
            LCD_EN_OBUF     : OUT STD_LOGIC
    );
END COMPONENT;

COMPONENT Hex2ASCII is
    Port ( HEX      : in STD_LOGIC_VECTOR (3 downto 0);
           ASCII    : out STD_LOGIC_VECTOR (7 downto 0));
END COMPONENT;

BEGIN

    LCD_RS      <= Sig_LCD_RS;
    LCD_EN      <= Sig_LCD_EN;
    LCD_DATA    <= Sig_LCD_DATA;
    
Inst_Hex2ASCII3: Hex2ASCII
port map(   HEX   => iData(15 downto 12),
            ASCII => DataConv3
        );
Inst_Hex2ASCII2: Hex2ASCII
port map(   HEX   => iData(11 downto 8),
            ASCII => DataConv2
        ); 
Inst_Hex2ASCII1: Hex2ASCII
port map(   HEX   => iData(7 downto 4),
            ASCII => DataConv1
        );
Inst_Hex2ASCII0: Hex2ASCII
port map(   HEX   => iData(3 downto 0),
            ASCII => DataConv0
        );

process(byteSel)
 begin
    case byteSel is
       when 0  => data <= '0'&X"38";
       when 1  => data <= '0'&X"38";
       when 2  => data <= '0'&X"38";
       when 3  => data <= '0'&X"38";
       when 4  => data <= '0'&X"38";
       when 5  => data <= '0'&X"38";
       when 6  => data <= '0'&X"01";
       when 7  => data <= '0'&X"0C";
       when 8  => data <= '0'&X"06";       
       when 9  => data <= '0'&X"80";
       when 10 => data <= '1'&X"53";
       when 11 => data <= '1'&X"79";
       when 12 => data <= '1'&X"73";
       when 13 => data <= '1'&X"74";
       when 14 => data <= '1'&X"65";
       when 15 => data <= '1'&X"6D";
       when 16 => data <= '1'&X"FE";
       when 17 => data <= '1'&X"52";
       when 18 => data <= '1'&X"65";
       when 19 => data <= '1'&X"61";
       when 20 => data <= '1'&X"64";
       when 21 => data <= '1'&X"79";
       when 22 => data <= '0'&X"C0"; --Repeat
       when 23 => data <= '1'&X"3D"; 
       when 24 => data <= '1'&X"3D";
       when 25 => data <= '1'&X"3E";
       when 26 => data <= '1'&DataConv3;
       when 27 => data <= '1'&DataConv2;
       when 28 => data <= '1'&DataConv1;
       when 29 => data <= '1'&DataConv0;
       when others => data <= '1'&X"01";
   end case;
end process;

Inst_LCD_master: LCD_master
	GENERIC map(CntMax => 83333)
	port map(
		        clk             => clk,
                iReset_n        => reset_n,
                LCD_DATA_IBUF   => data_wr,     --data_wr
                iEna            => ena,
                oBusy           => busy,
                LCD_DATA_OBUF   => Sig_LCD_DATA,
                LCD_RS_OBUF     => Sig_LCD_RS,
                LCD_EN_OBUF	    => Sig_LCD_EN
		); 
process(clk)
begin
if(clk'event and clk = '1') then
  case state is 
  when start =>
	      if count /= X"0000000" then                         
		      count   <= count - 1;	
		      reset_n <= '0';	
		      state   <= start;
		      ena 	  <= '0';  
	      else
		      reset_n <= '1'; 
   	          state   <= ready;
              data_wr <= data;                --data to be written 
          end if;
   when ready =>	
	      if busy = '0' then
	      	  ena     <= '1';
	      	  state   <= data_valid;
	      end if;
   when data_valid =>                              --state for conducting this transaction
          if busy = '1' then  
        	  ena     <= '0';
        	  state   <= busy_high;
          end if;
   when busy_high => 
          if(busy = '0') then               -- busy just went low 
		      state <= repeat;
		  end if;
   when repeat => 
          if byteSel < 29 then
          	  byteSel <= byteSel + 1;
          else	 
         	  byteSel <= 22;           
          end if; 		  
   	          state <= start; 
   when others => null;
   end case;
end if;
end process;
end Behavioral;
