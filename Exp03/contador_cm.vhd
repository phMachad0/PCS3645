library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_cm is
    generic (
        constant R : integer; --número de ciclos de clock de duração do sinal "echo" sinal correspondentes a 1cm de distância
        constant N : integer --número de bits do contador_m interno tal que 2^N >= R
    );
    port (
        clock     : in  std_logic;
        reset     : in  std_logic;
        pulso     : in  std_logic;
        digito0   : out std_logic_vector(3 downto 0);
        digito1   : out std_logic_vector(3 downto 0);
        digito2   : out std_logic_vector(3 downto 0);
        fim       : out std_logic;
        pronto    : out std_logic;
        db_estado : out std_logic_vector(3 downto 0)
    );
end entity;

architecture structure of contador_cm is
    component contador_cm_fd is
        generic(
            constant R : integer := 2941;
            constant N : integer := 12 
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
    end component;

    component contador_cm_uc is
        port(
            clock      : in std_logic;
            reset      : in std_logic;
            fim        : in std_logic;
            tick       : in std_logic;
            pulso      : in std_logic;
            conta_bcd  : out std_logic;
            zera_bcd   : out std_logic;
            conta_tick : out std_logic;
            zera_tick  : out std_logic;
            db_estado  : out std_logic_vector(3 downto 0)
        );
    end component;

    signal s_conta_bcd, s_zera_bcd, s_conta_tick, s_zera_tick, s_tick, s_fim : std_logic;
begin

    FD: contador_cm_fd
    generic map(
        R => R,
        N => N
    )
    port map(
        clock      => clock,
        conta_bcd  => s_conta_bcd,
        zera_bcd   => s_zera_bcd,
        conta_tick => s_conta_tick,
        zera_tick  => s_zera_tick,
        digito0    => digito0,
        digito1    => digito1,
        digito2    => digito2,
        fim        => s_fim,
        tick       => s_tick
    );

    UC: contador_cm_uc
    port map(
        clock      => clock,
        reset      => reset,
        pulso      => pulso,
        conta_bcd  => s_conta_bcd,
        zera_bcd   => s_zera_bcd,
        conta_tick => s_conta_tick,
        zera_tick  => s_zera_tick,
        fim        => s_fim,
        tick       => s_tick,
        db_estado  => db_estado
    );
end architecture;