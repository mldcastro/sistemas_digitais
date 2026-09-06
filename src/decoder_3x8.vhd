library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity decoder_3x8 is
  port (
    input  : in    std_logic_vector(2 downto 0);
    output : out   std_logic_vector(7 downto 0)
  );
end entity decoder_3x8;

architecture behavioral of decoder_3x8 is

begin

  with TO_INTEGER(unsigned(input)) select output <=
    "00000001" when 0,
    "00000010" when 1,
    "00000100" when 2,
    "00001000" when 3,
    "00010000" when 4,
    "00100000" when 5,
    "01000000" when 6,
    "10000000" when others;

end architecture behavioral;
