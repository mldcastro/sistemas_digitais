----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    12:37:41 10/08/2026
-- Design Name:
-- Module Name:    counter - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity counter_99 is
  generic (
    ticks_deb        : integer := 500000; -- ciclos entre leituras dos botões (10 ms)
    change_seg_ticks : integer := 50000
  );
  port (
    clk : in    std_logic;                    -- clock da placa (50 MHz)
    btn : in    std_logic_vector(2 downto 0); -- botões BTN0..BTN2 (pressionado = 1)
    seg : out   std_logic_vector(6 downto 0); -- segmentos: seg(0)=A ... seg(6)=G (0 acende)
    dp  : out   std_logic;                    -- ponto decimal (0 acende)
    an  : out   std_logic_vector(3 downto 0)  -- anodos dos 4 dígitos (0 liga o dígito)
  );
end entity counter_99;

architecture rtl of counter_99 is

  signal deb_cnt        : unsigned(19 downto 0) := (others => '0');
  signal change_seg_cnt : unsigned(19 downto 0) := (others => '0');

  signal btn_now : std_logic_vector(2 downto 0) := "000"; -- foto atual
  signal btn_old : std_logic_vector(2 downto 0) := "000"; -- foto de 10 ms atrás

  signal tick_deb       : std_logic;
  signal change_seg     : std_logic;
  signal change_seg_sel : std_logic;

  signal press : std_logic_vector(2 downto 0);

  signal number : unsigned(3 downto 0) := "0000";
  signal unit   : unsigned(3 downto 0) := "0000";
  signal tenth  : unsigned(3 downto 0) := "0000";

begin

  -----------------------------------------------------------------
  -- 1) Debounce
  -- A cada 10 ms o circuito "tira uma foto" dos botões e guarda
  -- a foto anterior. Apertou = está em 1 na foto nova e em 0 na
  -- antiga. "press" vale 1 por UM ciclo de clock em cada aperto.
  -----------------------------------------------------------------
  tick_deb   <= '1' when deb_cnt = ticks_deb - 1 else
                '0';
  change_seg <= '1' when change_seg_cnt = change_seg_ticks - 1 else
                '0';

  counter_proc : process (clk) is
  begin

    if rising_edge(clk) then
      if (tick_deb = '1') then
        deb_cnt <= (others => '0');
        btn_now <= btn;
        btn_old <= btn_now;
      elsif (change_seg = '1') then
        change_seg_cnt <= (others => '0');
        change_seg_sel <= not change_seg_sel;
      else
        deb_cnt        <= deb_cnt + 1;
        change_seg_cnt <= change_seg_cnt + 1;
      end if;
    end if;

  end process counter_proc;

  press(0) <= tick_deb and btn_now(0) and not btn_old(0); -- BTN0
  press(1) <= tick_deb and btn_now(1) and not btn_old(1); -- BTN1
  press(2) <= tick_deb and btn_now(2) and not btn_old(2); -- BTN2

  -----------------------------------------------------------------
  -- 2) O contador (0 a 9)
  -----------------------------------------------------------------
  value_proc : process (clk) is
  begin

    if rising_edge(clk) then
      if (press(0) = '1') then                              -- BTN0: zera
        unit  <= "0000";
        tenth <= "0000";
      elsif (press(1) = '1') then                           -- BTN1: +1
        if (unit = 9) then
          unit <= "0000";

          if (tenth = 9) then
            tenth <= "0000";
          else
            tenth <= tenth + 1;
          end if;
        else
          unit <= unit + 1;
        end if;
      elsif (press(2) = '1') then                           -- BTN2: -1
        if (unit = 0) then
          unit <= "1001";

          if (tenth = 0) then
            tenth <= "1001";
          else
            tenth <= tenth - 1;
          end if;
        else
          unit <= unit - 1;
        end if;
      end if;
    end if;

  end process value_proc;

  -----------------------------------------------------------------
  -- 3) Decodificador de 7 segmentos (0 acende o segmento)

  number <= tenth when change_seg_sel = '1' else
            unit;
  an     <= "1101" when change_seg_sel = '1' else
            "1110";
  dp     <= '1'; -- ponto decimal apagado

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

      when others =>

        seg <= "1111111"; -- apagado

    end case;

  end process segment_proc;

end architecture rtl;
