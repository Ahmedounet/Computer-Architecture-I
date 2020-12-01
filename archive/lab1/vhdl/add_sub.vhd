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
    
    signal s_xor_output, s_adder_output, s_sub_32_bits : signed(31 downto 0);
    constant zeros : std_logic_vector(31 downto 0) := (others => '0'); 


begin

    s_xor_output <= not signed(b) when sub_mode = '1' else signed(b);

    s_sub_32_bits <= signed(zeros(31 downto 1) & sub_mode);

    s_adder_output <= signed(a) + s_xor_output + s_sub_32_bits;

    zero <= '1' when s_adder_output = to_signed(0, 32) else '0';

    carry <= s_adder_output(0); 

    r <= std_logic_vector(s_adder_output);

end synth;
