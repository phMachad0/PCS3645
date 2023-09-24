library ieee;
use ieee.std_logic_1164.all;

entity trena_saida_serial_fd is
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
end entity;

architecture structural of trena_saida_serial_fd is
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

    component mux_4x1_n is
        generic (
            constant BITS: integer := 4
        );
        port( 
            D3      : in  std_logic_vector (BITS-1 downto 0);
            D2      : in  std_logic_vector (BITS-1 downto 0);
            D1      : in  std_logic_vector (BITS-1 downto 0);
            D0      : in  std_logic_vector (BITS-1 downto 0);
            SEL     : in  std_logic_vector (1 downto 0);
            MUX_OUT : out std_logic_vector (BITS-1 downto 0)
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

    signal s_medida0, s_medida1, s_medida2: std_logic_vector(6 downto 0);
    signal s_mux_out: std_logic_vector(6 downto 0);
    signal s_medida: std_logic_vector(11 downto 0);
    signal s_seletor : std_logic_vector(1 downto 0);
    

begin
    sensor: interface_hcsr04 port map(
        clock => clock,
        reset => reset,
        medir => medir_sensor,
        echo => echo,
        trigger => trigger,
        medida => s_medida,
        pronto => pronto_sensor,
        db_estado => open
    );

    serial: tx_serial_7O1 port map(
        clock => clock,
        reset => reset,
        partida => partida_serial,
        dados_ascii => s_mux_out,
        saida_serial => saida_serial,
        pronto => pronto_serial,
        db_clock => open,
        db_estado => open,
        db_partida => open,
        db_saida_serial => open,
        db_tick => open
    );

    contador: contador_m generic map (
        M => 3,
        N => 2
    )
    port map (
        clock => clock,
        zera => zera_contador,
        conta => aumenta_contador,
        Q => s_seletor,
        fim => fim_contador
    );

    mux: mux_4x1_n
    generic map (
        BITS => 7
    )
    port map(
        D3 => "0000000",
        D2 => s_medida2,
        D1 => s_medida1,
        D0 => s_medida0,
        SEL => s_seletor,
        MUX_OUT => s_mux_out
    );

    s_medida0 <= "101" & s_medida(3 downto 0);
    s_medida1 <= "101" & s_medida(7 downto 4);
    s_medida2 <= "101" & s_medida(11 downto 8);
    
    medida0 <= s_medida(3 downto 0);
    medida1 <= s_medida(7 downto 4);
    medida2 <= s_medida(11 downto 8);

end architecture;