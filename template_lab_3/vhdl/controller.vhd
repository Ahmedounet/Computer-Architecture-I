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
        R_OP_IMM
    );

    signal s_current_state, s_next_state : states_type;
    -- Signal 3MSB of op_alu
    --signal MSB_op_alu : std_logic_vector(2 downto 0);

    -- Constant MSB op_alu (for operations: comp, shift, add, sub...)
    constant add : std_logic_vector(2 downto 0) := "000";
    constant sub : std_logic_vector(2 downto 0) := "001";
    constant comp : std_logic_vector(2 downto 0) := "011";
    constant logical : std_logic_vector(2 downto 0) := "100";
    constant shift_rot : std_logic_vector(2 downto 0) := "110";
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
                rf_wren <= '0';
                s_next_state <= DECODE;
            when DECODE =>
                pc_en <= '0';
                ir_en <= '0';
                case op is
                    -- Table 8 page 15
                    when "000100" =>
                       -- MSB_op_alu <= add;
                        s_next_state <= I_OP;
                    -- END Table 8 (5.1)
                    --------------- Part 5 -----------------

                    -- Table 10 page 15
                    when "001000" | "010000" | "011000" | "100000" =>
                      --  MSB_op_alu <= comp;
                        s_next_state <= I_OP;
                    -- END Table 10 (5.1)

                    -- Table 9 page 15
                    when "001100" | "010100" | "011100" =>
                      --  MSB_op_alu <= logical;
                        s_next_state <= I_OP_UN;
                    -- END Table 9 page (5.1)

                    -- Table 11 page 16
                    when "101000" | "110000" =>
                      --  MSB_op_alu <= comp; 
                        s_next_state <= I_OP_UN;
                    -- END Table 11 (5.1)

                    --------------- END Part 5 -------------
                    when "010111" =>
                      --  MSB_op_alu <= add;
                        s_next_state <= LOAD1;
                    when "010101" =>
                      --  MSB_op_alu <= add;
                        s_next_state <= STORE;
                    ----------------- Part 4 ------------
                    -- Table 3 page 11
                    when "000110" | "001110" | "010110" | "011110" | "100110" | "101110" | "110110" =>
                      --  MSB_op_alu <= comp;
                        s_next_state <= BRANCH;
                    -- END Table 3 page 11
                    when "000000" => 
                        s_next_state <= CALL;
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
                             --   MSB_op_alu <= shift_rot;
                                s_next_state <= R_OP_IMM;
                            -- END Table 13 and 15 (5.2)

                            when others =>
                                s_next_state <= R_OP;
                        end case;
                    -----------------END Part 5 ---------
                    when others =>
                        s_next_state <= DECODE;
                end case;
            when R_OP =>                        
                sel_rC <= '1';
                sel_b <= '1';
                rf_wren <= '1';
                -- Determination of MSB_op_alu
                case opx is 
                    when "110001" =>
                      --  MSB_op_alu <= add;
                      op_alu <= add & opx(5 downto 3);
                    when "111001" =>
                      --  MSB_op_alu <= sub;
                      op_alu <= sub & opx(5 downto 3);
                    when "001000" | "010000" =>
                      --  MSB_op_alu <= comp;
                      op_alu <= comp & opx(5 downto 3);
                    when "000110" | "001110" | "010110" | "011110" =>
                      --  MSB_op_alu <= logical;
                      op_alu <= logical & opx(5 downto 3);
                    when "010011" | "011011" | "111011" =>
                     --   MSB_op_alu <= shift_rot;
                     op_alu <= shift_rot & opx(5 downto 3);
                    when others =>
                     --   MSB_op_alu <= add;
                     op_alu <= add & opx(5 downto 3);
                end case;
                -- END determination
               -- op_alu <= MSB_op_alu & opx(5 downto 3);
                s_next_state <= FETCH1;
            when STORE =>
                imm_signed <= '1';
                read <= '0'; -- Not sure where read should be 1 or 0
                write <= '1';
                sel_mem <= '1';
                sel_addr <= '1';
--Only one case of MSB will be modified here !

                op_alu <=add  & op(5 downto 3);

--End of MSB_op modification
                s_next_state <= FETCH1;
            when LOAD1 =>
                imm_signed <= '1';
                sel_addr <= '1';

                --Only one case of MSB will be modified here !
                op_alu <= add & op(5 downto 3);
                --End of MSB_op modification
                s_next_state <= LOAD2;

            when LOAD2 =>
                imm_signed <= '0';
                sel_mem <= '1';
                rf_wren <= '1';
                s_next_state <= FETCH1;
            when I_OP =>
                imm_signed <= '1';
                rf_wren <= '1';

-- A lot of (2 actually) msb_op_alu will be modified here!!!
                case op is
                    --table 8 page 15
                    when "000100" => 
                        op_alu<=add & op(5 downto 3);
                    --End table 8 (5.1)

                    -- Table 10 page 15
                    when "001000" | "010000" | "011000" | "100000" =>
                        op_alu<= comp & op(5 downto 3);
                    -- END Table 10 (5.1)
               -- op_alu <= MSB_op_alu & op(5 downto 3);
                    when others =>
                    op_alu<=add & op(5 downto 3);

                end case;

                s_next_state <= FETCH1;

            
--End msb_op_alu modification

            when BREAK =>
                s_next_state <= BREAK;
            ------------------------- Part 4 -------------------------
            when BRANCH =>
                --Common features of all branch instructions
                branch_op <= '1';
                sel_b <= '1';
                pc_add_imm <= '1';
            -- MSB_OP_ALU changes !
            
                if op = "000110" then
                    op_alu <= comp & "100";
                else 
                    op_alu <= comp & op(5 downto 3);
                end if;

                --end of msb_op_alu changes!
                s_next_state <= FETCH1 ;
                
            when CALL =>
                -- Common signals for any CALL 
                sel_pc <= '1';
                sel_ra <= '1';
                pc_en <= '1';
                rf_wren <= '1';
                if opx = "011101" then
                    pc_sel_a <= '1';
                else 
                    pc_sel_imm <= '1';
                end if;
                s_next_state <= FETCH1;
            when JMP =>
                -- Common signal for any JMP 
                pc_en <= '1';
                if opx = "000001" then
                    pc_sel_imm <= '1';    
                else 
                    pc_sel_a <= '1';
                end if;
                s_next_state <= FETCH1;
            ------------------------- END Part 4 ---------------------
            ------------------------ Part 5 -------------
            when I_OP_UN =>
                imm_signed <= '0';
                rf_wren <= '1';
                --Change of msb_op_alu
                op_alu <= logical & op(5 downto 3);
                --End of change of msb_op_alu
                s_next_state <= FETCH1;

            when R_OP_IMM => -- What's different from R_OP ???
                sel_rC <= '1';
                sel_b <= '0';
                rf_wren <= '1';
            --Change of msb_op_alu

                op_alu <= shift_rot & opx(5 downto 3);

            --End of change of msb_op_alu

            s_next_state <= FETCH1;
            when others =>
                s_next_state <= FETCH1;
        end case;

    end process transition;

end synth;