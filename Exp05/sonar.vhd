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

        --7 segmentos
        sel_db       :  in std_logic; --escolher uma chave para conectar no pin planner
        db_estado    : out std_logic_vector(6 downto 0); --conecta no hex5
        db_angulo    : out std_logic_vector(6 downto 0); --conecta no hex4
        db_hex0      : out std_logic_vector(6 downto 0);
        db_hex1      : out std_logic_vector(6 downto 0);
        db_hex2      : out std_logic_vector(6 downto 0)
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

    component hexa7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

    component mux_2x1_n is
        generic (
            constant BITS: integer := 4
        );
        port(
            D1      : in  std_logic_vector (BITS-1 downto 0);
            D0      : in  std_logic_vector (BITS-1 downto 0);
            SEL     : in  std_logic;
            MUX_OUT : out std_logic_vector (BITS-1 downto 0)
        );
    end component;

    signal s_partida_sensor, s_partida_serial, s_zera_contagem_angulos,
            s_prox_angulo, s_zera_timer: std_logic;

    signal s_pronto_sensor, s_pronto_serial, s_fim_angulos, s_timeout: std_logic;

    signal s_db_medida0, s_db_medida1, s_db_medida2, s_db_estado_sensor,
           s_db_estado_serial, s_db_estado : std_logic_vector(3 downto 0);
    signal s_db_angulo : std_logic_vector(2 downto 0);
    signal s_mux_out   : std_logic_vector(11 downto 0);
    signal s_d1_mux, s_d0_mux : std_logic_vector(11 downto 0);
    signal s_hex4             : std_logic_vector(3 downto 0);
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

        db_estado => s_db_estado
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

        db_medida0 => s_db_medida0,
        db_medida1 => s_db_medida1,
        db_medida2 => s_db_medida2,
        db_angulo => s_db_angulo,
        db_estado_sensor => s_db_estado_sensor,
        db_estado_serial => s_db_estado_serial
    );

    s_d0_mux <= s_db_medida2 & s_db_medida1 & s_db_medida0;
    s_d1_mux <= x"0" & s_db_estado_sensor & s_db_estado_serial;
    MUX: mux_2x1_n
    generic map (
        BITS => 12
    )
    port map (
        D0 => s_d0_mux,
        D1 => s_d1_mux,
        SEL => sel_db,
        MUX_OUT => s_mux_out
    );
    
    HEX0: hexa7seg port map (
        hexa => s_mux_out(3 downto 0),
        sseg => db_hex0
    );
    HEX1: hexa7seg port map (
        hexa => s_mux_out(7 downto 4),
        sseg => db_hex1
    );
    HEX2: hexa7seg port map (
        hexa => s_mux_out(11 downto 8),
        sseg => db_hex2
    );

    s_hex4 <= '0' & s_db_angulo;

    HEX4: hexa7seg port map (
        hexa => s_hex4,
        sseg => db_angulo
    );
    HEX5: hexa7seg port map (
        hexa => s_db_estado,
        sseg => db_estado
    );
end architecture;