LIBRARY ieee;
USE ieee.std_logic_1164.all;
	
use IEEE.NUMERIC_STD.ALL;
--	use IEEE.STD_LOGIC_ARITH;
--	use IEEE.STD_LOGIC_UNSIGNED.ALL;	

entity TTL_serial is
	GENERIC (
		CONSTANT cnt_max : integer := 5208);  --5208
		port (
		reset_n				: in std_logic; 
		clk				: in std_logic; 
		ena 				: in std_logic;	
		idata				: in std_logic_vector(7 downto 0);
		busy 				: out std_logic;
		TX				: out std_logic
		);
end TTL_serial;

architecture state_machine of TTL_serial is

type stateType is (ready, Start, Send, Stop);
signal state   : stateType;
signal bit_cnt : integer;
signal data	   : std_logic_vector(7 downto 0);
signal clk_cnt : integer range 0 to cnt_max;
signal clk_en  : std_logic;

    attribute mark_debug : string; 
    attribute mark_debug of state : signal is "TRUE"; 
    attribute mark_debug of Bit_cnt : signal is "TRUE"; 
    attribute mark_debug of clk_en : signal is "TRUE";   
    attribute mark_debug of data : signal is "TRUE";  
    attribute mark_debug of TX : signal is "TRUE";
	 
begin

clk_en_inst: process(clk)
	begin
	if rising_edge(clk) then
		if (clk_cnt = cnt_max) then
			clk_cnt <= 0;
			clk_en <= '1';
		else
			clk_cnt <= clk_cnt + 1;
			clk_en <= '0';
		end if;
	end if;
end process;


process(clk, reset_n, ena)
begin
	if reset_n = '0' then 
	state <= ready;
	busy <= '1';
	bit_cnt <= 0;
	TX <= '1'; -- Don't need it if the output is pulled high
	
	elsif rising_edge(clk) and clk_en = '1' then
	
	case state is 
		when ready => 
			if ena = '0' then
				busy <= '0';
				state <= ready;
			else
				busy <= '1';
				data <= iData;
				state <= start;
				TX <= '0';
			end if;
			
		when start =>
			TX <= data(bit_cnt);
			state <= Send;
			
		when Send =>
			if bit_cnt < 7 then
				TX <= data(bit_cnt + 1);
				bit_cnt <= bit_cnt + 1;
				state <= Send;
			else
				state <= Stop;
				bit_cnt <= 0;
				TX <= '1';
			end if;
			
		when Stop =>
			state <= ready;
			busy <= '0';
		end case;
	end if;
end process;
			
end state_machine;			
			
			
			
			