library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity comparator_2_bits is
  port (
    a : in    std_logic_vector(1 downto 0);
    b : in    std_logic_vector(1 downto 0);

    a_greater_b : out   std_logic;
    a_equals_b  : out   std_logic;
    a_smaller_b : out   std_logic
  );
end entity comparator_2_bits;

architecture behavioral of comparator_2_bits is

begin

  a_greater_b <= '1' when a > b else
                 '0';
  a_equals_b  <= '1' when a = b else
                 '0';
  a_smaller_b <= '1' when a < b else
                 '0';

end architecture behavioral;
