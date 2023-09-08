
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_serial_7O1 is
    port (  
        clock             : in  std_logic; 
        reset             : in  std_logic;
        dado_serial       : in  std_logic;
        paridade_recebida : out  std_logic;
        pronto_rx         : out  std_logic;
        --tem_dado        : out  std_logic;
        --paridade_ok     : out  std_logic;
        dado_recebido0    : out  std_logic;
        dado_recebido1    : out  std_logic;
        db_estado         : out std_logic_vector(6 downto 0)
    );
end entity;
