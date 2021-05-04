#  VHDL PROJECT - Parking assistant 

## Team members 
This project was created by Tereza Beránková,Samuel Blecha,Kryštof Buroň,Šimon Cieslar & Zuzana Czmelová

[Tereza Beránková]( https://github.com/Zuzanaczm/Digital-electronics-1/tree/main/Labs/project)
[Samuel Blecha]( https://github.com/) --doplnit
[Kryštof Buroň]( https://github.com/)
[Šimon Cieslar]( https://github.com/)
[Zuzana Czmelová]( https://github.com/)

## Project objectives 
Our aim was to made park assistant with HC-SR04 ultrasonic sensor, sound signaling using PWM, signaling by LED bargraph.

## Hardware description

## VHDL modules description and simulations

### VHDL design for parking assistant 
#### 1.Park assistant
**A)Process  from VHDL design**
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
 **B)Entities from VHDL design**
 
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
 
**C)Testbench for parking assistant** 
 
 ###### Konstanty v tomhle testbenchi byly  nadefinované  tímhle způsobem - ruzne distnance -> levely 
 
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
  
 **D)Screenshots of simulation** 
 

#### 2.URM (ultrasonic range meter) driver decoder 
**A)Process of URM driver decoder** 

  ``` vhdl
--------------------------------------------------------------------
    -- Process for sending 10us signal into a sensor & 
    -- For measuring returning signal
    --------------------------------------------------------------------
    p_distance_measurement : process(clk)
    begin
        if rising_edge(clk) then
            if (reset = '1') then         -- Synchronous reset
                s_state       <= INITIAL; -- Set initial state
                s_local_cnt   <= 0;       -- Clear all counters
                update_o      <= '0';     -- Reset update signal
                sensor_in_o   <= '0';     -- Reset sensor input
                s_distance    <= 201;     -- Initialize distance
            else
                case s_state is  
                              
                    when INITIAL =>-- Initial state                                              
                        if (reset = '0') then
                            s_state         <= PULSE;     
                            update_o <= '0';-- Setting mux update to 0                        
                        end if;
                        
                    when PULSE =>-- State for sending 10us pulse     
                        if (s_local_cnt >= (PULSE_LENGTH - 1)) then
                            s_local_cnt     <= 0;        -- Clear counter
                            sensor_in_o     <= '0';      -- Reset output
                            s_state         <= WAITING;  -- Next state
                        else -- 10 us counter
                            s_local_cnt     <= s_local_cnt + 1; 
                            sensor_in_o     <= '1';      
                        end if;
                        
                    when WAITING =>-- Waiting state for signal returning from sensor
                        if (sensor_out_i = '1') then 
                            s_state         <= COUNT; 
                        end if;
                        
                    when COUNT =>-- State for counting the length of returning signal
                        if (sensor_out_i = '1') then -- Counter
                            s_local_cnt     <= s_local_cnt + 1;
                        else -- Dividing s_distance(length) of measured signal by constant 100*58                           
                            s_distance      <= s_local_cnt /5800;    -- specified by datasheet & 
                            s_local_cnt     <= 0;                    -- to eliminate efect of clk
                            update_o        <='1';                   -- to get dist in cm.          
                            s_state         <= INITIAL;             
                        end if;                           
                      
                    when others =>-- Other states
                        s_state <= INITIAL;
        
                end case;
            end if; 
        end if; 
    end process p_distance_measurement;
    
    --------------------------------------------------------------------
    -- Process for quantization measured signal
    --------------------------------------------------------------------
    p_dist_decoder : process(s_distance)
    begin
        if   (s_distance <= g_lvl_0) then -- The closest distance
            dist_lvl_o <= "11";
        elsif(s_distance <= g_lvl_1) then
            dist_lvl_o <= "10";
        elsif(s_distance <= g_lvl_2) then
            dist_lvl_o <= "01";
        else                              -- The furthest distance
            dist_lvl_o <= "00";
        end if;           
    end process p_dist_decoder;
  ```   
  
  **B)Testbench**
  
  ``` vhdl
      --------------------------------------------------------------------
    -- Clock generation process
    --------------------------------------------------------------------
    p_clk_gen : process
    begin
        while now < 750 ms loop         
            s_clk <= '0';
            wait for c_CLK_100MHZ_PERIOD / 2;
            s_clk <= '1';
            wait for c_CLK_100MHZ_PERIOD / 2;
        end loop;
        wait;                           -- Process is suspended forever
    end process p_clk_gen;
    
    --------------------------------------------------------------------
    -- Reset generation process
    --------------------------------------------------------------------
    p_reset_gen : process
    begin
       
        --Initial reset activated
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
        wait for 500 us;              -- Waiting for inital pulse
            s_sensor_out_i <= '1';
        wait for 150 us;              -- "Reciving" distance lesser than lvl_0 distance
            s_sensor_out_i <= '0';    -- its length is 2.58 cm (150/58)
        wait for 50 us;               -- Waiting for sending 10us pulse (We have to wait
            s_sensor_out_i <= '1';    -- at least 10us. Here we wait 50us to be sure.)
        wait for 3000 us;             -- "Reciving" distance bigger than lvl_0 distance 
            s_sensor_out_i <= '0';    -- its length is 51.8 cm (3000/58)
        wait for 50 us;               -- Waiting for sending 10us pulse
            s_sensor_out_i <= '1';
        wait for 6000 us;             -- "Reciving" distance bigger than lvl_1 distance 
            s_sensor_out_i <= '0';    -- its length is 103.4 cm (6000/58)
        wait for 50 us;               -- Waiting for sending 10us pulse
            s_sensor_out_i <= '1';
        wait for 12000 us;            -- "Reciving" distance bigger than lvl_2 distance 
            s_sensor_out_i <= '0';    -- its length is 206.9 cm (12000/58)
        wait for 50 us;               -- Waiting for sending 10us pulse
            s_sensor_out_i <= '1';
        wait for 24000 us;            -- "Reciving" distance bigger than lvl_2 distance
            s_sensor_out_i <= '0';    -- its length is 413.8 cm (24000/58)
        wait for 50 us;
        report "Stimulus process finished" severity note;
        wait;
    end process p_stimulus;
``` 
**C) Screenshots of simulation**

