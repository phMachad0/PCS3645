library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sonar_fd is
    port(
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
end entity;

architecture structural of sonar_fd is
    component interface_hcsr04 is
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
    end component;

    component angulo_distancia_serial is
        port
        (
            clock   : in std_logic;
            reset   : in std_logic;
            partida : in std_logic;
            angulo_ascii : in std_logic_vector (23 downto 0);
            medida       : in std_logic_vector (11 downto 0);
        
            saida_serial : out std_logic;
            pronto       : out std_logic;
        
            --depuracao
            db_estado : out std_logic_vector(3 downto 0)
        );
    end component;

    component tx_serial_7O1 is
        port (
            clock           : in  std_logic;
            reset           : in  std_logic;
            partida         : in  std_logic;
            dados_ascii     : in  std_logic_vector(6 downto 0);
            saida_serial    : out std_logic;
            pronto          : out std_logic;
            db_clock        : out std_logic;
            db_tick         : out std_logic;
            db_partida      : out std_logic;
            db_saida_serial : out std_logic;
            db_estado       : out std_logic_vector(3 downto 0)
        );
    end component;

    component controle_servo_3 is
        port
        (
          clock      : in std_logic;
          reset      : in std_logic;
          posicao    : in std_logic_vector(2 downto 0);
          pwm        : out std_logic;
          db_reset   : out std_logic;
          db_pwm     : out std_logic;
          db_posicao : out std_logic_vector(2 downto 0)
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

    component contadorg_updown_m is
        generic (
            constant M: integer := 50 -- modulo do contador
        );
        port (
            clock  : in  std_logic;
            zera_as: in  std_logic;
            zera_s : in  std_logic;
            conta  : in  std_logic;
            Q      : out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
            inicio : out std_logic;
            fim    : out std_logic;
            meio   : out std_logic 
       );
    end component;

    component rom_angulos_8x24 is
        port (
            endereco : in  std_logic_vector(2 downto 0);
            saida    : out std_logic_vector(23 downto 0)
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
    signal s_saida_serial_trena: std_logic;
    signal s_medida : std_logic_vector(11 downto 0);
    signal s_angulo_ascii : std_logic_vector(23 downto 0);
    signal s_angulo_sel : std_logic_vector(2 downto 0);
begin
    sensor : interface_hcsr04 port map(
        clock => clock,
        reset => reset,
        echo => echo,
        trigger => trigger,
        medida => s_medida,

        medir => partida_sensor, --entrada de controle
        pronto => pronto_sensor, --saida de condicao
        db_estado => db_estado_sensor
    );

    ROM: rom_angulos_8x24 port map(
        endereco => s_angulo_sel,
        saida => s_angulo_ascii
    );

    serial: angulo_distancia_serial port map (
        clock   => clock,
        reset   => reset,
        partida => partida_serial,
        angulo_ascii  => s_angulo_ascii,
        medida  => s_medida,
      
        saida_serial => saida_serial,
        pronto       => pronto_serial,
      
        --depuracao
        db_estado => db_estado_serial
    );

    contador_angulos: contadorg_updown_m
    generic map (
        M => 7
    )
    port map (
        clock => clock,
        zera_as => reset,
        zera_s => zera_contagem_angulos,
        conta => prox_angulo,
        Q => s_angulo_sel,
        inicio => open,
        fim => fim_angulos,
        meio => open
    );

    contador_timer: contador_m
    generic map (
        M => 100000000,
        N => 27
    )
    port map (
        clock => clock,
        zera => zera_timer,
        conta => '1',
        Q => open,
        fim => timeout,
        meio => open
    );

    servo: controle_servo_3 port map (
        clock      => clock,
        reset      => reset,
        posicao    => s_angulo_sel,
        pwm        => pwm,
        db_reset   => open,
        db_pwm     => open,
        db_posicao => open
    );

end architecture;