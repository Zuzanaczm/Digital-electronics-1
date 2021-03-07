
# Lab assignment - Zuzana Czmelová (04-segment)
## Part 1 - Truth table

| **Hex** | **Input** | **A** | **B** | **C** | **D** | **E** | **F** | **G** |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| 0 | 0000 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
| 1 | 0001 | 1 | 0 | 0 | 1 | 1 | 1 | 1 |
| 2 | 0010     | 0  | 0  | 1  | 0 | 0  | 1  | 0  |
| 3 | 0011    |  0 |  0 | 0  |  0 | 1 |  1 |  0 |
| 4 | 0100     |  1 | 0  | 0  | 1  | 1  |  0 | 0  |
| 5 | 0101    | 0 | 1  | 0  | 0  | 1  | 0  | 0  |
| 6 | 0110    | 0  | 1  | 0  | 0  | 0  | 0  | 0  |
| 7 | 0111     | 0  | 0  | 0  | 1  | 1  | 1  | 1  |
| 8 |  1000    | 0  | 0  |0   |  0 |0   |0   |  0 |
| 9 | 1001     | 0  | 0  | 0  | 0  | 1  |  0 | 0  |
| A | 1010     | 0  | 0 | 0  |  1 | 0  |  0 | 0  |
| b | 1011     | 1  | 1  | 0  |  0 |  0 | 0  | 0  |
| C | 1100     |  0 |  1 | 1 | 0 |  0 | 0 | 1  |
| d | 1101     |  1 |  0 |0  | 0  |  0 | 1  | 0  |
| E | 1110 | 0 | 1 | 1 | 0 | 0 | 0 | 0 |
| F | 1111 | 0 | 1 | 1 | 1 | 0 | 0 | 0 |

### Connection of 7-segment display on Nexys board
```
AN0 => J17                     CA => T10
AN1 => J18                     CB => R10
AN2 => T9                      CC => K16
AN3 => J14                     CD => K13
AN4 => P14                     CE => P15
AN5 => T14                     CF => T11
AN6 => K2                      CG => L18
AN7 => U13                     DP => H15
```
Both anode and cathode signals are active-low.

## Part 2 - Seven-segment display decoder

### A) VHDL design source
```vhdl
architecture Behavioral of hex_7seg is
begin

    p_7seg_decoder : process(hex_i)
    begin
        case hex_i is
            when "0000" =>
                seg_o <= "0000001";     -- 0
                
            when "0001" =>
                seg_o <= "1001111";     -- 1
                
            when "0010" =>
                seg_o <= "0010010";      --2
                
            when "0011" =>
                seg_o <= "0000110";     --3
                
            when "0100" =>
                seg_o <= "1001100";     --4
                
            when "0101" =>
                seg_o <= "0100100";    --5
                
            when "0110" =>              --6
                seg_o <= "0100000";    
                
            when "0111" =>              --7
                seg_o <= "0001111";
                
            when "1000" =>             --8
                seg_o <= "0000000";
                
            when "1001" =>             --9
                seg_o <= "0000100";
                
            when "1010" =>             --A
                seg_o <= "0001000";
                
            when "1011" =>             --b
                seg_o <= "1100000";
                
            when "1100" =>            --C
                seg_o <= "0110001";
                
            when "1101" =>             --d
                seg_o <= "1000010";
                
                
            when "1110" =>
                seg_o <= "0110000";     -- E
                
            when others =>
                seg_o <= "0111000";     -- F
        end case;
    end process p_7seg_decoder;

end Behavioral;
```
### B) VHDL testbench 

  ```vhdl
p_stimulus : process
    begin
  
        report "Stimulus process started" severity note;
       
       s_hex <= "0000";
        wait for 100ns ;
        
       s_hex <= "0001";
         wait for 100ns ;
         
       s_hex <= "0010"; 
        wait for 100ns ;
        
       s_hex <= "0011"; 
        wait for 100ns ;
        
       s_hex <= "0100";
        wait for 100ns ;
        
       s_hex <= "0101";  
        wait for 100ns ;
        
       s_hex <= "0110"; 
        wait for 100ns ;
        
       s_hex <= "0111"; 
       wait for 100ns ;
     
       s_hex <= "1000"; 
       wait for 100ns ;
   
        s_hex <= "1001"; 
        wait for 100ns ;
        
       s_hex <= "1010"; 
       wait for 100ns ;
     
       s_hex <= "1011"; 
       wait for 100ns ;
       
       s_hex <= "1100"; 
        wait for 100ns ;
        
       s_hex <= "1101"; 
       wait for 100ns ;
     
       s_hex <= "1110"; 
       wait for 100ns ;
       
        s_hex <= "1111"; 
       wait for 100ns ;
       
       report "Stimulus process finished" severity note;
        wait;
    end process p_stimulus;
  ```
  
 ### C) Screenshot of simulation 
 ![](images/simulation.png)
 
### D) VHDL code from TOP.vhd
 ```vhdl
architecture Behavioral of top is

begin

-- Instance (copy) of hex_7seg entity
    hex2seg : entity work.hex_7seg
        port map
        (
            hex_i    => SW,  
            seg_o(6) => CA,
            seg_o(5) => CB,
            seg_o(4) => CC,
            seg_o(3) => CD,
            seg_o(2) => CE,
            seg_o(1) => CF,
            seg_o(0) => CG
        );

 
 ```

## Part 3 - LED (7:4) indicators

### A) Truth table

| **Hex** | **Inputs** | **LED4** | **LED5** | **LED6** | **LED7** |
| :-: | :-: | :-: | :-: | :-: | :-: |
| 0 | 0000 | 1 | 0 | 0 | 0 |
| 1 | 0001 | 0 | 0 | 1 | 1 |
| 2 | 0010 | 0 | 0 | 0 | 1 |
| 3 | 0011 | 0 | 0 | 1 | 0 |
| 4 | 0100 | 0 | 0 | 0 | 1 |
| 5 | 0101 | 0 | 0 | 1 | 0 |
| 6 | 0110 | 0 | 0 | 0 | 0 |
| 7 | 0111 | 0 | 0 | 1 | 0 |
| 8 | 1000 | 0 | 0 | 0 | 1 |
| 9 | 1001 | 0 | 0 | 1 | 0 |
| A | 1010 | 0 | 1 | 0 | 0 |
| b | 1011 | 0 | 1 | 1 | 0 |
| C | 1100 | 0 | 1 | 0 | 0 |
| d | 1101 | 0 | 1 | 1 | 0 |
| E | 1110 | 0 | 1 | 0 | 0 |
| F | 1111 | 0 | 1 | 1 | 0 |
