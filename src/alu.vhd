library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity alu is
  generic (
    debounce_ticks       : integer := 500000; -- ciclos entre leituras dos botões (10 ms)
    change_display_ticks : integer := 50000   -- 1 ms
  );
  port (
    clk      : in    std_logic;                    -- clock da placa (50 MHz)
    button   : in    std_logic_vector(2 downto 0); -- botões BTN0..BTN2 (pressionado = 1)
    switches : in    std_logic_vector(2 downto 0);
    seg      : out   std_logic_vector(6 downto 0); -- segmentos: seg(0)=A ... seg(6)=G (0 acende)
    dp       : out   std_logic;                    -- ponto decimal (0 acende)
    an       : out   std_logic_vector(3 downto 0)  -- anodos dos 4 dígitos (0 liga o dígito)
  );
end entity alu;

architecture rtl of alu is

  signal debounce_tick_count       : unsigned(19 downto 0) := (others => '0');
  signal change_display_tick_count : unsigned(19 downto 0) := (others => '0');

  signal button_now : std_logic_vector(2 downto 0) := "000"; -- foto atual
  signal button_old : std_logic_vector(2 downto 0) := "000"; -- foto de 10 ms atrás

  signal debounce_tick       : std_logic;
  signal change_display_tick : std_logic;
  signal display_selector    : unsigned(1 downto 0) := "00";

  signal press : std_logic_vector(2 downto 0);

  signal number      : unsigned(3 downto 0) := "0000";
  signal unit        : unsigned(3 downto 0) := "0000";
  signal ten         : unsigned(3 downto 0) := "0000";
  signal a           : unsigned(3 downto 0) := "0000";
  signal b           : unsigned(3 downto 0) := "0000";
  signal ab_selector : std_logic;

begin

  -----------------------------------------------------------------
  -- Contador de ticks para evitar debounce
  -- A cada 10 ms o circuito "tira uma foto" dos botões e guarda
  -- a foto anterior. Apertou = está em 1 na foto nova e em 0 na
  -- antiga. "press" vale 1 por UM ciclo de clock em cada aperto.
  -----------------------------------------------------------------
  debounce_tick       <= '1' when debounce_tick_count = debounce_ticks - 1 else
                         '0';
  change_display_tick <= '1' when change_display_tick_count = change_display_ticks - 1 else
                         '0';

  tick_counter_proc : process (clk) is
  begin

    if rising_edge(clk) then
      if (debounce_tick = '1') then
        debounce_tick_count <= (others => '0');
        button_now          <= button;
        button_old          <= button_now;
      elsif (change_display_tick = '1') then
        change_display_tick_count <= (others => '0');
        display_selector          <= display_selector + 1;
      else
        debounce_tick_count       <= debounce_tick_count + 1;
        change_display_tick_count <= change_display_tick_count + 1;
      end if;
    end if;

  end process tick_counter_proc;

  press(0) <= debounce_tick and button_now(0) and not button_old(0); -- BTN0
  press(1) <= debounce_tick and button_now(1) and not button_old(1); -- BTN1
  press(2) <= debounce_tick and button_now(2) and not button_old(2); -- BTN2

  -----------------------------------------------------------------
  -- Editor de A e B
  -----------------------------------------------------------------
  ab_editor_proc : process (clk) is

    variable value          : unsigned(3 downto 0);
    variable value_selector : std_logic;

  begin

    if rising_edge(clk) then
      if (press(2) = '1') then
        value_selector := not ab_selector;
        ab_selector    <= not ab_selector; -- Update signal for next cycle
      else
        value_selector := ab_selector;
      end if;

      if (value_selector = '0') then
        value := a;
      else
        value := b;
      end if;

      if (press(0) = '1') then
        if (value = 9) then
          value := "0000";
        else
          value := value + 1;
        end if;
      elsif (press(1) = '1') then
        if (value = 0) then
          value := "1001";
        else
          value := value - 1;
        end if;
      end if;

      if (value_selector = '0') then
        a <= value;
      else
        b <= value;
      end if;
    end if;

  end process ab_editor_proc;

  -----------------------------------------------------------------
  -- Seletor de operação
  -----------------------------------------------------------------

  op_selector_proc : process (clk) is

    variable result : integer;

  begin

    if rising_edge(clk) then

      case switches is

        when "000" =>

          result := to_integer(a) + to_integer(b);

        when "001" =>

          result := to_integer(a) - to_integer(b);

        when "010" =>

          result := to_integer(a and b);

        when "011" =>

          result := to_integer(a or b);

        when "100" =>

          result := to_integer(a xor b);

        when others =>

          result := 0;

      end case;

      if (result >= 10) then
        ten  <= "0001";
        unit <= to_unsigned(result - 10, 4);
      elsif (result >= 0) then
        ten  <= "0000";
        unit <= to_unsigned(result, 4);
      else
        ten  <= "1111";  -- Sinalizar número negativo
        unit <= to_unsigned(result, 4);
      end if;
    end if;

  end process op_selector_proc;

  -----------------------------------------------------------------
  -- Decodificador de 7 segmentos (0 acende o segmento)
  -----------------------------------------------------------------

  with to_integer(display_selector) select number <=
    unit when 0,
    ten when 1,
    b when 2,
    a when 3,
    number when others;

  with to_integer(display_selector) select an <=
    "1110" when 0,
    "1101" when 1,
    "1011" when 2,
    "0111" when 3,
    "1110" when others;

  dp <= '0' when (display_selector = "0111" and ab_selector = '0') or
                 (display_selector = "1011" and ab_selector = '1') else
        '1';

  segment_proc : process (number) is
  begin

    case to_integer(number) is

      when 0 =>

        seg <= "1000000";

      when 1 =>

        seg <= "1111001";

      when 2 =>

        seg <= "0100100";

      when 3 =>

        seg <= "0110000";

      when 4 =>

        seg <= "0011001";

      when 5 =>

        seg <= "0010010";

      when 6 =>

        seg <= "0000010";

      when 7 =>

        seg <= "1111000";

      when 8 =>

        seg <= "0000000";

      when 9 =>

        seg <= "0010000";

      when 15 =>

        seg <= "0111111";      -- Sinal de menos

      when others =>

        seg <= "1111111";      -- apagado

    end case;

  end process segment_proc;

end architecture rtl;
