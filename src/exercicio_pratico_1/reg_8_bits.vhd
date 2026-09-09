library ieee;
  use ieee.std_logic_1164.all;

entity reg_8_bits is
  port (
    clk   : in    std_logic;
    reset : in    std_logic;
    load  : in    std_logic;
    data  : in    std_logic_vector(7 downto 0);
    value : out   std_logic_vector(7 downto 0)
  );
end entity reg_8_bits;

architecture behavioral of reg_8_bits is

begin

  reg_proc : process (clk, reset) is
  begin

    if (reset = '1') then
      value <= (others => '0');
    elsif rising_edge(clk) then
      if (load = '1') then
        value <= data;
      end if;
    end if;

  end process reg_proc;

end architecture behavioral;
