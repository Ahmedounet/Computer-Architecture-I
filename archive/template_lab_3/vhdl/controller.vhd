library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        -- instruction opcode
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        -- activates branch condition
        branch_op  : out std_logic;
        -- immediate value sign extention
        imm_signed : out std_logic;
        -- instruction register enable
        ir_en      : out std_logic;
        -- PC control signals
        pc_add_imm : out std_logic;
        pc_en      : out std_logic;
        pc_sel_a   : out std_logic;
        pc_sel_imm : out std_logic;
        -- register file enable
        rf_wren    : out std_logic;
        -- multiplexers selections
        sel_addr   : out std_logic;
        sel_b      : out std_logic;
        sel_mem    : out std_logic;
        sel_pc     : out std_logic;
        sel_ra     : out std_logic;
        sel_rC     : out std_logic;
        -- write memory output
        read       : out std_logic;
        write      : out std_logic;
        -- alu op
        op_alu     : out std_logic_vector(5 downto 0)
    );
end controller;

architecture synth of controller is

    type states_type is (
        FETCH1,
        FETCH2,
        DECODE,
        R_OP,
        STORE, 
        BREAK,
        LOAD1,
        LOAD2, 
        I_OP, 
        -- Part 4
        BRANCH,
        CALL, 
        JMP,
        -- End part 4
        I_OP_UN, 
        R_OP_IMM,


        -- Some modification ADDING CALLR AND JUMPI AS SEPARATE STATES!!
        CALLR,
        JMPI

    );

    signal s_current_state, s_next_state : states_type;
   
    

    -- Constant MSB op_alu (for operations: comp, shift, add, sub...)
    constant c_add : std_logic_vector(2 downto 0) := "000";
    constant c_sub : std_logic_vector(2 downto 0) := "001";
    constant c_comp : std_logic_vector(2 downto 0) := "011";
    constant c_logical : std_logic_vector(2 downto 0) := "100";
    constant c_shift_rot : std_logic_vector(2 downto 0) := "110";
    -- End constant MSB op_alu

begin

    dff : process (clk, reset_n)
    begin
        if (reset_n = '0') then
            s_current_state <= FETCH1;
        elsif (rising_edge(clk)) then
            s_current_state <= s_next_state;
        end if;
    end process dff;


    transition : process (s_current_state)
    begin

        pc_en <= '0';
        sel_rC <= '0';
        sel_b <= '0';
        write <= '0';
        sel_mem <= '0';
        sel_addr <= '0';
        read <= '0';
        imm_signed <= '0';
        ir_en <= '0';
        ----------------- Part4 ----------------
        sel_pc <= '0';
        pc_sel_imm <= '0';
        pc_add_imm <= '0';
        pc_sel_a <= '0';
        sel_ra <= '0';
        rf_wren <= '0';
        branch_op <= '0';




        case s_current_state is
            when FETCH1 =>

                pc_en <= '0';
                sel_rC <= '0';
                sel_b <= '0';
                write <= '0';
                sel_mem <= '0';
                sel_addr <= '0';
                read <= '1';
                imm_signed <= '0';
                ir_en <= '0';
                ----------------- Part4 ----------------
                sel_pc <= '0';
                pc_sel_imm <= '0';
                pc_add_imm <= '0';
                pc_sel_a <= '0';
                sel_ra <= '0';
                rf_wren <= '0';
                branch_op <= '0';
  
                ----------------- END Part 4 -----------
                s_next_state <= FETCH2;
            when FETCH2 =>
                pc_en <= '1';
                ir_en <= '1';
               -- rf_wren <= '0';

                read <= '0';

                s_next_state <= DECODE;
            when DECODE =>
                pc_en <= '0';
                ir_en <= '0';

                case op is
                    -- Table 8 page 15
                    when "000100" =>
                       
                        s_next_state <= I_OP;
                    -- END Table 8 (5.1)
                    --------------- Part 5 -----------------

                    -- Table 10 page 15
                    when "001000" | "010000" | "011000" | "100000" =>
                      
                        s_next_state <= I_OP;
                    -- END Table 10 (5.1)

                    -- Table 9 page 15
                    when "001100" | "010100" | "011100" =>
                      
                        s_next_state <= I_OP_UN;
                    -- END Table 9 page (5.1)

                    -- Table 11 page 16
                    when "101000" | "110000" =>
                      
                        s_next_state <= I_OP_UN;
                    -- END Table 11 (5.1)

                    --------------- END Part 5 -------------
                    when "010111" =>
                      
                        s_next_state <= LOAD1;
                    when "010101" =>
                      
                        s_next_state <= STORE;
                    ----------------- Part 4 ------------
                    -- Table 3 page 11
                    when "000110" | "001110" | "010110" | "011110" | "100110" | "101110" | "110110" =>
                     
                        s_next_state <= BRANCH;
                    -- END Table 3 page 11
                    when "000000" =>
                        s_next_state <= CALL;


                    when "000001" =>
                        s_next_state<= JMPI;


                    when "111010" =>
                        case opx is
                            when "110100" =>
                                s_next_state <= BREAK;
                            when "000001" =>
                                s_next_state <= JMP;
                            when "000101" =>
                                s_next_state <= JMP;
                            when "001101" =>
                                s_next_state <= JMP;
                            --------------- END Part 4 -------------
                            --------------- Part 5 -----------------

                            -- Table 13 and 15 page 16
                            when "010010" | "011010" | "111010" | "000010" =>
                            
                                s_next_state <= R_OP_IMM;
                            -- END Table 13 and 15 (5.2)


                            --MODIFICATION HERE! CALLR
                            when "011101" =>
                                s_next_state <= CALLR;
                            --END MOFICITAION


                            when others =>
                                s_next_state <= R_OP;
                        end case;
                    -----------------END Part 5 ---------
                    when others =>
                        s_next_state <= FETCH1;
                end case;


            when R_OP =>                        
                sel_rC <= '1';
                sel_b <= '1';
                rf_wren <= '1';

                s_next_state <= FETCH1;
            when STORE =>
                imm_signed <= '1';
                read <= '0'; 
                write <= '1';
                sel_mem <= '1';
                sel_addr <= '1';


