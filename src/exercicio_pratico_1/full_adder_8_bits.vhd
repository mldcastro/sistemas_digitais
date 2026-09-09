library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity full_adder_8_bits is
  port (
    a         : in    std_logic_vector(7 downto 0);
    b         : in    std_logic_vector(7 downto 0);
    carry_in  : in    std_logic;
    sum       : out   std_logic_vector(7 downto 0);
    carry_out : out   std_logic
  );
end entity full_adder_8_bits;

architecture behavioral of full_adder_8_bits is

  signal sum_extended : unsigned(8 downto 0);

begin

  sum_extended <= unsigned("0" & a) + unsigned("0" & b) + carry_in;
  sum          <= std_logic_vector(sum_extended(7 downto 0));
  carry_out    <= sum_extended(8);

end architecture behavioral;
