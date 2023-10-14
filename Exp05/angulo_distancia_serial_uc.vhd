library ieee;
use ieee.std_logic_1164.all;

entity angulo_distancia_serial_uc is
    port(
        clock: in std_logic;
        reset: in std_logic;
        partida: in std_logic;
        pronto: out std_logic;

        --sinais de controle
        partida_serial        : out std_logic;
        zera_contagem_digitos : out std_logic;
        prox_digito           : out std_logic;

        --sinais de condição
        pronto_serial         : in std_logic;
        fim_digitos           : in std_logic;

        --Depuração
        db_estado: out std_logic_vector(3 downto 0)
    );
end entity;

architecture fsm of angulo_distancia_serial_uc is
    type tipo_estado is (inicial, preparacao, envia_serial, espera_serial, conta, final);
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
  process (partida, pronto_serial, fim_digitos, Eatual) 
  begin
    case Eatual is

      when inicial =>      if partida='1' then Eprox <= preparacao;
                           else                Eprox <= inicial;
                           end if;

      when preparacao =>      Eprox <= envia_serial;

      when envia_serial  =>  Eprox <= espera_serial;

      when espera_serial =>  if pronto_serial='0' then Eprox <= espera_serial;
                             else                      Eprox <= conta;
                             end if;

      when conta =>          if fim_digitos='0' then Eprox <= envia_serial;
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
      partida_serial <= '1' when envia_serial, '0' when others;

  with Eatual select
      zera_contagem_digitos <= '1' when preparacao, '0' when others;

  with Eatual select
      prox_digito <= '1' when conta, '0' when others;

  with Eatual select
      db_estado <= "0001" when inicial,
                   "0010" when preparacao,
                   "0101" when envia_serial,   --5
                   "0110" when espera_serial,  --6
                   "1100" when conta, 
                   "1111" when final,    -- Final
                   "1110" when others;   -- Erro

end architecture;
