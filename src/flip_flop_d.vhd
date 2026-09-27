library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity flip_flop_d is
  port (
    clk   : in    std_logic;
    reset : in    std_logic;
    d     : in    std_logic;

    q : out   std_logic
  );
end entity flip_flop_d;

architecture rtl of flip_flop_d is

begin

  flip_flop_proc : process (clk, reset) is
  begin

    if (reset = '1') then
      q <= '0';
    elsif rising_edge(clk) then
      q <= d;
    end if;

  end process flip_flop_proc;

end architecture rtl;
