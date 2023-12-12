library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encoder_4x2 is
    port (
        i : in std_logic_vector(3 downto 0);
        o : out std_logic_vector(1 downto 0)
    );
end entity encoder_4x2;

architecture arch of encoder_4x2 is
begin
         --down
    o <= "00" when (i = "0001") else
         --left
         "01" when (i = "0010") else
         --up
         "10" when (i = "0100") else
         --right
         "11" when (i = "1000") else
         "11";
end arch;