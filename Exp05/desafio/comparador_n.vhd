library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity comparador_n is
    generic(
        N : integer := 8  -- Número de bits para comparar
    );
    Port(
        A, B : in  std_logic_vector(N-1 downto 0);  -- Entradas de N bits
        Equal : out std_logic               -- Saídas indicando se A > B e A = B
    );
end entity comparador_n;

architecture Behavioral of comparador_n is
begin
    process(A, B)
    begin
        -- Verifica se A é igual a B
        if A = B then
            Equal <= '1';
        else
            Equal <= '0';
        end if;
    end process;
end architecture Behavioral;
