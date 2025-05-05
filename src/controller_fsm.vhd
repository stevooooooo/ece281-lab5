----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:42:49 PM
-- Design Name: 
-- Module Name: controller_fsm - FSM
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
--------------------
--|                  State | Encoding
--|                 --------------------
--|                  s1    | 0001
--|                  s2    | 0010
--|                  s3    | 0100
--|                  s4    | 1000
--|                 --------------------
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

entity controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end controller_fsm;

architecture FSM of controller_fsm is

    signal f_Q, f_Q_next : std_logic_vector(3 downto 0);


begin
    --next state logic
	f_Q_next(0) <= (f_Q(3) and i_adv) or (f_Q(0) and not i_adv);
	f_Q_next(1) <= (f_Q(0) and i_adv) or (f_Q(1) and not i_adv);
	f_Q_next(2) <= (f_Q(1) and i_adv) or (f_Q(2) and not i_adv);
	f_Q_next(3) <= (f_Q(2) and i_adv) or (f_Q(3) and not i_adv);
	
	-- Output logic
	o_cycle(0) <= f_Q(0);
	o_cycle(1) <= f_Q(1);
	o_cycle(2) <= f_Q(2);
    o_cycle(3) <= f_Q(3);
    
    --processes
    register_proc : process (i_adv)
    begin      
        if (rising_edge(i_adv)) then
            if i_reset = '1' then
                f_Q <= "0001";
            else 
                f_Q <= f_Q_next;
            end if;
        end if;
	end process register_proc;


end FSM;
