library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity right_shift_register_4_bits is
  port (
    clk   : in    std_logic;
    reset : in    std_logic;
    load  : in    std_logic;
    d     : in    std_logic_vector(3 downto 0);

    q : out   std_logic_vector(3 downto 0)
  );
end entity right_shift_register_4_bits;

architecture rtl of right_shift_register_4_bits is

begin

  shift_proc : process (clk, reset) is
  begin

    if (reset = '1') then
      q <= (others => '0');
    elsif rising_edge(clk) then
      if (load = '1') then
        q <= d;
      else
        q <= '0' & q(3 downto 1);
      end if;
    end if;

  end process shift_proc;

end architecture rtl;
