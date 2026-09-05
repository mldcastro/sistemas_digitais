library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_8x1 is
  port (
    input    : in std_logic_vector(7 downto 0);
    selector : in std_logic_vector(2 downto 0);
    y        : out std_logic
  );
end entity mux_8x1;

architecture Behavioral of mux_8x1 is

begin
  y <= input(to_integer(unsigned(selector)));
end architecture Behavioral;
