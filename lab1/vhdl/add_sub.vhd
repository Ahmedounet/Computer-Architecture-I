library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub is
    port(
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        sub_mode : in  std_logic;
        carry    : out std_logic;
        zero     : out std_logic;
        r        : out std_logic_vector(31 downto 0)
    );
end add_sub;

architecture synth of add_sub is
    
--    signal s_xor_output, s_adder_output : signed(32 downto 0);

    signal  r_33_bits :std_logic_vector (32 downto 0);

    signal s_xor_output, s_sub_32_bits : std_logic_vector (31 downto 0);

    constant zeros : std_logic_vector(31 downto 0) := (others => '0'); 


begin

    s_sub_32_bits<= (31 downto 0 => sub_mode);

--    s_xor_output <= ('0' & b) xor s_sub_33_bits;

    s_xor_output <= ( b) xor s_sub_32_bits;

--s_xor_output_33_bits <= '0' &
	
    r_33_bits<= std_logic_vector (unsigned('0'& a)+ unsigned ('0' & s_xor_output)+ unsigned(zeros  & sub_mode));

    zero <= '1' when signed( r_33_bits (31 downto 0)) = to_signed(0, 31) else '0';

    r<= r_33_bits(31 downto 0);

    carry<= r_33_bits(32) ;



--   zero <= '1' when s_adder_output = to_signed(0, 32) else '0';

--    s_xor_output <= not signed(b) when sub_mode = '1' else signed(b);

--    s_sub_32_bits <= signed(zeros(31 downto 1) & sub_mode);

--    s_adder_output <= signed(a) + s_xor_output + s_sub_32_bits;



--    carry <= s_adder_output(32); 

--    r <= std_logic_vector(s_adder_output);

end synth;
