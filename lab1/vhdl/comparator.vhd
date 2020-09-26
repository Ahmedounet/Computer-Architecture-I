library ieee;
use ieee.std_logic_1164.all;

--comment

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


process (op, a_31, b_31, diff_31,carry, zero)

--variable  check : boolean;
begin



case op is

	when "001" =>
	r <= (not (b_31) and a_31 ) or ((a_31 xnor b_31) and (diff_31 or zero) );


	when "010" =>
	r<= ((not a_31) and b_31) or ((a_31 xnor b_31) and ( (not diff_31) and (not zero)));

	when "011" =>
	r<= not zero;

	when "100" =>
	r<= zero;

	when "101" =>
	r<= (not (carry)) or zero;
	--r<= carry and (not zero);

	when "110" =>
	r<= carry and (not(zero));
	--r<= (not carry) or zero;

	when others => r<='0'; 
	

end case;


end process;



end synth;
