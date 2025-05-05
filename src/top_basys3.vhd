--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals
	signal w_fsmOutput : std_logic_vector(3 downto 0);
	signal w_clk : std_logic;
	signal w_sign : std_logic_vector(3 downto 0);
	signal w_hund : std_logic_vector(3 downto 0);
	signal w_tens : std_logic_vector(3 downto 0);
	signal w_ones : std_logic_vector(3 downto 0);
	
	signal w_TMD4_o : STD_LOGIC_VECTOR (3 downto 0);
    signal w_sel : STD_LOGIC_VECTOR (3 downto 0);
    
    signal f_Q : std_logic_vector (7 downto 0);
    signal f_Q1 : std_logic_vector (7 downto 0);
    
    signal w_result : std_logic_vector(7 downto 0);
    signal w_flags : std_logic_vector(3 downto 0);
    
    signal w_data : std_logic_vector(7 downto 0);
	
	component controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end component controller_fsm;

    component clock_divider is
        generic ( constant k_DIV : natural := 50000000	); -- How many clk cycles until slow clock toggles
                                                   -- Effectively, you divide the clk double this 
                                                   -- number (e.g., k_DIV := 2 --> clock divider of 4)
        port ( 	i_clk    : in std_logic;
                i_reset  : in std_logic;		   -- asynchronous
                o_clk    : out std_logic		   -- divided (slow) clock
        );
    end component clock_divider;
    
    component TDM4 is
		generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
        Port ( i_clk		: in  STD_LOGIC;
           i_reset		: in  STD_LOGIC; -- asynchronous
           i_D3 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D2 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D1 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D0 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_data		: out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_sel		: out STD_LOGIC_VECTOR (3 downto 0)	-- selected data line (one-cold)
	   );
    end component TDM4;
    
    component twos_comp is 
        port (
        i_bin: in std_logic_vector(7 downto 0);
        o_sign: out std_logic_vector(3 downto 0);
        o_hund: out std_logic_vector(3 downto 0);
        o_tens: out std_logic_vector(3 downto 0);
        o_ones: out std_logic_vector(3 downto 0)
    );
    end component twos_comp;
    
   component sevenseg_decoder is
        port (
            i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
            o_seg_n : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component sevenseg_decoder;
    
    component ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end component ALU;


  
begin
	-- PORT MAPS ----------------------------------------
	controller1 : controller_fsm
        port map( 
            i_reset => btnU,
            i_adv => btnC,
            o_cycle => w_fsmOutput
       );
       
     clock1 : clock_divider
	--k_div = 12500 --from old code may need to change K_DIV
	   generic map (
            k_DIV =>  125000
        )
        port map(
	        i_clk => clk,
            i_reset => btnU,		   -- asynchronous
            o_clk => w_clk
	    );
	    
	    TDM1 : TDM4
        port map ( 
           i_clk => w_clk,
           i_reset	=> btnU,
           i_D3 => w_sign,
		   i_D2 => w_hund,
		   i_D1 => w_tens,	
		   i_D0 => w_ones,
		   o_data => w_TMD4_o,
		   o_sel => w_sel
	       );
	       
	    twos_comp1 : twos_comp
	    port map(
	        i_bin => w_data, --input from mux after alu
            o_sign => w_sign,
            o_hund => w_hund,
            o_tens => w_tens,
            o_ones => w_ones
	       );
	       
	    sevenseg_decoder1 : sevenseg_decoder
	    port map(
	       i_Hex => w_TMD4_o,
	       o_seg_n => seg
	    );
	    
	    alu1 : ALU
        Port map ( 
           i_A => f_Q, --register1
           i_B => f_Q1, --register2
           i_op => sw(2 downto 0),
           o_result => w_result,
           o_flags => w_flags
           );
	    
         register_proc : process (clk)
        begin
            if rising_edge(clk) then
                if w_fsmOutput(1) = '1' then
                    f_Q <= sw(7 downto 0);
                end if;
            end if;
        end process register_proc;
        
        register_proc2 : process (clk)
        begin
            if rising_edge(clk) then
                if w_fsmOutput(2) = '1' then
                    f_Q1 <= sw(7 downto 0);
                end if;
            end if;
        end process register_proc2;
	   

	-- CONCURRENT STATEMENTS ----------------------------
	   
        process(w_fsmOutput, w_sel)
    begin
        if w_fsmOutput = "0001" then
            an <= "1111";
        else
            an <= w_sel;
        end if;
    end process;
                 
        led(15 downto 12) <= w_flags;
        led(3 downto 0) <= w_fsmOutput;
        
        w_data <= f_Q when w_fsmOutput = "0010" else
			  f_Q1 when w_fsmOutput = "0100" else
			  w_result when w_fsmOutput = "1000" else
			  "00000000";
	
	
	
end top_basys3_arch;
