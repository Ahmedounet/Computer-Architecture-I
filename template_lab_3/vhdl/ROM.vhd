library ieee;

use ieee.std_logic_1164.all;



entity ROM is

    port(

        clk     : in  std_logic;

        cs      : in  std_logic;

        read    : in  std_logic;

        address : in  std_logic_vector(9 downto 0);

        rddata  : out std_logic_vector(31 downto 0)

    );

end ROM;



architecture synth of ROM is



signal s_output :std_logic_vector (31 downto 0):=((others =>'0'));

signal s_en : std_logic := '0';

signal s_address_current : std_logic_vector(9 downto 0) := (others => '0');



constant const_high_z : std_logic_vector(31 downto 0) := (others => 'Z');



COMPONENT ROM_Block 

    PORT

    (

        address     : IN STD_LOGIC_VECTOR (9 DOWNTO 0);

        clock       : IN STD_LOGIC  := '1';

        q       : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)

    );

END COMPONENT;



begin





rom_component : ROM_Block



    port map(



        address =>s_address_current,

        clock=>clk,

        --q=>rddata

        q=>s_output

        );





read_proc : process (clk)

    begin



        if(rising_edge(clk)) then



            s_en<= cs and read;

            s_address_current<=address;




        end if;


    end process ;


    rddata<=s_output when s_en='1' else const_high_z;


end synth;

