----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
 
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
 
entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is
    signal w_Cout : STD_LOGIC;
    signal w_S : STD_LOGIC_VECTOR (7 downto 0);
    signal w_Cout2 : STD_LOGIC;
    signal w_or : STD_LOGIC_VECTOR (7 downto 0);
    signal w_and : STD_LOGIC_VECTOR (7 downto 0);
    signal w_B : STD_LOGIC_VECTOR (7 downto 0);  -- New signal for inverted B
    signal w_result : STD_LOGIC_VECTOR (7 downto 0);
 
    component ripple_adder is 
        Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
               B : in STD_LOGIC_VECTOR (3 downto 0);
               Cin : in STD_LOGIC;
               S : out STD_LOGIC_VECTOR (3 downto 0);
               Cout : out STD_LOGIC);
    end component ripple_adder;
begin
    w_B <= not i_B when i_op(0) = '1' else i_B;  -- Invert B for subtraction
 
    ripple_adder_inst1: ripple_adder
    port map (
        Cin => i_op(0),
        A => i_A(3 downto 0),
        B => w_B(3 downto 0),  -- Use inverted B
        Cout => w_Cout,
        S => w_S(3 downto 0)
    );
    ripple_adder_inst2: ripple_adder
    port map (
        Cin => w_Cout,
        A => i_A(7 downto 4),
        B => w_B(7 downto 4),  -- Use inverted B
        S => w_S(7 downto 4),
        Cout => w_Cout2
    );
 
    w_or <= i_A or i_B;
    w_and <= i_A and i_B;
 
    with i_op select 
    w_result <= w_or when "011",
               w_and when "010",
               w_S when "001",
               w_S when "000",
               "00000000" when others;
               
    o_result <= w_result;           
 
    o_flags(3) <= w_result(7);
    process(w_S)
    begin
        if w_result = "00000000" then  -- Simplified zero flag logic
            o_flags(2) <= '1';
        else 
            o_flags(2) <= '0';
        end if;
    end process;
    o_flags(1) <= ((not i_op(1)) and w_Cout2);
    o_flags(0) <= (i_A(7) and w_B(7) and not w_result(7)) or (not i_A(7) and not w_B(7) and w_result(7));
end Behavioral;
