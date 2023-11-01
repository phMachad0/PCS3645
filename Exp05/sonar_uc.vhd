library ieee;
use ieee.std_logic_1164.all;

entity sonar_uc is
    port(
        --Entradas
        clock: in std_logic;
        reset: in std_logic;
        ligar: in std_logic;

        --Saídas
        fim_posicao : out std_logic;

        --sinais de controle
        partida_sensor : out std_logic;
        partida_serial : out std_logic;
        zera_contagem_angulos : out std_logic;
        prox_angulo : out std_logic;
        zera_timer : out std_logic;

        --sinais de condicao
        pronto_sensor : in std_logic;
        pronto_serial : in std_logic;
        fim_angulos : in std_logic;
        timeout: in std_logic;

        --Depuração
        db_estado: out std_logic_vector(3 downto 0)
    );
end entity;

architecture fsm of sonar_uc is
    type tipo_estado is (inicial, preparacao, inicia_timeout, espera_timeout, inicia_medicao, espera_medicao, envia_serial, espera_serial, proxima_posicao);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin

  -- memoria de estado
  process (reset, clock, ligar)
  begin
      if reset = '1' or ligar='0' then
          Eatual <= inicial;
      elsif clock'event and clock = '1' then
          Eatual <= Eprox; 
      end if;
  end process;

  -- logica de proximo estado
  process (pronto_sensor, pronto_serial, timeout, Eatual) 
  begin
    case Eatual is

      when inicial =>      Eprox <= preparacao;

      when preparacao =>      Eprox <= inicia_timeout;

      when inicia_timeout =>      Eprox <= espera_timeout;

      when espera_timeout =>     if timeout='1' then Eprox <= inicia_medicao;
                                 else                Eprox <= espera_timeout;
                                 end if;

      when inicia_medicao =>  Eprox <= espera_medicao;

      when espera_medicao =>  if pronto_sensor='1' then Eprox <= envia_serial;
                              else                      Eprox <= espera_medicao;
                              end if;

      when envia_serial  =>  Eprox <= espera_serial;

      when espera_serial =>  if pronto_serial='1' then Eprox <= proxima_posicao;
                             else                      Eprox <= espera_serial;
                             end if;

      when proxima_posicao =>  Eprox <= inicia_timeout;

      when others =>           Eprox <= inicial;

    end case;

  end process;

  -- logica de saida (Moore)
  with Eatual select
      fim_posicao <= '1' when proxima_posicao, '0' when others;

  with Eatual select
      partida_sensor <= '1' when inicia_medicao, '0' when others;

  with Eatual select
      partida_serial <= '1' when envia_serial, '0' when others;

  with Eatual select
      zera_contagem_angulos <= '1' when preparacao, '0' when others;

  with Eatual select
      prox_angulo <= '1' when proxima_posicao, '0' when others;

  with Eatual select
      zera_timer <= '1' when inicia_timeout, '0' when others;

  with Eatual select
      db_estado <= x"1" when inicial,
                   x"2" when preparacao, 
                   x"3" when inicia_timeout, 
                   x"4" when espera_timeout, 
                   x"5" when inicia_medicao,
                   x"6" when espera_medicao,
                   x"7" when envia_serial,
                   x"8" when espera_serial,
                   x"9" when proxima_posicao, 
                   x"f" when others;   -- Erro

end architecture;
