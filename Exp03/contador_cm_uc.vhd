library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_cm_uc is
    port(
        clock      : in std_logic;
        reset      : in std_logic;
        fim        : in std_logic;
        tick       : in std_logic;
        pulso      : in std_logic;
        conta_bcd  : out std_logic;
        zera_bcd   : out std_logic;
        conta_tick : out std_logic;
        zera_tick  : out std_logic;
		  pronto     : out std_logic;
        db_estado  : out std_logic_vector(3 downto 0)
    );
end entity;

architecture asyncronous of contador_cm_uc is
begin
    conta_tick <= pulso and not fim;
    zera_tick <= reset;
    zera_bcd <= reset;
    conta_bcd <= tick;
end architecture;

architecture fsm of contador_cm_uc is
    type tipo_estado is (inicial, preparacao, espera_tick, 
                         conta, final);
    signal Eatual, Eprox: tipo_estado;
begin

    -- estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    process (Eatual, fim, tick, pulso) 
    begin
      case Eatual is
        when inicial =>         if pulso='1' then Eprox <= preparacao;
                                else              Eprox <= inicial;
                                end if;
        when preparacao =>      Eprox <= espera_tick;
        when espera_tick =>     if pulso='0' or fim='1' then Eprox <= final;
                                elsif tick='1'          then Eprox <= conta;
                                else                    Eprox <= espera_tick;
                                end if;
        when conta =>           Eprox <= espera_tick;
        when final =>           Eprox <= inicial;
        when others =>          Eprox <= inicial;
      end case;
    end process;

  -- saidas de controle
  with Eatual select 
      zera_tick <= '1' when preparacao, '0' when others;
  with Eatual select 
      zera_bcd <= '1' when preparacao, '0' when others;

  with Eatual select 
      conta_tick <= '1' when espera_tick | conta, '0' when others;
  with Eatual select 
      conta_bcd <= '1' when conta, '0' when others;
  with Eatual select 
      pronto <= '1' when final, '0' when others;

  with Eatual select
      db_estado <= "0001" when inicial, 
                   "0010" when preparacao, 
                   "1110" when espera_tick, 
                   "1100" when conta,
                   "1111" when final, 
                   "0000" when others;

end architecture;
