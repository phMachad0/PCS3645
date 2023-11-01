------------------------------------------------------------------
-- Arquivo   : mux_4x1_n.vhd
-- Projeto   : Experiencia 4 - Trena Digital com Saida Serial
------------------------------------------------------------------
-- Descricao : multiplexador 4x1  
-- > parametro BITS: numero de bits das entradas
--
-- > adaptado a partir do codigo my_4t1_mux.vhd 
-- > do livro "Free Range VHDL" 
--
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     20/09/2019  1.0     Edson Midorikawa  versao inicial
--     31/08/2022  2.0     Edson Midorikawa  revisao do codigo
--     17/09/2023  2.1     Edson Midorikawa  revisao
------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity mux_8x1_n is
    generic (
        constant BITS: integer := 4
    );
    port(
        D7      : in  std_logic_vector (BITS-1 downto 0);
        D6      : in  std_logic_vector (BITS-1 downto 0);
        D5      : in  std_logic_vector (BITS-1 downto 0);
        D4      : in  std_logic_vector (BITS-1 downto 0);
        D3      : in  std_logic_vector (BITS-1 downto 0);
        D2      : in  std_logic_vector (BITS-1 downto 0);
        D1      : in  std_logic_vector (BITS-1 downto 0);
        D0      : in  std_logic_vector (BITS-1 downto 0);
        SEL     : in  std_logic_vector (2 downto 0);
        MUX_OUT : out std_logic_vector (BITS-1 downto 0)
    );
end entity;

architecture arch_mux_8x1_n of mux_8x1_n is
begin

    MUX_OUT <= D7 when (SEL = "111") else
               D6 when (SEL = "110") else
               D5 when (SEL = "101") else
               D4 when (SEL = "100") else
               D3 when (SEL = "011") else
               D2 when (SEL = "010") else
               D1 when (SEL = "001") else
               D0 when (SEL = "000") else
               (others => '1');

end architecture;
