library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity counter_8_bits is
  port (
    clk     : in    std_logic;
    reset   : in    std_logic;
    down    : in    std_logic;
    counter : out   std_logic_vector(7 downto 0)
  );
end entity counter_8_bits;

architecture behavioral of counter_8_bits is

  signal counter_unsigned : unsigned(7 downto 0);

begin

  counter_proc : process (clk, reset) is
  begin

    if (reset = '1') then
      counter_unsigned <= (others => '0');
    elsif rising_edge(clk) then
      if (down = '0') then
        counter_unsigned <= counter_unsigned + 1;
      else
        counter_unsigned <= counter_unsigned - 1;
      end if;
    end if;

  end process counter_proc;

  counter <= std_logic_vector(counter_unsigned);

end architecture behavioral;
