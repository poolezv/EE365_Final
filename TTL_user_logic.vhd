LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--USE ieee.std_logic_unsigned.all;

ENTITY TTL_user_logic IS
	GENERIC (CONSTANT cnt_max : integer := 5208); 
	PORT(clk       : IN     STD_LOGIC;                     --system clock
         iData     : IN     STD_LOGIC_VECTOR(15 DOWNTO 0); --input data
         TX        : OUT    STD_LOGIC);                    --serial data output
END TTL_user_logic;

ARCHITECTURE user_logic OF TTL_user_logic IS

TYPE state_type IS(start, ready, data_valid, busy_high, repeat); --needed states
signal state      : state_type;                   --state machine
signal reset_n    : STD_LOGIC;                    --active low reset
signal ena        : STD_LOGIC;                    --latch in data
signal data       : STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write 
signal data_wr    : STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write 
signal busy       : STD_LOGIC;                    --indicates transaction in 
--signal busy_prev  : STD_LOGIC;
signal count 	  : unsigned(27 DOWNTO 0):=X"000000F";  --000000F
signal byteSel    : integer range 0 to 10:=0;
signal sig_TX     : std_logic;

attribute mark_debug : string; 
attribute mark_debug of byteSel : signal is "TRUE"; 

COMPONENT TTL_serial is
	GENERIC (
		CONSTANT cnt_max : integer := 5208); 
		port (
		reset_n				: in std_logic; 
		clk				    : in std_logic; 
		ena 				: in std_logic;	
		idata				: in std_logic_vector(7 downto 0);
		busy 				: out std_logic;
		TX				    : out std_logic
		);
end COMPONENT;

BEGIN

    TX <= Sig_TX;
	
process(byteSel, iData)
 begin
    case byteSel is
       when 0  => data <= X"76";
       when 1  => data <= X"76";
       when 3  => data <= X"7A";
       when 4  => data <= X"FF";
       when 5  => data <= X"77";
       when 6  => data <= X"00";
       when 7  => data <= X"0"&iData(15 downto 12);
       when 8  => data <= X"0"&iData(11 downto 8);
       when 9  => data <= X"0"&iData(7  downto 4);
       when 10 => data <= X"0"&iData(3  downto 0);
       when others => data <= X"76";
   end case;
end process;

      
Inst_TTL_serial: TTL_serial
	GENERIC map(
		cnt_max => 5208)                 -- 9 -------------------
	port map(
		reset_n	  => reset_n, 		
		clk	      => clk, 		
		ena 	  => ena,			
		idata	  => data_wr, 		
		busy 	  => busy,			
	    TX	      => Sig_TX	
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
		ena 	<= '0';  
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
              if(busy = '0') then                -- busy just went low 
		      state <= repeat;
   	      end if;		     
  when repeat => 
          	if byteSel < 10 then
           	   byteSel <= byteSel + 1;
        	else	 
           	   byteSel <= 7;           
         	end if; 		  
   	          state <= start; 
  when others => null;

  end case;   
end if;  
end process;         
end user_logic;  
 