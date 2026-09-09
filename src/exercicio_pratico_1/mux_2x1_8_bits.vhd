library ieee;
  use ieee.std_logic_1164.all;

entity mux_2x1_8_bits is
  port (
    a        : in    std_logic_vector(7 downto 0);
    b        : in    std_logic_vector(7 downto 0);
    selector : in    std_logic;
    y        : out   std_logic_vector(7 downto 0)
  );
end entity mux_2x1_8_bits;

architecture behavioral of mux_2x1_8_bits is

begin

  with selector select y <=
    a when '0',
    b when others;

end architecture behavioral;
