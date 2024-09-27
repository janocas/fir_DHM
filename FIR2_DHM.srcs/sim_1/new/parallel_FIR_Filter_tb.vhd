----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/20/2024 04:28:40 PM
-- Design Name: 
-- Module Name: parallel_FIR_Filter_tb - Behavioral
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
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity Parallel_FIR_Filter_tb is
end;

architecture bench of Parallel_FIR_Filter_tb is

  component Parallel_FIR_Filter
      Generic (
          FILTER_TAPS  : integer := 60;
          INPUT_WIDTH  : integer range 8 to 25 := 24; 
          COEFF_WIDTH  : integer range 8 to 18 := 16;
          OUTPUT_WIDTH : integer range 8 to 43 := 24
      );
      Port ( 
             clk    : in STD_LOGIC;
             reset  : in STD_LOGIC;
             enable : in STD_LOGIC;
             data_i : in STD_LOGIC_VECTOR (INPUT_WIDTH-1 downto 0);
             data_o : out STD_LOGIC_VECTOR (OUTPUT_WIDTH-1 downto 0)
             );
  end component;
  

  
  -------------------------------------------------------------------------------------
  -- Testbench Internal Signals
  -------------------------------------------------------------------------------------
  
  file file_data : text;
  file file_res : text;
  
  constant  INPUT_WIDTH : integer := 16;
  constant  OUTPUT_WIDTH : integer := 16;
  
  signal clk: STD_LOGIC;
  signal reset: STD_LOGIC;
  signal enable: STD_LOGIC;
  type v_data_i is array(0 to 1) of std_logic_vector(INPUT_WIDTH-1 downto 0);
  signal data_i: v_data_i;
  type v_data_o is array(0 to 1) of std_logic_vector(OUTPUT_WIDTH-1 downto 0);
  signal data_o: v_data_o;

  constant clock_period: time := 10 ns;
  signal stop: boolean;
  signal even_flag : std_logic; 

begin

  -- Insert values for generic parameters !!
  gen_fir: 
  	for I in 0 to 1 generate
	  firx : Parallel_FIR_Filter generic map ( FILTER_TAPS  => 60,
											 INPUT_WIDTH  => 16,
											 COEFF_WIDTH  => 16,
											 OUTPUT_WIDTH =>  16)
								  port map ( clk          => clk,
											 reset        => reset,
											 enable       => enable,
											 data_i       => data_i(I),
											 data_o       => data_o(I) );
 	end generate gen_fir;	
 
  stimulus: process
  	variable v_iline : line;
  	variable v_oline : line;
  	--variable v_data_i : std_logic_vector (INPUT_WIDTH-1 downto 0);
  	variable v_data_i : integer;
  	variable v_data_o : integer;
  	variable fstatus_rd: file_open_status; 
  	variable fstatus_wr: file_open_status;
  begin
  
	  file_open(fstatus_rd, file_data, "data.txt", read_mode);
	  file_open(fstatus_wr, file_res, "fir_results.txt", write_mode);
	  
      report "data.txt" & LF & HT & "file_open_status = " & file_open_status'image(fstatus_rd);
      assert fstatus_rd = OPEN_OK 
            report "file_open_status /= file_ok"
            severity FAILURE;    -- end simulation
            
	  report "fir_results.txt" & LF & HT & "file_open_status = " & file_open_status'image(fstatus_wr);
      assert fstatus_wr = OPEN_OK 
            report "file_open_status /= file_ok"
            severity FAILURE;    -- end simulation
	  

	  reset <= '1'; wait for 50 ns;
	  reset <= '0'; wait for 50 ns;
	  
	  
	  while not endfile(file_data) loop
		wait until falling_edge(clk);
		-- Filter reading Reals
		readline(file_data, v_iline);
		read(v_iline, v_data_i);
		data_i(0) <= std_logic_vector(TO_UNSIGNED(v_data_i, data_i(0)'length));
		
		-- Filter readin Imags
		readline(file_data, v_iline);
		read(v_iline, v_data_i); 
		data_i(1) <= std_logic_vector(TO_UNSIGNED(v_data_i, data_i(1)'length));
		--wait for 50 ns;
		
		wait for 10 ns; -- NEEDS revision
		v_data_o := to_integer(signed(data_o(0)));
		--v_data_o := 5;
		write(v_oline, v_data_o, left);
		writeline(file_res, v_oline);

		v_data_o := to_integer(signed(data_o(1)));
		write(v_oline, v_data_o, right);
		writeline(file_res, v_oline);
	
		
	  end loop;
	  stop <= true;
	  file_close(file_data);
	  file_close(file_res);
  end process;

  clocking: process
  begin
    while not stop loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;