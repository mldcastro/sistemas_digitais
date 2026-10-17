library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity neander is
  port (
    clk   : in    std_logic;
    reset : in    std_logic
  );
end entity neander;

architecture rtl of neander is

  component memory is
    port (
      clka  : in    std_logic;
      wea   : in    std_logic_vector(0 downto 0);
      addra : in    std_logic_vector(7 downto 0);
      dina  : in    std_logic_vector(7 downto 0);
      douta : out   std_logic_vector(7 downto 0)
    );
  end component memory;

  -- Sinais de controle
  signal should_write    : std_logic_vector(0 downto 0);
  signal should_read     : std_logic;
  signal pc_or_rdm_sel   : std_logic;
  signal inc_pc          : std_logic;
  signal alu_sel         : std_logic_vector(2 downto 0);
  signal charge_rdm      : std_logic;
  signal charge_rem      : std_logic;
  signal charge_ri       : std_logic;
  signal charge_pc       : std_logic;
  signal charge_ac       : std_logic;
  signal charge_nz_flags : std_logic;

  -- Saídas
  signal alu_out : std_logic_vector(7 downto 0);
  signal ac_out  : std_logic_vector(7 downto 0);
  signal rdm_out : std_logic_vector(7 downto 0);
  signal rem_out : std_logic_vector(7 downto 0);
  signal pc_out  : std_logic_vector(7 downto 0);
  signal n       : std_logic;
  signal z       : std_logic;

  -- FSM

  type t_stage is (t0, t1, t2, t3, t4, t5, t6, t7, halt_state);

  type t_op is (op_sta, op_lda, op_add, op_sub, op_or, op_xor, op_and, op_not, op_jmp, op_jn, op_jz, op_nop, op_hlt);

  signal stage : t_stage;
  signal op    : t_op;

