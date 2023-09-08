library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo is
 port (
 clock : in std_logic;
 reset : in std_logic;
 posicao : in std_logic_vector(1 downto 0);
 controle : out std_logic
 );
end entity controle_servo;

architecture beh of controle_servo is

component circuito_pwm is
  generic (
      conf_periodo : integer := 1250;  -- periodo do sinal pwm [1250 => f=4KHz (25us)]
      largura_00   : integer :=    0;  -- largura do pulso p/ 00 [0 => 0]
      largura_01   : integer :=   50;  -- largura do pulso p/ 01 [50 => 1us]
      largura_10   : integer :=  500;  -- largura do pulso p/ 10 [500 => 10us]
      largura_11   : integer := 1000   -- largura do pulso p/ 11 [1000 => 20us]
  );
  port (
      clock   : in  std_logic;
      reset   : in  std_logic;
      largura : in  std_logic_vector(1 downto 0);  
      pwm     : out std_logic 
  );
end component;

begin

	pwm: circuito_pwm
	generic map(
		conf_periodo => 1000000,
		largura_00 => 50000,
		largura_01 => 62500,
		largura_10 => 100000,
		largura_11 => 75000
	)
	port map(
		clock => clock,
		reset => reset,
		largura => posicao,
		pwm => controle
	);

end architecture;