#### 3.Beep generator ("submodules" of park assistant)
**A)VHDL design**
``` vhdl
 --------------------------------------------------------------------
    -- Process for changing frequency of the tone
    --------------------------------------------------------------------
    p_pulse_clock : process(pulse_clock_period,clk)  -- Generates signal, which determines the     
    begin                                            -- frequency of beeping.
        if (rising_edge(clk)) then
            if (s_pulse_counter < 100000*pulse_clock_period) then
                s_pulse_counter <= s_pulse_counter +1;
            else
                pc_out <= not pc_out;
                s_pulse_counter <= 0;                         
            end if;
        end if;
    end process p_pulse_clock;
    
    --------------------------------------------------------------------
    -- Process for changing frequency of tone depending on the input
    --------------------------------------------------------------------
    p_clock_enable : process(dist_lvl,clk)
    begin
        case dist_lvl is
            when "11" =>                            -- Shortest distance => continuous tone.
                s_en <= '1';                        -- Tone generator output enabled
            when "10" =>                            -- Second shortest distance => fast beeping
                pulse_clock_period <= fast_period;  -- Pulse clock generates fast beeping signal
                s_en  <= pc_out;                    -- Enables tone generator output with the frequencz of pulse clock
            when "01" =>                            -- Second longest distance => slow beeping
                pulse_clock_period <= slow_period;  -- Pulse clock generates slow beeping signal
                s_en  <= pc_out;                    -- Enables tone generator output with the frequencz of pulse clock
            when others =>                          -- Farthest distance => silence
                s_en <= '0';                        -- Tone generator output off
        end case;
    end process p_clock_enable;
    
    --------------------------------------------------------------------
    -- Tone generating process
    --------------------------------------------------------------------
    p_1kHz_gen : process(clk, s_en)                 -- Tone generator
    begin        
        if rising_edge(clk) then        
            if (reset = '1') then
                s_clk_counter   <= 0;
                s_local_clock   <= '0';
                tone_o          <= '0';
            elsif (s_clk_counter >= ((s_clk_period-1)/2 )) then
                s_clk_counter   <= 0;
                s_local_clock   <= not s_local_clock;
            else
                s_clk_counter   <= s_clk_counter + 1;
            end if;           
        end if;
           
        if (s_en = '1') then
            tone_o <= s_local_clock;   -- Enables tone gen. output 
        else
            tone_o <= '0';
        end if;
    end process p_1kHz_gen;

``` 
**B)Testbench**
```vhdl
 --------------------------------------------------------------------
    -- Reset generation process
    --------------------------------------------------------------------    
    p_clk_gen : process
    begin
        while now < 50 ms loop
            s_clk_100MHz <= '0';
            wait for c_CLK_100MHZ_PERIOD / 2;
            s_clk_100MHz <= '1';
            wait for c_CLK_100MHZ_PERIOD / 2;
        end loop;
        wait;
    end process p_clk_gen;
    
    --------------------------------------------------------------------
    -- Data generation process
    --------------------------------------------------------------------
    p_stimulus : process
    begin
        report "Stimulus process started" severity note;
        
            distance_lvl <= "00";
            wait for 10ms;
            distance_lvl <= "01";
            wait for 10ms;
            distance_lvl <= "10";
            wait for 10ms;
            distance_lvl <= "11";
            
        report "Stimulus process finished" severity note;
        wait;
    end process p_stimulus;
   ``` 
   