--End of MSB_op modification
                s_next_state <= FETCH1;
            when LOAD1 =>
                imm_signed <= '1';
                sel_addr <= '1';


                read <= '1';

                --End of MSB_op modification
                s_next_state <= LOAD2;

            when LOAD2 =>
                imm_signed <= '0';
                sel_mem <= '1';
                rf_wren <= '1';

                read <= '0';

                s_next_state <= FETCH1;

            when I_OP =>
                imm_signed <= '1';
                rf_wren <= '1';

                s_next_state <= FETCH1;

            when BREAK =>
                s_next_state <= BREAK;
            ------------------------- Part 4 -------------------------
            when BRANCH =>
                --Common features of all branch instructions
                branch_op <= '1';
                sel_b <= '1';
                pc_add_imm <= '1';
    
                s_next_state <= FETCH1 ;
                
            when CALL =>
                -- Common signals for any CALL 
                sel_pc <= '1';
                sel_ra <= '1';
                pc_en <= '1';
                rf_wren <= '1';

                -- Some modification!
                pc_sel_imm <= '1';


              --  if opx = "011101" then
                --    pc_sel_a <= '1';
                --else
                  --  pc_sel_imm <= '1';
                --end if;
                s_next_state <= FETCH1;


            when CALLR =>
                sel_pc <= '1';
                sel_ra <= '1';
                pc_en <= '1';
                rf_wren <= '1';
                pc_sel_a <= '1';
                sel_rC<='0';
                s_next_state <= FETCH1;

            when JMP =>
                -- Common signal for any JMP 
                pc_en <= '1';
               -- case opx is 
                 --   when "000101" | "001101"=>
                        pc_sel_a <= '1';
                   -- when others =>
                     --   pc_sel_imm <= '1';
                --end case;
                s_next_state <= FETCH1;

            when JMPI =>
                pc_en <= '1';
                pc_sel_imm <= '1';
                s_next_state <= FETCH1;
            ------------------------- END Part 4 ---------------------
            ------------------------ Part 5 -------------
            when I_OP_UN =>
                imm_signed <= '0';
                rf_wren <= '1';
               
                s_next_state <= FETCH1;

            when R_OP_IMM => -- What's different from R_OP ???
                sel_rC <= '1';
                sel_b <= '0';
                rf_wren <= '1';

                 s_next_state <= FETCH1;
            when others =>
                s_next_state <= FETCH1;
        end case;

    end process transition;



    op_alu<= 


    --  Table 2

     c_logical & opx(5 downto 3) when (op="111010" and opx="001110")  else --AND
     c_shift_rot & opx (5 downto 3) when (op="111010" and opx="011011") else  --SRL
     c_add & op(5 downto 3) when(op="000100") else  --ADDI
     c_add & op(5 downto 3) when (op="010111") else  --LDW
     c_add & op(5 downto 3) when (op="010101") else  --STW
     c_add & opx(5 downto 3) when (op="111010" and opx="110100") else    --BREAK
    
    --END  Table 2
   

    --Table 3 ALL I TYPES NO OPX COMPARAISON NEEDED

     c_comp & "100" when (op="000110") else           --BR UNCONDITONAL BRANCH CHECK THE GIT VERSION!!!!!!!!!!!!!!!!!!!!!!!!
     c_comp & op(5 downto 3) when (op="001110") else --BLE
     c_comp & op(5 downto 3) when (op="010110") else  --BGT
     c_comp & op(5 downto 3) when (op="011110") else --BNE
     c_comp & op(5 downto 3) when  (op="100110") else--BEQ
     c_comp & op(5 downto 3) when  (op="101110") else  --BLEU
     c_comp & op(5 downto 3) when  (op="110110") else--BGTU

    --END Table 3


