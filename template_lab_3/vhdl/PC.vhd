library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        en      : in  std_logic;
        sel_a   : in  std_logic;
        sel_imm : in  std_logic;
        add_imm : in  std_logic;
        imm     : in  std_logic_vector(15 downto 0);
        a       : in  std_logic_vector(15 downto 0);
        addr    : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is

    component extend is
        port(
            imm16  : in  std_logic_vector(15 downto 0);
            signed : in  std_logic;
            imm32  : out std_logic_vector(31 downto 0)
        );
    end component extend;

    signal s_current, s_next : unsigned(15 downto 0);

begin

    -- Extend component instanciation
    extend_unit : extend 
    port map(
        imm16 => std_logic_vector(s_current), 
        signed => '0',
        imm32 => addr
    );

    -- Combinatorial 
    -- Modified for Part 4
    s_next <= shift_left(unsigned(imm), 2) when sel_imm = '1' else 
        unsigned(a) when sel_a = '1' else
        s_current + unsigned(imm) when add_imm = '1' else
        s_current + 4;

    -- Sequential
    dff: process (clk, reset_n)
    begin
        if (reset_n = '0') then
            s_current <= to_unsigned(0, 16);
        elsif (rising_edge(clk)) then
            if (en = '1') then 
                s_current <= s_next;
            else 
                s_current <= s_current;
            end if;
        end if;
    end process dff;
end synth;
