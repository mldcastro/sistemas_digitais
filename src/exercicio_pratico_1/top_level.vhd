library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity top_level_system is
  port (
    clk        : in    std_logic;
    reset      : in    std_logic;
    count_down : in    std_logic;
    load       : in    std_logic;
    selector   : in    std_logic;
    data       : in    std_logic_vector(7 downto 0);

    display_0 : out   std_logic_vector(6 downto 0);
    display_1 : out   std_logic_vector(6 downto 0)
  );
end entity top_level_system;

architecture structural of top_level_system is

  signal counter_out            : unsigned(7 downto 0);
  signal entry_reg_out          : unsigned(7 downto 0);
  signal full_adder_out         : unsigned(7 downto 0);
  signal xilinx_subtractor_out  : unsigned(7 downto 0);
  signal mux_out                : unsigned(7 downto 0);
  signal internal_reg_out       : unsigned(7 downto 0);
  signal nibble_converter_0_out : unsigned(7 downto 0);
  signal nibble_converter_1_out : unsigned(7 downto 0);

begin

  counter_proc : process (clk, reset) is
  begin

    if (reset = '1') then
      counter_out <= (others => '0');
    elsif rising_edge(clk) then
      if (count_down = '0') then
        counter_out <= counter_out + 1;
      else
        counter_out <= counter_out - 1;
      end if;
    end if;

  end process counter_proc;

  entry_reg_proc : process (clk, reset) is
  begin

    if (reset = '1') then
      entry_reg_out <= (others => '0');
    elsif rising_edge(clk) then
      if (load = '1') then
        entry_reg_out <= unsigned(data);
      end if;
    end if;

  end process entry_reg_proc;

  full_adder_out <= entry_reg_out + counter_out;

  with selector select mux_out <=
    full_adder_out when '0',
    xilinx_subtractor_out when others;

  internal_reg_proc : process (clk, reset) is
  begin

    if (reset = '1') then
      entry_reg_out <= (others => '0');
    elsif rising_edge(clk) then
      entry_reg_out <= mux_out;
    end if;

  end process internal_reg_proc;

  least_significant_nibble_proc: process (entry_reg_out)
  begin
    
  end process;
  

end architecture structural;