begin

  memory_inst : component memory
    port map (
      clka  => clk,
      wea   => should_write,
      addra => rem_out,
      dina  => rdm_out,
      douta => rdm_out
    );

  ------------------------------------------
  -- FSM
  ------------------------------------------
  stage_proc : process (reset, clk) is
  begin

    if (reset = '1') then
      stage           <= t0;
      pc_or_rdm_sel   <= '0';
      charge_rem      <= '0';
      should_read     <= '0';
      inc_pc          <= '0';
      charge_ri       <= '0';
      charge_ac       <= '0';
      charge_nz_flags <= '0';
      charge_pc       <= '0';
      charge_rdm      <= '0';
      should_write    <= "0";
    elsif rising_edge(clk) then
      should_write    <= "0";
      should_read     <= '0';
      inc_pc          <= '0';
      pc_or_rdm_sel   <= '0';
      charge_ri       <= '0';
      charge_ac       <= '0';
      charge_nz_flags <= '0';
      charge_pc       <= '0';
      charge_rdm      <= '0';
      charge_rem      <= '0';

      case stage is

        when t0 =>

          pc_or_rdm_sel <= '0';
          charge_rem    <= '1';
          stage         <= t1;

        when t1 =>

          should_read <= '1';
          inc_pc      <= '1';
          stage       <= t2;

        when t2 =>

          charge_ri <= '1';
          stage     <= t3;

        when t3 =>

          if (
              (op = op_sta)
              or (op = op_lda)
              or (op = op_add)
              or (op = op_sub)
              or (op = op_or)
              or (op = op_xor)
              or (op = op_and)
              or (op = op_jmp)
              or ((op = op_jn) and (n = '1'))
              or ((op = op_jz) and (z = '1'))
            ) then
            pc_or_rdm_sel <= '0';
            charge_rem    <= '1';
            stage         <= t4;
          elsif (op = op_not) then
            charge_ac       <= '1';
            charge_nz_flags <= '1';
            stage           <= t0;
          elsif (((op = op_jn) and (n = '0')) or ((op = op_jz) and (z = '0'))) then
            inc_pc <= '1';
            stage  <= t0;
          elsif (op = op_nop) then
            stage <= t0;
          elsif (op = op_hlt) then
            stage <= halt_state;
          end if;

        when t4 =>

          if (
              (op = op_sta)
              or (op = op_lda)
              or (op = op_add)
              or (op = op_sub)
              or (op = op_or)
              or (op = op_xor)
              or (op = op_and)
            ) then
            should_read <= '1';
            inc_pc      <= '1';
            stage       <= t5;
          elsif ((op = op_jmp) or (op = op_jn) or (op = op_jz)) then
            should_read <= '1';
            stage       <= t5;
          end if;

        when t5 =>

          if (
              (op = op_sta)
              or (op = op_lda)
              or (op = op_add)
              or (op = op_sub)
              or (op = op_or)
              or (op = op_xor)
              or (op = op_and)
            ) then
            pc_or_rdm_sel <= '1';
            charge_rem    <= '1';
            stage         <= t6;
          elsif ((op = op_jmp) or (op = op_jn) or (op = op_jz)) then
            charge_pc <= '1';
            stage     <= t0;
          end if;

        when t6 =>

          if (op = op_sta) then
            charge_rdm <= '1';
            stage      <= t7;
          elsif (
                 (op = op_lda)
                 or (op = op_add)
                 or (op = op_sub)
                 or (op = op_or)
                 or (op = op_xor)
                 or (op = op_and)
               ) then
            should_read <= '1';
            stage       <= t7;
          end if;

        when t7 =>

          if (op = op_sta) then
            should_write <= "1";
            stage        <= t0;
          elsif (
                 (op = op_lda)
                 or (op = op_add)
                 or (op = op_sub)
                 or (op = op_or)
                 or (op = op_xor)
                 or (op = op_and)
               ) then
            charge_ac       <= '1';
            charge_nz_flags <= '1';
            stage           <= t0;
          end if;

        when halt_state =>

          stage <= halt_state;

        when others =>

          null;

      end case;

    end if;

  end process stage_proc;

  ------------------------------------------
  -- RDM
  ------------------------------------------

  rdm_proc : process (reset, clk) is
  begin

    if (reset = '1') then
      rdm_out <= (others => '0');
    elsif rising_edge(clk) then
      if (charge_rdm = '1') then
        rdm_out <= ac_out;
      end if;
    end if;

  end process rdm_proc;

  ------------------------------------------
  -- REM
  ------------------------------------------

  rem_proc : process (reset, clk) is
  begin

    if (reset = '1') then
      rem_out <= (others => '0');
    elsif rising_edge(clk) then
      if (charge_rem = '1') then
        if (pc_or_rdm_sel = '0') then
          rem_out <= pc_out;
        else
          rem_out <= rdm_out;
        end if;
      end if;
    end if;

  end process rem_proc;

  ------------------------------------------
  -- PC
  ------------------------------------------

  pc_proc : process (reset, clk) is
  begin

    if (reset = '1') then
      pc_out <= (others => '0');
    elsif rising_edge(clk) then
      if (charge_pc = '1') then
        pc_out <= rdm_out;
      elsif (inc_pc = '1') then
        pc_out <= std_logic_vector(unsigned(pc_out) + 1);
      end if;
    end if;

  end process pc_proc;

  ------------------------------------------
  -- AC
  ------------------------------------------

  ac_proc : process (reset, clk) is
  begin

    if (reset = '1') then
      ac_out <= (others => '0');
    elsif rising_edge(clk) then
      if (charge_ac = '1') then
        ac_out <= alu_out;
      end if;
    end if;

  end process ac_proc;

  ------------------------------------------
  -- RI
  ------------------------------------------

  ri_proc : process (reset, clk) is
  begin

    if (reset = '1') then
      op <= op_nop;
    elsif rising_edge(clk) then
      if (charge_ri = '1') then

        case rdm_out(7 downto 4) is

          when "0000" =>

            op <= op_nop;

          when "0001" =>

            op <= op_sta;

          when "0010" =>

            op      <= op_lda;
            alu_sel <= "000";

          when "0011" =>

            op      <= op_add;
            alu_sel <= "001";

          when "0100" =>

            op      <= op_or;
            alu_sel <= "010";

          when "0101" =>

            op      <= op_and;
            alu_sel <= "011";

          when "0110" =>

            op      <= op_not;
            alu_sel <= "100";

          when "0111" =>

            op      <= op_sub;
            alu_sel <= "101";

          when "1011" =>

            op      <= op_xor;
            alu_sel <= "110";

          when "1000" =>

            op <= op_jmp;

          when "1001" =>

            op <= op_jn;

          when "1010" =>

            op <= op_jz;

          when "1111" =>

            op <= op_hlt;

          when others =>

            null;

        end case;

      end if;
    end if;

  end process ri_proc;

  ------------------------------------------
  -- ALU
  ------------------------------------------

  with alu_sel select alu_out <=
    std_logic_vector(unsigned(ac_out) + unsigned(rdm_out)) when "001",
    ac_out or rdm_out when "010",
    ac_out and rdm_out when "011",
    not ac_out when "100",
    std_logic_vector(unsigned(ac_out) - unsigned(rdm_out)) when "101",
    ac_out xor rdm_out when "110",
    rdm_out when others;

  ------------------------------------------
  -- NZ FLAGS
  ------------------------------------------

  nz_proc : process (reset, clk) is
  begin

    if (reset = '1') then
      n <= '0';
      z <= '1';
    elsif rising_edge(clk) then
      if (charge_nz_flags = '1') then
        n <= alu_out(7);
        if (alu_out = "00000000") then
          z <= '1';
        else
          z <= '0';
        end if;
      end if;
    end if;

  end process nz_proc;

end architecture rtl;
