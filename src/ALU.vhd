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

  
	-- declare components and signals
	
signal w_Cout : STD_LOGIC;
signal w_S : STD_LOGIC_VECTOR (7 downto 0);
signal w_Cout2 : STD_LOGIC;
signal w_or : STD_LOGIC_VECTOR (7 downto 0);
signal w_and : STD_LOGIC_VECTOR (7 downto 0);

    component ripple_adder is 
        Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
               B : in STD_LOGIC_VECTOR (3 downto 0);
               Cin : in STD_LOGIC;
               S : out STD_LOGIC_VECTOR (3 downto 0);
               Cout : out STD_LOGIC);
    end component ripple_adder;

begin
    ripple_adder_inst1: ripple_adder
    port map (
        Cin => i_op(0),
        A => i_A(1 downto 0),
        B => i_B(5 downto 4),
        Cout => w_Cout,
        S => w_S (3 downto 0)
        );
       
     ripple_adder_inst2: ripple_adder
     port map (
        Cin => w_Cout,
        A => i_A(3 downto 2),
        B => i_B(7 downto 6),
        S => w_S (7 downto 4),
        Cout => w_Cout2
        );

    w_or <= i_A or i_B;
    w_and <= i_A and i_B;


	with i_op select 
	o_result <= w_or when "011",
	           W_and when "010",
	           w_S when "001",
	           w_S when "000",
	           "0000000" when others;
	           
	o_flags(3) <= w_S(7);
	
	process(w_S)
	begin
	   if (w_S and "0000000") = "0000000" then
	       o_flags(2) <= '1';
	   else 
	       o_flags(2) <= '0';
	   end if;
	end process;
	
	o_flags(1) <= ((not i_op(1))and w_Cout2);
	

	o_flags(0) <= 
	   (not ((i_A(7) xor i_B(7) xor i_op(0))) 
	   and (w_S(7) xor i_A(7)) 
	   and i_op(1));
           

end Behavioral;
