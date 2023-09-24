library ieee;
use ieee.std_logic_1164.all;

entity exp4_trena is
    port (
    clock : in std_logic;
    reset : in std_logic;
    mensurar : in std_logic;
    echo : in std_logic;
    trigger : out std_logic;
    saida_serial : out std_logic;
    medida0 : out std_logic_vector (6 downto 0);
    medida1 : out std_logic_vector (6 downto 0);
    medida2 : out std_logic_vector (6 downto 0);
    pronto : out std_logic;
    db_estado : out std_logic_vector (6 downto 0)
    );
end entity exp4_trena;

architecture structural of exp4_trena is
    component trena_saida_serial_fd is
        port(
            --Entradas de dados
            clock : in std_logic;
            reset : in std_logic;
            echo  : in std_logic;
    
            --Entradas de controle
            medir_sensor : in std_logic;
            partida_serial : in std_logic;
            zera_contador: in std_logic;
            aumenta_contador: in std_logic;
    
            --Saídas de dados
            trigger : out std_logic;
            saida_serial : out std_logic;
            medida0 : out std_logic_vector (3 downto 0);
            medida1 : out std_logic_vector (3 downto 0);
            medida2 : out std_logic_vector (3 downto 0);
    
            --Saídas de controle
            pronto_sensor  : out std_logic;
            pronto_serial  : out std_logic;
            fim_contador   : out std_logic
        );
    end component;

    component trena_saida_serial_uc is
        port(
            --Entradas
            clock: in std_logic;
            reset: in std_logic;
            mensurar: in std_logic;
    
            --Entradas de controle
            pronto_sensor  : in std_logic;
            pronto_serial  : in std_logic;
            fim_contador   : in std_logic;
    
            --Saídas
            pronto: out std_logic;
    
            --Saídas de controle
            medir_sensor : out std_logic;
            partida_serial : out std_logic;
            zera_contador: out std_logic;
            aumenta_contador: out std_logic;
    
            --Depuração
            db_estado: out std_logic_vector(3 downto 0)
        );
    end component;

    component edge_detector is
        port (  
            clock     : in  std_logic;
            signal_in : in  std_logic;
            output    : out std_logic
        );
    end component;

    component hexa7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

    signal s_medir_sensor, s_partida_serial, s_zera_contador, s_aumenta_contador : std_logic;
    signal s_pronto_sensor, s_pronto_serial, s_fim_contador : std_logic;
    signal s_mensurar_pulso : std_logic;
    signal s_db_estado_4bits : std_logic_vector(3 downto 0);
    signal s_medida0, s_medida1, s_medida2 : std_logic_vector(3 downto 0);
begin

    FD: trena_saida_serial_fd port map (
        clock => clock,
        reset => reset,
        echo => echo,
        medir_sensor => s_medir_sensor,
        partida_serial => s_partida_serial,
        zera_contador => s_zera_contador,
        aumenta_contador => s_aumenta_contador,
        trigger => trigger,
        saida_serial => saida_serial,
        medida0 => s_medida0,
        medida1 => s_medida1,
        medida2 => s_medida2,
        pronto_sensor => s_pronto_sensor,
        pronto_serial => s_pronto_serial,
        fim_contador => s_fim_contador
    );

    UC: trena_saida_serial_uc port map (
        clock => clock,
        reset => reset,
        mensurar => s_mensurar_pulso,
        pronto_sensor => s_pronto_sensor,
        pronto_serial => s_pronto_serial,
        fim_contador => s_fim_contador,
        pronto => pronto,
        medir_sensor => s_medir_sensor,
        partida_serial => s_partida_serial,
        zera_contador => s_zera_contador,
        aumenta_contador => s_aumenta_contador,
        db_estado => s_db_estado_4bits
    );

    edge: edge_detector port map (
        clock => clock,
        signal_in => mensurar,
        output => s_mensurar_pulso
    );

    HEX0: hexa7seg port map (
        hexa => s_medida0,
        sseg => medida0
    );

    HEX1: hexa7seg port map (
        hexa => s_medida1,
        sseg => medida1
    );

    HEX2: hexa7seg port map (
        hexa => s_medida2,
        sseg => medida2
    );

    HEX5: hexa7seg port map (
        hexa => s_db_estado_4bits,
        sseg => db_estado
    );

end architecture;