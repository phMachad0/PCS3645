library ieee;
use ieee.std_logic_1164.all;

entity interface_hcsr04 is
    port (
        clock : in std_logic;
        reset : in std_logic;
        medir : in std_logic;
        echo : in std_logic;
        trigger : out std_logic;
        medida : out std_logic_vector(11 downto 0); -- 3 digitos BCD
        pronto : out std_logic;
        db_estado : out std_logic_vector(3 downto 0) -- estado da UC
    );
end entity;

architecture structure of interface_hcsr04 is
    component interface_hcsr04_fd is
        port(
            clock       : in  std_logic;
            reset       : in  std_logic;
            pulso       : in  std_logic;
            zera        : in  std_logic;
            gera        : in std_logic;
            registra    : in  std_logic;
            distancia   : out  std_logic_vector(11 downto 0);
            fim         : out  std_logic;
            fim_medida  : out  std_logic;
            trigger     : out std_logic
        );
    
    end component;

    component interface_hcsr04_uc is 
        port ( 
            clock      : in  std_logic;
            reset      : in  std_logic;
            medir      : in  std_logic;
            echo       : in  std_logic;
            fim_medida : in  std_logic;
            zera       : out std_logic;
            gera       : out std_logic;
            registra   : out std_logic;
            pronto     : out std_logic;
            db_estado  : out std_logic_vector(3 downto 0) 
        );
    end component;
    signal s_pulso, s_zera, s_gera, s_registra, s_fim, s_fim_medida, s_trigger: std_logic;
begin
    FD: interface_hcsr04_fd port map(
        clock      => clock,
        reset      => reset,
        pulso      => s_pulso,
        zera       => s_zera,
        gera       => s_gera,
        registra   => s_registra,
        distancia  => medida,
        fim        => s_fim,
        fim_medida => s_fim_medida,
        trigger    => s_trigger
    );

    UC: interface_hcsr04_uc port map(
        clock      => clock,
        reset      => reset,
        medir      => medir,
        echo       => echo,
        fim_medida => s_fim_medida,
        zera       => s_zera,
        gera       => s_gera,
        registra   => s_registra,
        pronto     => pronto,
        db_estado  => db_estado
    );

end architecture;
