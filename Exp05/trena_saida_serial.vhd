library ieee;
use ieee.std_logic_1164.all;

entity trena_saida_serial is
    port (
    clock : in std_logic;
    reset : in std_logic;
    mensurar : in std_logic;
    echo : in std_logic;
    trigger : out std_logic;
    saida_serial : out std_logic;
    medida0 : out std_logic_vector (3 downto 0);
    medida1 : out std_logic_vector (3 downto 0);
    medida2 : out std_logic_vector (3 downto 0);
    pronto : out std_logic;

    --Depuração
	db_mensurar : out std_logic;
	db_saida_serial : out std_logic;
	db_trigger : out std_logic;
	db_echo : out std_logic;
    db_estado : out std_logic_vector (3 downto 0)
    );
end entity trena_saida_serial;

architecture structural of trena_saida_serial is
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

    component hexa7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

    signal s_medir_sensor, s_partida_serial, s_zera_contador, s_aumenta_contador : std_logic;
    signal s_pronto_sensor, s_pronto_serial, s_fim_contador : std_logic;
    signal s_saida_serial, s_trigger : std_logic;
begin

    FD: trena_saida_serial_fd port map (
        clock => clock,
        reset => reset,
        echo => echo,
        medir_sensor => s_medir_sensor,
        partida_serial => s_partida_serial,
        zera_contador => s_zera_contador,
        aumenta_contador => s_aumenta_contador,
        trigger => s_trigger,
        saida_serial => s_saida_serial,
        medida0 => medida0,
        medida1 => medida1,
        medida2 => medida2,
        pronto_sensor => s_pronto_sensor,
        pronto_serial => s_pronto_serial,
        fim_contador => s_fim_contador
    );

    UC: trena_saida_serial_uc port map (
        clock => clock,
        reset => reset,
        mensurar => mensurar,
        pronto_sensor => s_pronto_sensor,
        pronto_serial => s_pronto_serial,
        fim_contador => s_fim_contador,
        pronto => pronto,
        medir_sensor => s_medir_sensor,
        partida_serial => s_partida_serial,
        zera_contador => s_zera_contador,
        aumenta_contador => s_aumenta_contador,
        db_estado => db_estado
    );

    db_mensurar <= mensurar;
    db_saida_serial <= s_saida_serial;
	saida_serial <= s_saida_serial;
    db_trigger <= s_trigger;
	trigger <= s_trigger;
    db_echo <= echo;

end architecture;