library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo_3 is
  port
  (
    clock      : in std_logic;
    reset      : in std_logic;
    posicao    : in std_logic_vector(2 downto 0);
    pwm        : out std_logic;
    db_reset   : out std_logic;
    db_pwm     : out std_logic;
    db_posicao : out std_logic_vector(2 downto 0)
  );
end entity controle_servo_3;

architecture beh of controle_servo_3 is

  component circuito_pwm is
    generic
    (
      conf_periodo : integer := 1250; -- periodo do sinal pwm [1250 => f=4KHz (25us)]
      largura_000  : integer := 0; -- largura do pulso p/ 00 [0 => 0]
      largura_001  : integer := 50; -- largura do pulso p/ 01 [50 => 1us]
      largura_010  : integer := 500; -- largura do pulso p/ 10 [500 => 10us]
      largura_011  : integer := 1000; -- largura do pulso p/ 11 [1000 => 20us]
      largura_100  : integer := 0; -- largura do pulso p/ 00 [0 => 0]
      largura_101  : integer := 50; -- largura do pulso p/ 01 [50 => 1us]
      largura_110  : integer := 500; -- largura do pulso p/ 10 [500 => 10us]
      largura_111  : integer := 1000 -- largura do pulso p/ 11 [1000 => 20us]
    );
    port
    (
      clock   : in std_logic;
      reset   : in std_logic;
      largura : in std_logic_vector(2 downto 0);
      pwm     : out std_logic
    );
  end component;
  signal s_pwm : std_logic;
begin

  servo_pwm : circuito_pwm
  generic map
  (
    conf_periodo => 1000000,
    largura_000  => 35000, --20 graus
    largura_001  => 45700, --40 graus
    largura_010  => 56450, --60 graus
    largura_011  => 67150, --80 graus
    largura_100  => 77850, --100 graus
    largura_101  => 88550, --120 graus
    largura_110  => 99300, --140 graus
    largura_111  => 110000 --160 graus
  )
  port map
  (
    clock   => clock,
    reset   => reset,
    largura => posicao,
    pwm     => s_pwm
  );
  pwm <= s_pwm;
  db_posicao <= posicao;
  db_pwm <= s_pwm;
  db_reset <= reset;

end architecture;