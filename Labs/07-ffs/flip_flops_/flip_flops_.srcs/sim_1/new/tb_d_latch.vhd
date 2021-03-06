----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.03.2021 11:01:59
-- Design Name: 
-- Module Name: tb_d_latch - Behavioral
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

entity tb_d_latch is
--  Port ( );
end tb_d_latch;

architecture Behavioral of tb_d_latch is
           signal s_en    : STD_LOGIC;
           signal s_d     : STD_LOGIC;
           signal s_arst  : STD_LOGIC;
           signal s_q     : STD_LOGIC;
           signal s_q_bar : STD_LOGIC;
begin

uut_d_latch : entity work.d_latch

        port map(
            en    => s_en,    
            d     => s_d,     
            arst  => s_arst,  
            q     => s_q,     
            q_bar => s_q_bar 
        );
        
--------------------------------------------------------------------
-- Reset generation process
--------------------------------------------------------------------
p_reset_gen : process
begin
    s_arst <= '1';
    wait for 50 ns;
    
    s_arst <= '0';
    wait for 75 ns;
    
    s_arst <= '1';
    wait for 100 ns;
    
    s_arst <= '0';
    wait for 275 ns;        
    
    s_arst <= '0';
    wait for 150 ns;
    
    s_arst <= '1';
    wait for 50 ns;
    
    s_arst <= '0';
    wait for 100 ns;
    
    s_arst <= '1';
    wait for 20 ns;
    
    s_arst <= '0';
    wait for 200 ns;  
end process p_reset_gen;


p_stimulus : process
begin
    report "Stimulus process started" severity note;

    -- Enable latch
    s_en     <= '1';
    
    -- Output change
    s_d <= '1';
    wait for 50 ns;       
    
    s_d <= '0';
    wait for 50 ns;
    
    s_d <= '1';
    wait for 50 ns;
    
    s_d <= '0';
    wait for 50 ns; 
       
    s_d <= '1';
    wait for 50 ns;

    -- Expected output
    assert ((s_q = '1') and (s_q_bar = '0' ))
    -- If false, then report an error
    report "Test failed for input: '1' " severity error;
        
    s_d <= '0';
    wait for 50 ns;

    s_d <= '1';
    wait for 50 ns;
    
    s_d <= '0';
    wait for 50 ns;
    
    s_d <= '1';
    wait for 50 ns;
    
    s_d <= '0';
    wait for 50 ns;
    --500ns
    
    -- Expected output
    assert ((s_q = '0') and (s_q_bar = '1' ))
    -- If false, then report an error
    report "Test failed for input: '0' " severity error;
    
    s_d <= '1';
    wait for 25 ns;
    
    -- Disable latch
    s_en     <= '0';
    wait for 25 ns;
        
    s_d <= '0';
    wait for 50 ns;
    
    s_d <= '1';
    wait for 50 ns;
    
    s_d <= '0';
    wait for 50 ns; 
       
    s_d <= '1';
    wait for 25 ns;
    
    -- Enable latch
    s_en     <= '1';
    wait for 25 ns;
    
    -- Output change
    s_d <= '0';
    wait for 50 ns;
    
    s_d <= '1';
    wait for 50 ns;
    
    s_d <= '0';
    wait for 50 ns;
    
    s_d <= '1';
    wait for 50 ns; 
       
    s_d <= '0';
    wait for 50 ns;
    
    report "Stimulus process finished" severity note;
    wait;
end process p_stimulus;

end Behavioral;