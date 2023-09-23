library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_cm_fd is
    generic(
        constant R : integer := 2941; --número de ciclos de clock de duração do sinal "echo" sinal correspondentes a 1cm de distância
        constant N : integer := 12 --número de bits do contador_m interno tal que 2^N >= R
    );
    port(
        clock      : in std_logic;
        conta_bcd  : in std_logic;
        zera_bcd   : in std_logic;
        conta_tick : in std_logic;
        zera_tick  : in std_logic;
        digito0    : out std_logic_vector(3 downto 0);
        digito1    : out std_logic_vector(3 downto 0);
        digito2    : out std_logic_vector(3 downto 0);
        fim        : out std_logic;
        tick       : out std_logic
    );
end entity;

architecture behavior of contador_cm_fd is
    component contador_bcd_3digitos is 
    port ( 
        clock   : in  std_logic;
        zera    : in  std_logic;
        conta   : in  std_logic;
        digito0 : out std_logic_vector(3 downto 0);
        digito1 : out std_logic_vector(3 downto 0);
        digito2 : out std_logic_vector(3 downto 0);
        fim     : out std_logic
    );
    end component;

    component contador_m is
        generic (
            constant M : integer := 50;  
            constant N : integer := 6 
        );
        port (
            clock : in  std_logic;
            zera  : in  std_logic;
            conta : in  std_logic;
            Q     : out std_logic_vector (N-1 downto 0);
            fim   : out std_logic;
            meio  : out std_logic
        );
    end component;
begin
    bcd: contador_bcd_3digitos
        port map(
            clock => clock,
            zera  => zera_bcd,
            conta => conta_bcd,
            digito0 => digito0,
            digito1 => digito1,
            digito2 => digito2,
            fim     => fim
        );

    contador: contador_m
        generic map(
            M => R,
            N => N
        )
        port map(
            clock => clock,
            zera  => zera_tick,
            conta => conta_tick,
            Q     => open,
            fim   => open,
            meio  => tick
        );
end architecture;
