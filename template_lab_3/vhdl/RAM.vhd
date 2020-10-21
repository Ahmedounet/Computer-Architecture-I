library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);
        rddata  : out std_logic_vector(31 downto 0));
end RAM;

architecture synth of RAM is

type ram_type is array (0 to 1023) of std_logic_vector (31 downto 0);
signal ram_array :  ram_type := (others => (others => '0'));

signal s_cs, s_read : std_logic;
--signal s_output : std_logic_vector (31 downto 0) :=((others =>'0'));
constant const_high_z : std_logic_vector(31 downto 0) := (others => 'Z');
signal s_address_current : std_logic_vector (9 downto 0 ):= (others =>'0');

--debugging purposes
signal s_rddata_current : std_logic_vector (31 downto 0) := (others => '0') ;
signal s_wrdata_debug : std_logic_vector (31 downto 0) := (others => '0');


begin

--tri_state_proc: process (read,cs) -- This is false because of sensitivity list!

--	begin
--		s_enable<=(read and cs);

--		case s_enable is 
--			when'1' => rddata<=s_output ;
--			when others =>rddata<= const_high_z;
		
--		end case ;
--	end process;


	--s_enable <= (read and cs);
s_address_current <= address;
s_read <= read;
s_cs <= cs;

read_proc: process(clk)

begin

	if(rising_edge(clk)) then

--		case s_enable is 
--			when'1' => rddata<=ram_array (to_integer (unsigned (s_temp_address) )) ;
--			when others =>rddata<= const_high_z;

		if(s_read = '1' and s_cs = '1') then

			rddata <= ram_array(to_integer(unsigned(s_address_current)));

		else 
			rddata <= const_high_z;
		end if;
		
               -- s_rddata_current<=ram_array (to_integer (unsigned (s_address_current)));		
		
        

	end if;

    

end process;


write_proc:process(clk)

begin

	if(rising_edge(clk)) then
	
		if((write = '1') and (cs = '1')) then

			--debugging signal  
			
            ram_array(to_integer(unsigned(address))) <= wrdata;
            


			--s_wrdata_debug<=ram_array (to_integer (unsigned (address) ) );

		end if;

	end if;

end process;

end synth;