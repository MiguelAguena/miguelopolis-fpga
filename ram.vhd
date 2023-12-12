library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
    generic (
        addr_s : natural := 6;
        word_s : natural := 6
    );
    port (
        ck     : in  std_logic;
        wr     : in  std_logic;
        reset  : in  std_logic;
        addr   : in  std_logic_vector(addr_s-1 downto 0);
        data_i : in  std_logic_vector(word_s-1 downto 0);
        data_o : out std_logic_vector(word_s-1 downto 0)
    );
end ram;

architecture ram_1 of ram is
    type memory_type is array (0 to (2 ** addr_s) - 1) of std_logic_vector(word_s-1 downto 0);

    signal mem : memory_type := (others => (others => '0'));
begin
    p0: process (ck) is
    begin
        if(ck = '1' AND wr = '1') then
            if(reset = '1') then
                mem <= (others => (others => '0'));
            else
                mem(to_integer(unsigned(addr))) <= data_i;
            end if;
        end if;
    end process p0;

    data_o <= mem(to_integer(unsigned(addr)));
end architecture;