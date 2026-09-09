library ieee;
  use ieee.std_logic_1164.all;

entity top_level_system is
  port (
    clk   : in    std_logic;
    reset : in    std_logic;

    -- Counter inputs
    count_down : in    std_logic;

    -- Mux inputs
    ext_data     : in    std_logic_vector(7 downto 0);
    use_ext_data : in    std_logic;

    -- Register inputs
    load_reg : in    std_logic;

    -- System output (from Decoder)
    decoded_out : out   std_logic_vector(7 downto 0)
  );
end entity top_level_system;

architecture structural of top_level_system is

  -- Internal Wires (Signals)
  -- These act as cables connecting the output of one block to the input of another.
  signal wire_counter_out : std_logic_vector(7 downto 0);
  signal wire_mux_out     : std_logic_vector(7 downto 0);
  signal wire_reg_out     : std_logic_vector(7 downto 0);

begin

  -- 1. Instantiate the Counter
  inst_counter : entity work.counter_8_bits
    port map (
      clk     => clk,
      reset   => reset,
      down    => count_down,
      counter => wire_counter_out
    );

  -- 2. Instantiate the Multiplexer
  inst_mux : entity work.mux_2x1_8_bits
    port map (
      a        => wire_counter_out,
      b        => ext_data,
      selector => use_ext_data,
      y        => wire_mux_out
    );

  -- 3. Instantiate the Register
  inst_reg : entity work.reg_8_bits
    port map (
      clk   => clk,
      reset => reset,
      load  => load_reg,
      data  => wire_mux_out,
      value => wire_reg_out
    );

end architecture structural;
