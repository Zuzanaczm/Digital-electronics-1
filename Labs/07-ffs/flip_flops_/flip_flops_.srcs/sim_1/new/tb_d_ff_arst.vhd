library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity tb_d_ff_arst is
--  Port ( );
end tb_d_ff_arst;

architecture Behavioral of tb_d_ff_arst is

          -- Local constants
          constant c_CLK_100MHZ_PERIOD : time    := 10 ns;
    
          signal s_clk_100MHz     : STD_LOGIC;
          signal s_arst  : STD_LOGIC;
          signal s_d     : STD_LOGIC;
          signal s_q     : STD_LOGIC;
          signal s_q_bar : STD_LOGIC;
begin
    uut_d_ff_arst : entity work.d_ff_arst
    port map
    (
        clk    => s_clk_100MHz,
        arst  => s_arst,
        d     => s_d,
        q     => s_q,
        q_bar => s_q_bar
    );

    --------------------------------------------------------------------
    -- Clock generation process
    --------------------------------------------------------------------
    p_clk_gen : process
    begin
        while now < 750 ns loop         -- 75 periods of 100MHz clock
            s_clk_100MHz <= '0';
            wait for c_CLK_100MHZ_PERIOD / 2;
            s_clk_100MHz <= '1';
            wait for c_CLK_100MHZ_PERIOD / 2;
        end loop;
        wait;
    end process p_clk_gen;
    
    p_reset_gen : process
    begin
        s_arst <= '0';
        wait for 53ns;
        
        s_arst <= '1';
        wait for 5ns;
        
        s_arst <= '0';
        
        wait for 14ns;
        s_arst <= '1';
        
        wait for 30ns;
        s_arst <= '0';
        
        wait for 45ns;
        s_arst <= '1';
        
        wait for 30ns;
        s_arst <= '0';
        
        wait;
    end process p_reset_gen;

     p_stimulus : process
    begin
        report "Stimulus process started" severity note;
        s_d  <= '0';
        
        wait for 10ns;
        s_d  <= '1';
        wait for 10ns;
        s_d  <= '0';
        wait for 10ns;
        s_d  <= '1';
        wait for 10ns;
        s_d  <= '0';
        wait for 10ns;
        s_d  <= '1';
        wait for 10ns;
        s_d  <= '0';
        wait for 10ns;
        
        wait for 3ns;
        assert(s_d = '0' and  s_arst = '1' and s_q = '0')
        report "Test failed for input combination: d='0', arst='1', s_q = '0'." severity error;
        
        wait for 7ns;
        s_d  <= '1';
        wait for 10ns;
        s_d  <= '0';
        wait for 10ns;
        s_d  <= '1';
        
        wait for 3ns;
        assert(s_d = '1' and  s_arst = '0' and s_q = '0')
        report "Test failed for input combination: d='1', arst='0', s_q = '0'." severity error;
        
        wait for 7ns;
        s_d  <= '0';
        wait for 10ns;
        s_d  <= '1';
        wait for 10ns;
        s_d  <= '0';
        wait for 10ns;
        
        wait for 3ns;
        assert(s_d = '0' and  s_arst = '0' and s_q = '0')
        report "Test failed for input combination: d='0', arst='0', s_q='0'." severity error;
        
        wait for 7ns;
        s_d  <= '1';
        wait for 10ns;
        
        s_d  <= '0';
        wait for 10ns;
        s_d  <= '1';
        
        wait for 3ns;
        assert(s_d = '1' and  s_arst = '1' and s_q = '0')
        report "Test failed for input combination: d='1', arst='1', s_q='0'." severity error;
        
        report "Stimulus process finished" severity note;
        wait;
    end process p_stimulus;
end Behavioral;