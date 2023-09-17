-----------------Laboratorio Digital-------------------------------------
-- Arquivo   : gerador_pulso.vhd
-- Projeto   : Experiencia 3 - Interface com sensor de distancia
-------------------------------------------------------------------------
-- Descricao : gera pulso de saida com largura pulsos de clock
--             
--             parametro generic: largura
--             
-------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2019  1.0     Edson Midorikawa  criacao 
--     12/09/2022  1.1     Edson Midorikawa  revisao do codigo
--     13/09/2023  1.2     Edson Midorikawa  revisao
-------------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gerador_pulso_tb is
end entity;

architecture tb of gerador_pulso_tb is
   component gerador_pulso is
      generic (
           largura: integer:= 25
      );
      port(
           clock  : in  std_logic;
           reset  : in  std_logic;
           gera   : in  std_logic;
           para   : in  std_logic;
           pulso  : out std_logic;
           pronto : out std_logic
      );
   end component;
   signal clock_in      : std_logic := '0';
   signal reset_in      : std_logic := '0';
   signal gera_in      : std_logic := '0';
   signal para_in       : std_logic := '0';
   signal pulso_out   : std_logic := '0';
   signal pronto_out    : std_logic := '0';

   constant clockPeriod   : time      := 20 ns; -- clock de 50MHz
   signal keep_simulating : std_logic := '0';   -- delimita o tempo de geração do clock

begin
   clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

   dut: gerador_pulso
   generic map (
       largura => 500
   )
   port map (
       clock  => clock_in,
       reset  => reset_in,
       gera   => gera_in,
       para   => '0',
       pulso  => pulso_out,
       pronto  => open
   );
   
   stimulus: process is
   begin
      assert false report "Inicio das simulacoes" severity note;
      keep_simulating <= '1';

      ---- inicio: reset ----------------
      wait for 2*clockPeriod;
      reset_in <= '1'; 
      wait for 2 us;
      reset_in <= '0';
      wait until falling_edge(clock_in);

      --- espera de 100us
      wait for 1 us;
      
      wait for 2*clockPeriod;
         gera_in <= '1'; 
         wait for 2 us;
         gera_in <= '0';
         wait until falling_edge(clock_in);

      wait for 100 us;
      ---- final dos casos de teste da simulacao
      assert false report "Fim das simulacoes" severity note;
      keep_simulating <= '0';

      wait; -- fim da simulação: aguarda indefinidamente (não retirar esta linha)
   end process;
end architecture tb;
