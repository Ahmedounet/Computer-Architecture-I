library ieee;
use ieee.std_logic_1164.all;

entity comparator is
    port(
        a_31    : in  std_logic;
        b_31    : in  std_logic;
        diff_31 : in  std_logic;
        carry   : in  std_logic;
        zero    : in  std_logic;
        op      : in  std_logic_vector(2 downto 0);
        r       : out std_logic
    );
end comparator;

architecture synth of comparator is


begin

	r <= (not (b_31) and a_31 ) or ((a_31 xnor b_31) and (diff_31 or zero) ) when op = "001" else

	     ((not a_31) and b_31) or ((a_31 xnor b_31) and ( (not diff_31) and (not zero))) when op="010" else

	      not zero when op="011" else

	      zero when op="100" else
	
              (not carry) or zero when op="101" else 

              carry and (not zero) when op="110" else
	
	      '0'; 
	



end synth;
