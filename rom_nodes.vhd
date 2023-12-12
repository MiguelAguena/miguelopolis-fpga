library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_nodes is
    port (
        endereco : in std_logic_vector(3 downto 0);
        dado_saida : out std_logic_vector(23 downto 0)
    );
end entity rom_nodes;

architecture arch of rom_nodes is
    type t_mem is array(15 downto 0) of std_logic_vector(23 downto 0);

    constant mem : t_mem := (0 =>  "000001000000000000000000",
                             1 =>  "000101000010000001001000",
                             2 =>  "000011000000000010000100",
                             3 =>  "000000000000000011000000",
                             4 =>  "000110000000000101001001",
                             5 =>  "000111000100000110001010",
                             6 =>  "000000000000000111000000",
                             7 =>  "001011000000000000000000",
                             8 =>  "001100001000001011001111",
                             9 =>  "001101001001001100010000",
                             10 => "001110001010001101010001",
                             11 => "000000000000001110000000",
                             12 => "000000001111000000000000",
                             13 => "000000010000000000000000",
                             14 => "000000010001000000000000",
                             others => "000000000000000000000000");

begin
    -- saida da memoria
    dado_saida <= mem(to_integer(unsigned(endereco)));

end architecture arch;