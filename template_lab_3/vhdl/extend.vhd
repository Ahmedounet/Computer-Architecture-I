library ieee;
use ieee.std_logic_1164.all;

entity extend is
    port(
        imm16  : in  std_logic_vector(15 downto 0);
        signed : in  std_logic;
        imm32  : out std_logic_vector(31 downto 0)
    );
end extend;

architecture synth of extend is

    signal sign_extended : std_logic_vector(15 downto 0);
    constant zeros_16 : std_logic_vector(15 downto 0) := (others => '0');

begin

    sign_extended <= (others => imm16(15));

    imm32 <= (zeros_16 & imm16) when signed = '0' else
        sign_extended & imm16;

end synth;
