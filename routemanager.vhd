library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity routemanager is
    port (
        clock, reset : std_logic;
        rx : in std_logic;
        -- Saídas
        tx : out std_logic
    );
end routemanager;

architecture arch of routemanager is
    component routemanager_fd is
        generic (
            MAX_ROUTE : integer := 64
        );
        port (
            clock, reset : std_logic;
            rx : in std_logic;
            -- Saídas
            tx : out std_logic;
            -- UC controls in
            nodeEn, routeEn, proStart, txErr, txRoute, txStart, txInitiate, proReset : in std_logic;
            -- UC controls out
            rxErr, rxReady, endRoute, proReady, txReady : out std_logic;
            rxData : out std_logic_vector(3 downto 0)
        );
    end component routemanager_fd;

    component routemanager_uc is
        port (
            clock, reset : std_logic;
            -- UC controls in
            rxReady, endRoute, proReady, txReady : in std_logic;
            rxData : in std_logic_vector(3 downto 0);
            rxErr : in std_logic;
            -- UC controls out
            nodeEn, routeEn, proStart, txErr, txRoute, txStart, txInitiate, proReset : out std_logic
        );
    end component routemanager_uc;

    signal s_nodeEn, s_routeEn, s_proStart, s_txErr, s_txRoute, s_txStart, s_txInitiate, s_proReset : std_logic;
    signal s_rxErr, s_rxReady, s_endRoute, s_proReady, s_txReady : std_logic;
    signal s_rxData : std_logic_vector(3 downto 0);
begin
    FD : routemanager_fd
    port map(
        clock => clock,
        reset => reset,
        rx => rx,
        tx => tx,
        nodeEn => s_nodeEn,
        routeEn => s_routeEn,
        proStart => s_proStart,
        txErr => s_txErr,
        txInitiate => s_txInitiate,
        txRoute => s_txRoute,
        txStart => s_txStart,
        proReset => s_proReset,
        rxErr => s_rxErr,
        rxReady => s_rxReady,
        endRoute => s_endRoute,
        proReady => s_proReady,
        txReady => s_txReady,
        rxData => s_rxData
    );

    UC : routemanager_uc
    port map(
        clock => clock,
        reset => reset,
        rxReady => s_rxReady,
        endRoute => s_endRoute,
        proReady => s_proReady,
        txReady => s_txReady,
        rxData => s_rxData,
        nodeEn => s_nodeEn,
        routeEn => s_routeEn,
        proStart => s_proStart,
        rxErr => s_rxErr,
        txRoute => s_txRoute,
        txStart => s_txStart,
        txInitiate => s_txInitiate,
        proReset => s_proReset
    );
end arch; -- arch