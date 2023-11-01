------------------------------------------------------------------------------
-- Arquivo   : angulo_distancia_serial_tb.vhd
-- Projeto   : Experiencia 5
------------------------------------------------------------------------------
-- Descricao : circuito do exp5
-- > Testbench para angulo_distancia_serial_tb
------------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     15/10/2023  1.0     Bruno Alcântara   versao inicial
------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity angulo_distancia_serial_tb is
end entity;

architecture tb of angulo_distancia_serial_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component angulo_distancia_serial is
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
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (ModelSim)
  signal clock_in         : std_logic := '0';
  signal reset_in         : std_logic := '0';
  signal partida_in       : std_logic := '0';
  signal angulo_ascii_in  : std_logic_vector (23 downto 0) := x"000000";
  signal medida_in        : std_logic_vector (11 downto 0) := x"000";
  -- signal dados_ascii_8_in : std_logic_vector (7 downto 0) := "00000000";
  signal saida_serial_out : std_logic := '1';
  signal pronto_out       : std_logic := '0';
  -- signal db_estado_out    : std_logic_vector(6 downto 0) := "0000000";

  -- Configurações do clock
  signal keep_simulating : std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod   : time := 20 ns;    -- clock de 50MHz
  
  signal caso : integer := 0;

begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;
  
  -- Conecta DUT (Device Under Test)
  dut: angulo_distancia_serial
       port map
       ( 
           clock           => clock_in,
           reset           => reset_in,
           partida         => partida_in,
           angulo_ascii    => angulo_ascii_in,
           medida          => medida_in,
           saida_serial    => saida_serial_out,
           pronto          => pronto_out,
           db_estado       => open
      );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is

  type serial_teste_type is record
      angulo : std_logic_vector(23 downto 0); 
      medida : std_logic_vector(11 downto 0);     
  end record;

  type array_std_logic_vector_7 is array (natural range <>) of serial_teste_type;
  constant vetor_teste: array_std_logic_vector_7 :=
     (
        (x"303430", x"011"),
        (x"303630", x"109"),
        (x"313630", x"035")
     );

  begin
  
    assert false report "Inicio da simulacao" severity note;
    keep_simulating <= '1';
    
    ---- inicio da simulacao: reset ----------------
    partida_in <= '0';
    -- pulso largo de reset com 20 periodos de clock
    wait until falling_edge(clock_in);
    reset_in   <= '1'; 
    wait for 20*clockPeriod;
    reset_in   <= '0';
    wait until falling_edge(clock_in);
    wait for 50*clockPeriod;

    ---- Casos de teste

    -- Para cada padrao de teste no vetor
    for i in vetor_teste'range loop

        assert false report "caso: " & integer'image(i) severity note;
        caso <= i;

        ---- dado de entrada do vetor de teste
        angulo_ascii_in <= vetor_teste(i).angulo;
        medida_in       <= vetor_teste(i).medida;
        wait for 20*clockPeriod;
    
        ---- acionamento da partida (inicio da transmissao)
        wait until falling_edge(clock_in);
        partida_in <= '1';
        wait for 25*clockPeriod; -- pulso partida com 25 periodos de clock
        partida_in <= '0';
    
        ---- espera final da transmissao (pulso pronto em 1)
        wait until pronto_out='1';
        
        ---- final do caso de teste 
    
        -- intervalo entre casos de teste
        wait for 500*clockPeriod;
    

    end loop;

    ---- final dos casos de teste da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;

end architecture;
