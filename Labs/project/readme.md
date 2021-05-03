#  VHDL PROJECT - Parking assistant 

## Team members 
This project was created by Tereza Beránková,Samuel Blecha,Kryštof Buroň,Šimon Cieslar & Zuzana Czmelová

[Link to  GitHub project folder]( https://github.com/Zuzanaczm/Digital-electronics-1/tree/main/Labs/project)
--doplnit ostatnych rip

## Project objectives 
Our aim was to create park assistant with HC-SR04 ultrasonic sensor, sound signaling using PWM, signaling by LED bargraph.

## Hardware description

## VHDL modules description and simulations

### VHDL design for parking assistant 
#### 1.Park assistant
**A) process  +komentár**
```vhdl
 --------------------------------------------------------------------
    -- Proces for switching between Left & Center & Right front sensor
    -- So only one is measuring at the moment 
    --------------------------------------------------------------------
    p_front_sensor_select : process(clk)
    begin
        if rising_edge(clk) then
            if (reset = '1') then
                s_sensor_front <= LEFT; -- Initial state                 
            else
                case s_sensor_front is
                
                    when LEFT =>
                        s_sensorfront_i <= sensor0_i;        -- Conecting input and output of urm_driver_decoder(front)
                        sensor0_o <= s_sensorfront_o;        -- to its proper sensor input and output...
                        
                        if(s_updatefront_i = '1') then       -- Reciving update signal will...
                            s_dist_lvl0 <= s_dist_lvl_front; -- Save measured value to proper interal signal &
                            s_sensor_front <= CENTER;        -- Change state.
                        end if;                              -- Rest works same, but with its own sensors.    
                        
                    when CENTER =>                
                        s_sensorfront_i <= sensor1_i;
                        sensor1_o <= s_sensorfront_o;
    
                        if(s_updatefront_i = '1') then
                            s_dist_lvl1 <= s_dist_lvl_front;
                            s_sensor_front <= RIGHT;
                        end if;
                        
                    when RIGHT =>
                        s_sensorfront_i <= sensor2_i;
                        sensor2_o <= s_sensorfront_o;
    
                        if(s_updatefront_i = '1') then
                            s_dist_lvl2 <= s_dist_lvl_front;
                            s_sensor_front <= LEFT;
                        end if;
                        
                    when others =>-- Other states
                        s_sensor_front <= LEFT;
        
                end case;
            end if;
        end if;
    end process p_front_sensor_select;
    
    --------------------------------------------------------------------
    -- Proces for switching between Left & Center & Right back sensor
    -- So only one is measuring at the moment
    --------------------------------------------------------------------
    p_back_sensor_select : process(clk)
    begin
        if rising_edge(clk) then
            if (reset = '1') then
                s_sensor_back <= LEFT; -- Initial state       
            else
                case s_sensor_back is
                
                    when LEFT =>
                        s_sensorback_i <= sensor3_i;        -- Conecting input and output of urm_driver_decoder(back)   
                        sensor3_o <= s_sensorback_o;        -- to its proper sensor input and output...                  
    
                        if(s_updateback_i = '1') then       -- Reciving update signal will...                            
                            s_dist_lvl3 <= s_dist_lvl_back; -- Save measured value to proper interal signal &            
                            s_sensor_back <= CENTER;        -- Change state.                                             
                        end if;                             -- Rest works same, but with its own sensors.
                        
                    when CENTER =>                
                        s_sensorback_i <= sensor4_i;
                        sensor4_o <= s_sensorback_o;
    
                        if(s_updateback_i = '1') then
                            s_dist_lvl4 <= s_dist_lvl_back;
                            s_sensor_back <= RIGHT;
                        end if;
                        
                    when RIGHT =>
                        s_sensorback_i <= sensor5_i;
                        sensor5_o <= s_sensorback_o;
    
                        if(s_updateback_i = '1') then
                            s_dist_lvl5 <= s_dist_lvl_back;
                            s_sensor_back <= LEFT;
                        end if;
                        
                    when others =>-- Other states
                        s_sensor_back <= LEFT;
                        
                end case;
            end if;
        end if;
    end process p_back_sensor_select;  
 ```
 **B) entity + komentár**
 
  ```vhdl
 --------------------------------------------------------------------
    -- Connecting testbench signals with entities 
    --------------------------------------------------------------------  
    -- Entity: Ultrasonic range meter driver - for front sensors
    uut_urm_driver_front : entity work.urm_driver_decoder
            generic map(
                g_lvl_0      => g_distance_threshold1,
                g_lvl_1      => g_distance_threshold2,
                g_lvl_2      => g_distance_threshold3,
                g_lvl_3      => g_distance_threshold4
            )
            port map(
                clk          => clk,
                reset        => reset,
                sensor_out_i => s_sensorfront_i,
                sensor_in_o  => s_sensorfront_o,
                dist_lvl_o   => s_dist_lvl_front,
                update_o     => s_updatefront_i
            );
            
    -- Entity: Ultrasonic range meter driver - for back sensors
    uut_urm_driver_back : entity work.urm_driver_decoder
            generic map(
                g_lvl_0      => g_distance_threshold1,
                g_lvl_1      => g_distance_threshold2,
                g_lvl_2      => g_distance_threshold3,
                g_lvl_3      => g_distance_threshold4
            )
            port map(
                clk          => clk,
                reset        => reset,
                sensor_out_i => s_sensorback_i,
                sensor_in_o  => s_sensorback_o,
                dist_lvl_o   => s_dist_lvl_back,
                update_o     => s_updateback_i
            );
    
    -- Entity: Comparation of distances measured by sensors        
    uut_distance_comparator : entity work.distance_comparator
            port map (
                a_i          => s_dist_lvl0,
                b_i          => s_dist_lvl1,
                c_i          => s_dist_lvl2,
                d_i          => s_dist_lvl3,
                e_i          => s_dist_lvl4,
                f_i          => s_dist_lvl5,
                greatest_o   => s_tone_gen_data_i
            );
            
     -- Entity: For tone generation dependant on closest measuerd range
    uut_tone_gen: entity work.beep_generator
            generic map(
                tone_freq    =>  g_tone_freq,  -- 1000; --Hz
                slow_period  =>  g_slow_period,  -- 5; --ms
                fast_period  =>  g_fast_period  -- 2  --ms
            )  
            port map  (
                clk          =>  clk,
                reset        =>  reset,
                dist_lvl     =>  s_tone_gen_data_i,
                tone_o       =>  sound_o
            );
    
    -- Entity: Multiplexer for 6-LEDs(bargraphs)      
    uut_mux_led: entity work.mux_2bit_6to1
            port map (
                a_i          =>  s_dist_lvl0, 
                b_i          =>  s_dist_lvl1, 
                c_i          =>  s_dist_lvl2, 
                d_i          =>  s_dist_lvl3, 
                e_i          =>  s_dist_lvl4, 
                f_i          =>  s_dist_lvl5, 
                sel_i        =>  s_sel_o,
                f_o          =>  LED_o
            );
            
    -- Entity: For sending pulse every 2ms
    uut_clk_en0 : entity work.clock_enable
            generic map(
                g_MAX        => 200000
            )
            port map(
                clk          => clk,
                reset        => reset,
                ce_o         => s_2ms
            );   
                 
    -- Entity: To change multiplexer selector signal
    uut_bin_cnt0 : entity work.cnt_up_down
            generic map(
                g_CNT_WIDTH  => 3
            )
            port map(
                clk          => clk,
                reset        => reset,
                en_i         => s_2ms,
                cnt_up_i     => '1',
                cnt_o        => s_sel_o            
            );             
                -- Connecting internal mux selecting singal to output          
                sel_o <= s_sel_o;
                           
end Behavioral;
 ```
 
