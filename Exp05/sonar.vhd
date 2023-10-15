library ieee;
use ieee.std_logic_1164.all;

entity sonar is
    port (
        clock : in std_logic;
        reset : in std_logic;
        ligar : in std_logic;
        echo  : in std_logic;

        trigger      : out std_logic;
        pwm          : out std_logic;
        saida_serial : out std_logic;
        fim_posicao  : out std_logic;

        --depuracao
        db_estado    : out std_logic_vector(3 downto 0);
        db_estado_sensor: out std_logic_vector(3 downto 0);
        db_estado_serial: out std_logic_vector(3 downto 0);
        db_medida0: out std_logic_vector(3 downto 0);
        db_medida1: out std_logic_vector(3 downto 0);
        db_medida2: out std_logic_vector(3 downto 0);
        db_angulo : out std_logic_vector(2 downto 0)
    );
end entity;

architecture structure of sonar is
    component sonar_uc is
        port(
            --Entradas
            clock: in std_logic;
            reset: in std_logic;
            ligar: in std_logic;
    
            --Saídas
            fim_posicao : out std_logic;
    
            --sinais de controle
            partida_sensor : out std_logic;
            partida_serial : out std_logic;
            zera_contagem_angulos : out std_logic;
            prox_angulo : out std_logic;
            zera_timer : out std_logic;
    
            --sinais de condicao
            pronto_sensor : in std_logic;
            pronto_serial : in std_logic;
            fim_angulos : in std_logic;
            timeout: in std_logic;
    
            --Depuração
            db_estado: out std_logic_vector(3 downto 0)
        );
    end component;

    component sonar_fd is
        port(
            --sinais de dados
            clock : in std_logic;
            reset : in std_logic;
            echo  : in std_logic;
            trigger : out std_logic;
            saida_serial : out std_logic;
            pwm          : out std_logic;
    
            --sinais de controle
            partida_sensor : in std_logic;
            partida_serial : in std_logic;
            zera_contagem_angulos : in std_logic;
            prox_angulo : in std_logic;
            zera_timer : in std_logic;
    
            --sinais de condicao
            pronto_sensor : out std_logic;
            pronto_serial : out std_logic;
            fim_angulos : out std_logic;
            timeout: out std_logic;
    
            --deṕuracao
            db_medida0 : out std_logic_vector(3 downto 0);
            db_medida1 : out std_logic_vector(3 downto 0);
            db_medida2 : out std_logic_vector(3 downto 0);
            db_angulo  : out std_logic_vector(2 downto 0);
            db_estado_sensor : out std_logic_vector(3 downto 0);
            db_estado_serial : out std_logic_vector(3 downto 0)
        );
    end component;
    signal s_partida_sensor, s_partida_serial, s_zera_contagem_angulos,
            s_prox_angulo, s_zera_timer: std_logic;

    signal s_pronto_sensor, s_pronto_serial, s_fim_angulos, s_timeout: std_logic;
begin
    UC: sonar_uc port map(
        clock => clock,
        reset => reset,
        ligar => ligar,
        fim_posicao => fim_posicao,

        partida_sensor => s_partida_sensor,
        partida_serial => s_partida_serial,
        zera_contagem_angulos => s_zera_contagem_angulos,
        prox_angulo => s_prox_angulo,
        zera_timer => s_zera_timer,
        pronto_sensor => s_pronto_sensor,
        pronto_serial => s_pronto_serial,
        fim_angulos => s_fim_angulos,
        timeout => s_timeout,

        db_estado => db_estado
    );

    FD: sonar_fd port map (
        clock => clock,
        reset => reset,
        echo => echo,
        trigger => trigger,
        saida_serial => saida_serial,
        pwm => pwm,

        partida_sensor => s_partida_sensor,
        partida_serial => s_partida_serial,
        zera_contagem_angulos => s_zera_contagem_angulos,
        prox_angulo => s_prox_angulo,
        zera_timer => s_zera_timer,
        pronto_sensor => s_pronto_sensor,
        pronto_serial => s_pronto_serial,
        fim_angulos => s_fim_angulos,
        timeout => s_timeout,

        db_medida0 => db_medida0,
        db_medida1 => db_medida1,
        db_medida2 => db_medida2,
        db_angulo => db_angulo,
        db_estado_sensor => db_estado_sensor,
        db_estado_serial => db_estado_serial
    );
    

end architecture;