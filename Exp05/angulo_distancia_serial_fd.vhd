library ieee;
use ieee.std_logic_1164.all;

entity angulo_distancia_serial_fd is
  port
  (
    clock        : in std_logic;
    reset        : in std_logic;
    angulo       : in std_logic_vector (2 downto 0);
    medida0      : in std_logic_vector (3 downto 0);
    medida1      : in std_logic_vector (3 downto 0);
    medida2      : in std_logic_vector (3 downto 0);
    saida_serial : out std_logic;

    --entradas de controle
    partida_serial        : in std_logic;
    zera_contagem_digitos : in std_logic;
    prox_digito           : in std_logic;

    --saidas de condição
    pronto_serial         : out std_logic;
    fim_digitos           : out std_logic
  );
end entity;

architecture structure of angulo_distancia_serial_fd is
  component mux_8x1_n is
    generic
    (
      constant BITS : integer := 4
    );
    port
    (
      D7      : in std_logic_vector (BITS - 1 downto 0);
      D6      : in std_logic_vector (BITS - 1 downto 0);
      D5      : in std_logic_vector (BITS - 1 downto 0);
      D4      : in std_logic_vector (BITS - 1 downto 0);
      D3      : in std_logic_vector (BITS - 1 downto 0);
      D2      : in std_logic_vector (BITS - 1 downto 0);
      D1      : in std_logic_vector (BITS - 1 downto 0);
      D0      : in std_logic_vector (BITS - 1 downto 0);
      SEL     : in std_logic_vector (2 downto 0);
      MUX_OUT : out std_logic_vector (BITS - 1 downto 0)
    );
  end component;

  component contador_m is
    generic
    (
      constant M : integer := 50;
      constant N : integer := 6
    );
    port
    (
      clock : in std_logic;
      zera  : in std_logic;
      conta : in std_logic;
      Q     : out std_logic_vector (N - 1 downto 0);
      fim   : out std_logic;
      meio  : out std_logic
    );
  end component;

  component tx_serial_7O1 is
    port
    (
      clock           : in std_logic;
      reset           : in std_logic;
      partida         : in std_logic;
      dados_ascii     : in std_logic_vector(6 downto 0);
      saida_serial    : out std_logic;
      pronto          : out std_logic;
      db_clock        : out std_logic;
      db_tick         : out std_logic;
      db_partida      : out std_logic;
      db_saida_serial : out std_logic;
      db_estado       : out std_logic_vector(3 downto 0)
    );
  end component;

  signal s_mux_angulo_ascii : std_logic_vector(27 downto 0);
  signal s_caractere_ascii  : std_logic_vector(6 downto 0);
  signal s_sel_digito       : std_logic_vector(2 downto 0);
begin

  mux_8x1_angulo : mux_8x1_n
    generic map (
        BITS => 28
    )
    port map
    (
        D7      => "0110001-0110110-0110000-0101100", --160,
        D6      => "0110001-0110100-0110000-0101100", --140,
        D5      => "0110001-0110010-0110000-0101100", --120,
        D4      => "0110001-0110000-0110000-0101100", --100,
        D3      => "0110000-0111000-0110000-0101100", --080,
        D2      => "0110000-0110110-0110000-0101100", --060,
        D1      => "0110000-0110100-0110000-0101100", --040,
        D0      => "0110000-0110010-0110000-0101100", --020,
        SEL     => angulo,
        MUX_OUT => s_mux_angulo_ascii
    );

  mux_8x1_caractere : mux_8x1_n
    generic map (
        BITS => 7
    )
    port map (
        D7      => "0100011",
        D6      => medida0,
        D5      => medida1,
        D4      => medida2,
        D3      => s_mux_angulo_ascii(6 downto 0),
        D2      => s_mux_angulo_ascii(13 downto 7),
        D1      => s_mux_angulo_ascii(20 downto 14),
        D0      => s_mux_angulo_ascii(27 downto 21),
        SEL     => s_sel_digito,
        MUX_OUT => s_caractere_ascii
    );

  contador : contador_m
    generic map (
        M => 7,
        N => 3
    )
    port map (
        clock => clock,
        zera  => zera_contagem_digitos,
        conta => prox_digito,
        Q     => s_sel_digito,
        fim   => fim_digitos
    );

  tx_serial : tx_serial_7O1
    port map (
        clock           => clock,
        reset           => reset,
        partida         => partida_serial,
        dados_ascii     => s_caractere_ascii,
        saida_serial    => saida_serial,
        pronto          => pronto_serial,
        db_clock        => open,
        db_tick         => open,
        db_partida      => open,
        db_saida_serial => open,
        db_estado       => open
    );

end architecture;