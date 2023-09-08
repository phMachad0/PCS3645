------------------------------------------------------------------
-- Arquivo   : tx_serial_uc.vhd
-- Projeto   : Experiencia 2 - Comunicacao Serial Assincrona
------------------------------------------------------------------
-- Descricao : unidade de controle do circuito da experiencia 2 
-- > implementa superamostragem (tick)
-- > independente da configuracao de transmissao (7O1, 8N2, etc)
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
--     31/08/2022  2.0     Edson Midorikawa  revisao
--     17/08/2023  3.0     Edson Midorikawa  revisao
------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;

entity rx_serial_uc is 
    port ( 
        clock     : in  std_logic;
        reset     : in  std_logic;
        dado      : in  std_logic;
        tick      : in  std_logic;
        fim       : in  std_logic;
        recebe_dado : in  std_logic;
        carrega   : out std_logic;
        limpa     : out std_logic;
        zera      : out std_logic;
        desloca   : out std_logic;
        conta     : out std_logic;
        registra  : out std_logic;
        pronto    : out std_logic;
        tem_dado  : out std_logic;
        db_estado : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rx_serial_uc_arch of rx_serial_uc is

    type estado_receptor is (inicial, preparacao, espera, recepcao, armazena, final, dado_presente);
    signal Eatual: estado_receptor;  -- estado atual
    signal Eprox:  estado_receptor;  -- proximo estado

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
  process (dado, tick, fim, recebe_dado, Eatual) 
  begin

    case Eatual is

      when inicial =>      if dado='1' then Eprox <= inicial;
                           else             Eprox <= preparacao;
                           end if;

      when preparacao =>   Eprox <= espera;

      when espera =>       if tick='1' then   Eprox <= recepcao;
                           elsif fim='0' then Eprox <= espera;
                           else               Eprox <= armazena;
                           end if;


      when recepcao =>     Eprox <= espera;

      when armazena =>     Eprox <= final;

      when final =>        Eprox <= dado_presente;

      when dado_presente =>  if recebe_dado='0' then Eprox <= dado_presente;
                             else                    Eprox <= inicial;
                             end if;

      when others =>       Eprox <= inicial;

    end case;

  end process;

  -- logica de saida (Moore)
  with Eatual select
      carrega <= '1' when preparacao, '0' when others;

  with Eatual select
      limpa <= '1' when preparacao, '0' when others;

  with Eatual select
      zera <= '1' when preparacao, '0' when others;

  with Eatual select
      desloca <= '1' when recepcao, '0' when others;

  with Eatual select
      conta <= '1' when recepcao, '0' when others;

  with Eatual select
      registra <= '1' when armazena, '0' when others;

  with Eatual select
      pronto <= '1' when final, '0' when others;

  with Eatual select
      tem_dado <= '1' when dado_presente, '0' when others;

  with Eatual select
      db_estado <= "0000" when inicial,
                   "0001" when preparacao, 
                   "0010" when espera, 
                   "0100" when recepcao, 
                   "1000" when armazena, 
                   "1001" when final, 
                   "1010" when dado_presente,    -- Final
                   "1111" when others;   -- Erro

end architecture rx_serial_uc_arch;