**C) testbench** 
 Konstanty v tomhle testbenchi byly takhle nadefinované  tímhle způsobem - ruzne distnance -> levely 
 
  ```vhdl
  --------------------------------------------------------------------
    -- Clock generation process
    --------------------------------------------------------------------
    p_clk_gen : process
    begin
        while now < 100 ms loop         
            s_clk <= '0';
            wait for c_CLK_100MHZ_PERIOD / 2;
            s_clk <= '1';
            wait for c_CLK_100MHZ_PERIOD / 2;
        end loop;
        wait;   
    end process p_clk_gen;
    
    --------------------------------------------------------------------
    -- Reset generation process
    --------------------------------------------------------------------
    p_reset_gen : process
    begin
       
        -- Initial reset activated
        s_reset <= '1';
        wait for 100 us;
    
        -- Reset deactivated
        s_reset <= '0';
        wait for 3 ms;
        
        -- Reset activated
        s_reset <= '1';
        wait for 100 us;
    
        -- Reset deactivated
        s_reset <= '0';
    
        wait;
    end process p_reset_gen;
    
    --------------------------------------------------------------------
    -- Data generation process
    --------------------------------------------------------------------
    p_stimulus : process
    begin
        report "Stimulus process started" severity note;
        
       --                     --1st block 
        wait for 180 us;
        s_sensor0_out_i <= '1';
        s_sensor3_out_i <= '1';
        wait for c_dist_0;
        s_sensor0_out_i <= '0';
        s_sensor3_out_i <= '0';
        
        wait for 180 us;        
        s_sensor1_out_i <= '1';
        s_sensor4_out_i <= '1'; 
        wait for c_dist_0;      
        s_sensor1_out_i <= '0';
        s_sensor4_out_i <= '0'; 
        
        wait for 100 us;
        s_sensor2_out_i <= '1';
        s_sensor5_out_i <= '1';
        wait for c_dist_0;
        s_sensor2_out_i <= '0';
        s_sensor5_out_i <= '0';
       --                     --2nd block                     
        wait for 180 us;
        s_sensor0_out_i <= '1';
        s_sensor3_out_i <= '1';
        wait for c_dist_4;
        s_sensor0_out_i <= '0';
        s_sensor3_out_i <= '0';
        
        wait for 180 us;        
        s_sensor1_out_i <= '1';
        s_sensor4_out_i <= '1'; 
        wait for c_dist_2;      
        s_sensor1_out_i <= '0';
        s_sensor4_out_i <= '0'; 
        
        wait for 100 us;
        s_sensor2_out_i <= '1';
        s_sensor5_out_i <= '1';
        wait for c_dist_3;
        s_sensor2_out_i <= '0';
        s_sensor5_out_i <= '0'; 
       --                     --3rd block                       
        wait for 180 us;
        s_sensor0_out_i <= '1';
        s_sensor3_out_i <= '1';
        wait for c_dist_3;
        s_sensor0_out_i <= '0';
        s_sensor3_out_i <= '0';
        
        wait for 180 us;        
        s_sensor1_out_i <= '1';
        s_sensor4_out_i <= '1'; 
        wait for c_dist_2;      
        s_sensor1_out_i <= '0';
        s_sensor4_out_i <= '0'; 
        
        wait for 100 us;
        s_sensor2_out_i <= '1';
        s_sensor5_out_i <= '1';
        wait for c_dist_4;
        s_sensor2_out_i <= '0';
        s_sensor5_out_i <= '0';
       --                     --4th block
        wait for 15 us;
        s_sensor0_out_i <= '1';
        s_sensor3_out_i <= '1';
        wait for c_dist_5;
        s_sensor0_out_i <= '0';
        s_sensor3_out_i <= '0';
       
        wait for 11 us;
        s_sensor1_out_i <= '1';
        s_sensor4_out_i <= '1';
        wait for c_dist_5;
        s_sensor1_out_i <= '0'; 
        s_sensor4_out_i <= '0';
        
        wait for 130 us;
        s_sensor2_out_i <= '1';
        s_sensor5_out_i <= '1';
        wait for c_dist_5;
        s_sensor2_out_i <= '0';
        s_sensor5_out_i <= '0';

        report "Stimulus process finished" severity note;
        wait;
    end process p_stimulus;
  ```    
  
 **D) screenshot of simulation** 
 

#### 2.driver
#### 3. beep beep 
#### 4. distance comparator 
#### 5. cnt + mux
 
 
## TOP module description and simulations

## Video

## References



