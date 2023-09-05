-- controle_servo_tb
--------------------------------------------------------------------------
-- Descricao : 
--             testbench do componente controle_servo
--
--------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     26/09/2021  1.0     Edson Midorikawa  criacao
--     24/08/2022  1.1     Edson Midorikawa  revisao
--     08/05/2023  1.2     Edson Midorikawa  revisao do componente
--     17/08/2023  1.3     Edson Midorikawa  revisao do componente
-------------------------------------------------------------------------
--
--
library ieee;
use ieee.std_logic_1164.all;

entity controle_servo_tb is
end entity;

architecture tb of controle_servo_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component controle_servo is
    port (
      clock     : in  std_logic;
      reset     : in  std_logic;
      posicao   : in  std_logic_vector(1 downto 0);
      sinal_pwm : out std_logic
    );
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
  signal clock_in      : std_logic := '0';
  signal reset_in      : std_logic := '0';
  signal posicao_in    : std_logic_vector (1 downto 0) := "00";
  signal sinal_pwm_out : std_logic := '0';


  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod: time := 20 ns;
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

 
  -- Conecta DUT (Device Under Test)
  dut: controle_servo port map( 
         clock     => clock_in,
         reset     => reset_in,
         posicao   => posicao_in,
         sinal_pwm => sinal_pwm_out
      );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio da simulacao" & LF & "... Simulacao ate 800 ms. Aguarde o final da simulacao..." severity note;
    keep_simulating <= '1';
    
    ---- inicio: reset ----------------
    reset_in <= '1'; 
    wait for 2*clockPeriod;
    reset_in <= '0';
    wait for 2*clockPeriod;

    ---- casos de teste
    -- posicao=00
    posicao_in <= "00"; -- largura de pulso de 0V
    wait for 200 ms;

    -- posicao=01
    posicao_in <= "01"; -- largura de pulso de 1ms
    wait for 200 ms;

    -- posicao=10
    posicao_in <= "10"; -- largura de pulso de 1,5ms
    wait for 200 ms;

    -- posicao=11
    posicao_in <= "11"; -- largura de pulso de 2ms
    wait for 200 ms;

    ---- final dos casos de teste  da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;


end architecture;
