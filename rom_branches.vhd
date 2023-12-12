library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_branches is
    port (
        endereco : in std_logic_vector(5 downto 0);
        dado_saida : out std_logic_vector(7 downto 0)
    );
end entity rom_branches;

architecture arch of rom_branches is
    type t_mem is array(63 downto 0) of std_logic_vector(7 downto 0);

    constant mem : t_mem := (0  => "00000000",
                             1  => "00000001",
                             2  => "00010010",
                             3  => "00100011",
                             4  => "01010010",
                             5  => "00010100",
                             6  => "01000101",
                             7 =>  "01010110",
                             8 =>  "10000001",
                             9 =>  "10010100",
                             10 => "10100101",
                             11 => "01111000",
                             12 => "10001001",
                             13 => "10011010",
                             14 => "10101011",
                             15 => "11001000",
                             16 => "11011001",
                             17 => "11101010",
                             others => "00000000");

begin
    -- saida da memoria
    dado_saida <= mem(to_integer(unsigned(endereco)));

end architecture arch;