
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_serial_hamming7x4 is
    port (
        clock : in std_logic;
        reset : in std_logic;
        dado_serial : in std_logic;
        dado_recebido : out std_logic_vector(3 downto 0);
        erro : out std_logic;
        pronto_rx : out std_logic
        -- db_estado : out std_logic_vector(6 downto 0)
    );
end entity;

architecture estrutural of rx_serial_hamming7x4 is

    component rx_serial_hamming7x4_uc
        port (
            clock : in std_logic;
            reset : in std_logic;
            tick : in std_logic;
            fim : in std_logic;
            dado_serial : in std_logic;
            meio_contador : in std_logic;
            zera : out std_logic;
            zera_dados : out std_logic;
            -- conta : out std_logic;
            desloca : out std_logic;
            pronto : out std_logic;
            db_estado : out std_logic_vector(3 downto 0)
        );
    end component rx_serial_hamming7x4_uc;

    component rx_serial_hamming7x4_fd
        port (
            clock : in std_logic;
            reset : in std_logic;
            -- zera : in std_logic;
            -- conta : in std_logic;
            zera_dados : in std_logic;
            desloca : in std_logic;
            dado_serial : in std_logic;
            dados : out std_logic_vector(3 downto 0);
            erro : out std_logic;
            fim : out std_logic
        );
    end component rx_serial_hamming7x4_fd;

    component contador_m
        generic (
            constant M : integer;
            constant N : integer
        );
        port (
            clock : in std_logic;
            zera : in std_logic;
            conta : in std_logic;
            Q : out std_logic_vector(N - 1 downto 0);
            fim : out std_logic;
            meio : out std_logic
        );
    end component contador_m;

    component hexa7seg
        port (
            hexa : in std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component hexa7seg;

    -- s_partida, s_partida_ed
    signal s_reset, s_zera_dados : std_logic;
    -- s_carrega
    signal s_zera, s_conta, s_desloca, s_tick, s_fim : std_logic;
    signal s_saida_serial : std_logic;
    signal s_meio_contador : std_logic;
    signal s_estado : std_logic_vector(3 downto 0);
    signal s_saida_ascii : std_logic_vector(3 downto 0);
begin

    -- sinais reset e partida mapeados na GPIO (ativos em alto)
    s_reset <= reset;
    -- s_partida <= partida;

    -- unidade de controle
    U1_UC : rx_serial_hamming7x4_uc
    port map(
        clock => clock,
        reset => s_reset,
        tick => s_tick,
        fim => s_fim,
        dado_serial => dado_serial,
        zera_dados => s_zera_dados,
        meio_contador => s_meio_contador,
        zera => s_zera,
        desloca => s_desloca,
        pronto => pronto_rx,
        db_estado => s_estado
    );

    -- fluxo de dados
    U2_FD : rx_serial_hamming7x4_fd
    port map(
        clock => clock,
        reset => s_reset,
        -- zera => s_zera,
        desloca => s_desloca,
        zera_dados => s_zera_dados,
        dado_serial => dado_serial,
        dados => s_saida_ascii,
        erro => erro,
        fim => s_fim
    );
    -- gerador de tick
    -- fator de divisao para 9600 bauds (5208=50M/9600)
    -- fator de divisao para 115.200 bauds (434=50M/115200)
    U3_TICK : contador_m
    generic map(
        M => 434, -- 115200 bauds
        N => 13
    )
    port map(
        clock => clock,
        zera => s_zera,
        conta => '1',
        Q => open,
        fim => s_tick,
        meio => s_meio_contador
    );

    -- HEX0 : hexa7seg
    -- port map(
    --     hexa => s_estado,
    --     sseg => db_estado
    -- );

    dado_recebido <= s_saida_ascii;

    -- HEX1 : hexa7seg
    -- port map(
    --     hexa => s_saida_ascii(3 downto 0),
    --     sseg => dado_recebido0
    -- );

    -- s_saida_ascii_1 <= "0" & s_saida_ascii(6 downto 4);
    -- HEX2 : hexa7seg
    -- port map(
    --     hexa => s_saida_ascii_1,
    --     sseg => dado_recebido1
    -- );

end architecture;