library ieee;
use ieee.std_logic_1164.all;

entity decoder is
    port(
        address : in  std_logic_vector(15 downto 0);
        cs_LEDS : out std_logic;
        cs_RAM  : out std_logic;
		cs_ROM  : out std_logic;
		cs_buttons : out std_logic
    );
end decoder;

architecture synth of decoder is
begin

	cs_ROM <=	
		'1'	when  (address < X"1000") and (address >= X"0000") else
		'0';

	cs_RAM <=
		'1'	when (address < X"2000") and (address >= X"1000") else
		'0';

	cs_LEDS <=
		'1' when (address < X"2010") and (address >= X"2000") else
		'0';

	cs_buttons <=
		'1' when (address < X"2034") and (address >= X"2030") else
		'0';

end synth;