--Table 8


--END Table 8




--Table 9 ALL I TYPES


c_logical & op ( 5 downto 3) when (op="001100") else --ANDI
c_logical & op ( 5 downto 3) when (op="010100") else --ORI
c_logical & op ( 5 downto 3) when (op="011100") else --XNORI


--END Table 9






-- Table 10 All comparaison instructions I TYPES!

c_comp & op(5 downto 3) when (op="001000") else--CMPLEI
c_comp & op(5 downto 3) when (op="010000") else --CMPGTI
c_comp & op(5 downto 3) when (op="011000") else--CMPNEI
c_comp & op(5 downto 3) when (op="100000") else --CMPEQI


-- END Table 10




-- Table 11 I TYPES

c_comp & op(5 downto 3) when (op="101000") else --CMPLEUI
c_comp & op(5 downto 3) when (op="110000") else --CMPGTUI

-- END Table 11


-- Table 12 R TYPES WORK WITH OPX!!!!!!!

c_add & opx(5 downto 3) when opx="110001" else--ADD
c_sub & opx(5 downto 3) when opx="111001" else--SUB
c_comp & opx(5 downto 3) when opx= "001000" else--CMPLE
c_comp & opx(5 downto 3) when opx="010000" else--CMPGT
c_logical & opx(5 downto 3) when opx= "000110" else--NOR
c_logical & opx(5 downto 3) when opx="001110"  else--AND
c_logical & opx(5 downto 3) when opx="010110" else--OR
c_logical & opx(5 downto 3) when opx="011110" else--XNOR
c_shift_rot & opx(5 downto 3) when opx="010011"  else--SLL
c_shift_rot & opx(5 downto 3) when opx="011011" else--SRL
c_shift_rot & opx(5 downto 3) when opx="111011" else--SRA

-- END Table 12



-- Table 13 R TYPES WORK WITH OPX!!!


c_shift_rot & opx(5 downto 3) when opx="010010" else --SLLI
c_shift_rot & opx(5 downto 3) when opx="011010" else--SRLI
c_shift_rot & opx(5 downto 3) when opx="111010" else--SRAI

-- END Table 13




--Table 14 R TYPES WORK WITH OPX!!!!!!!


c_comp & opx(5 downto 3) when opx="011000" else --CMPNE
c_comp & opx(5 downto 3) when opx="100000" else --CMPEQ
c_comp & opx(5 downto 3) when opx="101000" else --CMPLEU
c_comp & opx(5 downto 3) when opx="110000" else --CMPGTU
c_shift_rot & opx(5 downto 3) when opx="000011" else --ROL
c_shift_rot & opx(5 downto 3) when opx="001011" else--ROR

-- END Table 14


--Table 15 R TYPE WORK WITH OPX!!!!!!!

c_shift_rot & opx(5 downto 3) when opx="000010" else--roli

-- END Table 15



    "000000" ;







        

end synth;
