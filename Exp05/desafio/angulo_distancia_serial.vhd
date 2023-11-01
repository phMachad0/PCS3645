library ieee;
use ieee.std_logic_1164.all;

entity angulo_distancia_serial is
  port
  (
    clock   : in std_logic;
    reset   : in std_logic;
    partida : in std_logic;
    angulo_ascii : in std_logic_vector (23 downto 0);
    medida       : in std_logic_vector (11 downto 0);

    saida_serial : out std_logic;
    pronto       : out std_logic;

    --depuracao
    db_estado : out std_logic_vector(3 downto 0)
  );
end entity;

architecture structure of angulo_distancia_serial is
  component angulo_distancia_serial_fd is
    port
    (
        clock        : in std_logic;
        reset        : in std_logic;
        angulo_ascii : in std_logic_vector (23 downto 0);
        medida       : in std_logic_vector (11 downto 0);
        saida_serial : out std_logic;
    
        --entradas de controle
        partida_serial        : in std_logic;
        zera_contagem_digitos : in std_logic;
        prox_digito           : in std_logic;
    
        --saidas de condição
        pronto_serial         : out std_logic;
        fim_digitos           : out std_logic
    );
  end component;

  component angulo_distancia_serial_uc is
    port
    (
      clock   : in std_logic;
      reset   : in std_logic;
      partida : in std_logic;
      pronto  : out std_logic;

      --sinais de controle
      partida_serial        : out std_logic;
      zera_contagem_digitos : out std_logic;
      prox_digito           : out std_logic;

      --sinais de condição
      pronto_serial : in std_logic;
      fim_digitos   : in std_logic;

      --Depuração
      db_estado : out std_logic_vector(3 downto 0)
    );
  end component;

  signal s_partida_serial, s_zera_contagem_digitos, s_prox_digito: std_logic;
  signal s_pronto_serial, s_fim_digitos: std_logic;
begin
    FD: angulo_distancia_serial_fd port map (
      clock        => clock,
      reset        => reset,
      angulo_ascii => angulo_ascii,
      medida       => medida,
      saida_serial => saida_serial,

      --entradas de controle
      partida_serial        => s_partida_serial,
      zera_contagem_digitos => s_zera_contagem_digitos,
      prox_digito           => s_prox_digito,

      --saidas de condição
      pronto_serial => s_pronto_serial,
      fim_digitos   => s_fim_digitos
    );

    UC: angulo_distancia_serial_uc port map (
      clock   => clock,
      reset   => reset,
      partida => partida,
      pronto  => pronto,

      --sinais de controle
      partida_serial        => s_partida_serial,
      zera_contagem_digitos => s_zera_contagem_digitos,
      prox_digito           => s_prox_digito,

      --sinais de condição
      pronto_serial => s_pronto_serial,
      fim_digitos   => s_fim_digitos,

      --Depuração
      db_estado => db_estado
    );

end architecture;