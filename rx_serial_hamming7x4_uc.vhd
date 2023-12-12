
library ieee;
use ieee.std_logic_1164.all;

entity rx_serial_hamming7x4_uc is
    port (
        clock : in std_logic;
        reset : in std_logic;
        -- partida : in std_logic;
        tick : in std_logic;
        fim : in std_logic;
        dado_serial : in std_logic;
        meio_contador : in std_logic;
        zera_dados : out std_logic;
        zera : out std_logic;
        -- conta : out std_logic;
        -- carrega : out std_logic;
        desloca : out std_logic;
        pronto : out std_logic;
        db_estado : out std_logic_vector(3 downto 0)
    );
end entity;

architecture arch of rx_serial_hamming7x4_uc is

    type tipo_estado is (inicial, preparacao, espera_primeiro, leitura, espera, final);
    signal Eatual : tipo_estado; -- estado atual
    signal Eprox : tipo_estado; -- proximo estado

begin

    -- memoria de estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox;
        end if;
    end process;

    -- transição de estados

    Eprox <=
        inicial when Eatual = final else
        preparacao when Eatual = inicial and dado_serial = '0' else
        espera_primeiro when Eatual = preparacao else
        leitura when Eatual = espera_primeiro and meio_contador = '1' else
        espera when Eatual = leitura and fim = '0' else
        final when Eatual = leitura and fim = '1' else
        final when Eatual = espera and fim = '1' else
        leitura when Eatual = espera and tick = '1' else
        Eatual;
    -- logica de saida (Moore)

    with Eatual select
        zera <= '1' when preparacao | leitura, '0' when others;

    with Eatual select
        zera_dados <= '1' when preparacao, '0' when others;

    with Eatual select
        desloca <= '1' when leitura, '0' when others;

    with Eatual select
        pronto <= '1' when final, '0' when others;

    with Eatual select
        db_estado <= "0000" when inicial,
        "0001" when preparacao,
        "0010" when espera_primeiro,
        "0100" when leitura,
        "1000" when espera,
        "1111" when final, -- Final
        "1110" when others; -- Erro

end architecture;