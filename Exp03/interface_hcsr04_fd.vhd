library ieee;
use ieee.std_logic_1164.all;

entity interface_hcsr04_fd is
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

end entity;

architecture structure of interface_hcsr04_fd is
    component gerador_pulso is
        generic (
             largura: integer:= 25
        );
        port(
             clock  : in  std_logic;
             reset  : in  std_logic;
             gera   : in  std_logic;
             para   : in  std_logic;
             pulso  : out std_logic;
             pronto : out std_logic
        );
     end component;

    component contador_cm is
        generic (
            constant R : integer;
            constant N : integer
        );
        port (
            clock   : in  std_logic;
            reset   : in  std_logic;
            pulso   : in  std_logic;
            digito0 : out std_logic_vector(3 downto 0);
            digito1 : out std_logic_vector(3 downto 0);
            digito2 : out std_logic_vector(3 downto 0);
            fim     : out std_logic;
            pronto  : out std_logic
        );
    end component;

    component registrador_n is
        generic (
            constant N: integer
        );
        port (
            clock  : in  std_logic;
            clear  : in  std_logic;
            enable : in  std_logic;
            D      : in  std_logic_vector (N-1 downto 0);
            Q      : out std_logic_vector (N-1 downto 0) 
        );
    end component;

    signal digitos: std_logic_vector(11 downto 0);
    signal s_clock: std_logic;
begin
    s_clock <= clock;
    contador_cm_dut: contador_cm
        generic map (
            R => 1000000000,
            N => 4
        )
        port map (
            clock   => s_clock,
            reset   => zera,
            pulso   => pulso,
            digito0 => digitos(3 downto 0),
            digito1 => digitos(7 downto 4),
            digito2 => digitos(11 downto 8),
            fim     => fim,
            pronto  => fim_medida
        );

    gerador_pulso_dut: gerador_pulso
        generic map (
            largura => 500
        )
        port map (
            clock  => clock,
            reset  => reset,
            gera   => gera,
            para   => '0',
            pulso  => trigger,
            pronto => open
        );
    registrador_n_dut: registrador_n
        generic map (
            N => 12
        )
        port map (
            clock  => clock,
            clear  => zera,
            enable => registra,
            D      => digitos,
            Q      => distancia
        );
end architecture;