**C) Screenshot of simulation**

#### 4. Distance comparator 
**A)VHDL design**
  ``` vhdl
 --------------------------------------------------------------------
    -- Process for finding highest value
    --------------------------------------------------------------------
    p_comp : process(a_i,b_i,c_i,d_i,e_i,f_i,temp_1,temp_2,temp_3,temp_4)
    begin
        -- Finding the highest value from input signals, saving them into temporary signals
        if (b_i >= a_i) then  
            temp_1 <= b_i;
        else
            temp_1 <= a_i;
        end if;
        
        if (c_i >= d_i) then
            temp_2 <= c_i;
        else
            temp_2 <= d_i;
        end if;
        
        if (e_i >= f_i) then
            temp_3 <= e_i;
        else
            temp_3 <= f_i;
        end if;
        
        -- Finding the highest value of the temporary signals.
        if (temp_1 >= temp_2) then
            temp_4 <= temp_1;
        else
            temp_4 <= temp_2;
        end if;
        
        -- Greatest value sent to output.
        if (temp_4 >= temp_3) then
            greatest_o <= temp_4;
        else
            greatest_o <= temp_3;
        end if;
    end process p_comp;
  ```  
  **B) Testbench**
  ``` vhdl
   -- Connecting testbench signals with distance_comparator
    uut_distance_comparator : entity work.distance_comparator
        port map(
            a_i           => s_a,
            b_i           => s_b,
            c_i           => s_c,
            d_i           => s_d,
            e_i           => s_e,
            f_i           => s_f,
            greatest_o    => s_goat
        );
    --------------------------------------------------------------------
    -- Data generation process
    --------------------------------------------------------------------
    p_stimulus : process
    begin        
        report "Stimulus process started" severity note;
        s_a <= "01";
        s_b <= "00";
        s_c <= "00";
        s_d <= "00";
        s_e <= "00";
        s_f <= "00";
        wait for 10ns;
        
        s_a <= "00";
        s_b <= "01";
        s_c <= "00";
        s_d <= "00";
        s_e <= "00";
        s_f <= "00";
        wait for 10ns;
        
        s_a <= "00";
        s_b <= "00";
        s_c <= "01";
        s_d <= "00";
        s_e <= "00";
        s_f <= "00";
        wait for 10ns;
        
        s_a <= "00";
        s_b <= "00";
        s_c <= "00";
        s_d <= "01";
        s_e <= "00";
        s_f <= "00";
        wait for 10ns;
        
        s_a <= "00";
        s_b <= "00";
        s_c <= "00";
        s_d <= "01";
        s_e <= "00";
        s_f <= "00";
        wait for 10ns;
        
        s_a <= "00";
        s_b <= "00";
        s_c <= "00";
        s_d <= "00";
        s_e <= "01";
        s_f <= "00";
        wait for 10ns;
        
        s_a <= "00";
        s_b <= "00";
        s_c <= "00";
        s_d <= "00";
        s_e <= "00";
        s_f <= "01";
        wait for 10ns;
        
        s_a <= "11";
        s_b <= "11";
        s_c <= "00";
        s_d <= "00";
        s_e <= "00";
        s_f <= "01";
        wait for 10ns;
        wait;
    end process p_stimulus;
   ``` 
  **C) Screenshot of simulation**
  
