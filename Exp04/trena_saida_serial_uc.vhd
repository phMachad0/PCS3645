library ieee;
use ieee.std_logic_1164.all;

entity trena_saida_serial_uc is
    port(
        --Entradas
        clock: in std_logic;
        reset: in std_logic;
        mensurar: in std_logic;

        --Entradas de controle
        pronto_sensor  : in std_logic;
        pronto_serial  : in std_logic;
        fim_contador   : in std_logic;

        --Saídas
        pronto: out std_logic;

        --Saídas de controle
        medir_sensor : out std_logic;
        partida_serial : out std_logic;
        zera_contador: out std_logic;
        aumenta_contador: out std_logic;

        --Depuração
        db_estado: out std_logic_vector(3 downto 0)
    );
end entity;

architecture fsm of trena_saida_serial_uc is
    type tipo_estado is (inicial, preparacao, inicia_medicao, espera_medicao, envia_serial, espera_serial, conta, final);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin

  -- memoria de estado
  process (reset, clock)
  begin
      if reset = '1' then
          Eatual <= inicial;
      elsif clock'event and clock = '1' then
          Eatual <= Eprox; 
      end if;
  end process;

  -- logica de proximo estado
  process (mensurar, pronto_sensor, pronto_serial, fim_contador, Eatual) 
  begin
    case Eatual is

      when inicial =>      if mensurar='1' then Eprox <= preparacao;
                           else                Eprox <= inicial;
                           end if;

      when preparacao =>      Eprox <= inicia_medicao;

      when inicia_medicao =>  Eprox <= espera_medicao;

      when espera_medicao =>  if pronto_sensor='0' then Eprox <= espera_medicao;
                              else                      Eprox <= envia_serial;
                              end if;

      when envia_serial  =>  Eprox <= espera_serial;

      when espera_serial =>  if pronto_serial='0' then Eprox <= espera_serial;
                             else                      Eprox <= conta;
                             end if;

      when conta =>          if fim_contador='0' then Eprox <= envia_serial;
                             else                     Eprox <= final;
                             end if;

      when final =>      Eprox <= inicial;

      when others =>   Eprox <= inicial;

    end case;

  end process;

  -- logica de saida (Moore)
  with Eatual select
      pronto <= '1' when final, '0' when others;

  with Eatual select
      medir_sensor <= '1' when inicia_medicao, '0' when others;

  with Eatual select
      partida_serial <= '1' when envia_serial, '0' when others;

  with Eatual select
      zera_contador <= '1' when preparacao, '0' when others;

  with Eatual select
      aumenta_contador <= '1' when conta, '0' when others;

  with Eatual select
      db_estado <= "0001" when inicial,
                   "0010" when preparacao, 
                   "1010" when inicia_medicao, --A
                   "1011" when espera_medicao, --B
                   "0101" when envia_serial,   --5
                   "0110" when espera_serial,  --6
                   "1100" when conta, 
                   "1111" when final,    -- Final
                   "1110" when others;   -- Erro

end architecture;