#### 5. cnt_up_down 
**A) VDHL design**
```vhdl
--------------------------------------------------------------------
    -- p_cnt_up_down:
    -- Clocked process with synchronous reset which implements n-bit 
    -- up/down counter.
    --------------------------------------------------------------------
    p_cnt_up_down : process(clk)
    begin
        if rising_edge(clk) then
        
            if (reset = '1') then               -- Synchronous reset
                s_cnt_local <= (others => '0'); -- Clear all bits

            elsif (en_i = '1') then       -- Test if counter is enabled
                if (cnt_up_i = '1') then
                    if (s_cnt_local >= b"101") then     -- Counter Shortened to 6 values
                        s_cnt_local <= b"000";
                    else
                        s_cnt_local <= s_cnt_local + 1;
                    end if;                    
                else
                    s_cnt_local <= s_cnt_local - 1;
                end if;
            end if;
        end if;
    end process p_cnt_up_down;

    -- Output must be retyped from "unsigned" to "std_logic_vector"
    cnt_o <= std_logic_vector(s_cnt_local);
   ```
   **B)Testbench**
   
    ```vhdl
   -- Connecting testbench signals with cnt_up_down entity
    -- (Unit Under Test)
    uut_cnt : entity work.cnt_up_down
        generic map(
            g_CNT_WIDTH  => c_CNT_WIDTH
        )
        port map(
            clk      => s_clk_100MHz,
            reset    => s_reset,
            en_i     => s_en,
            cnt_up_i => s_cnt_up,
            cnt_o    => s_cnt
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

    --------------------------------------------------------------------
    -- Reset generation process
    --------------------------------------------------------------------
    p_reset_gen : process
    begin
        
        -- Reset activated
        s_reset <= '1';
        wait for 50 ns;

        s_reset <= '0';
        wait;
    end process p_reset_gen;

    --------------------------------------------------------------------
    -- Data generation process
    --------------------------------------------------------------------
    p_stimulus : process
    begin
        report "Stimulus process started" severity note;

        -- Enable counting
        s_en     <= '1';
        s_cnt_up <= '1';
        wait for 380 ns;
        -- Disable counting
        s_en     <= '0';

        report "Stimulus process finished" severity note;
        wait;
    end process p_stimulus;
    ```
 
 
**C)Screenshot of simulation**

#### 6. mux_2bit_6to1
**A)VHDL design**
**B)Testbench**
**C)Screenshot of simulation**

## TOP module description and simulations
napojení signálů --> stejný jako PA /medium ,které napojuje piny desky `Arty-A7-100` na ten kód/

## Video

## References
--inspo video od Kryštofa
--soubor reference manual senzoru 


