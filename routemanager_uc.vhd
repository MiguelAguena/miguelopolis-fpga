library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity routemanager_uc is
    port (
        clock, reset : std_logic;
        -- UC controls in
        rxReady, endRoute, proReady, txReady : in std_logic;
        rxData : in std_logic_vector(3 downto 0);
		rxErr : in std_logic;
        -- UC controls out
        nodeEn, routeEn, proStart, txErr, txRoute, txStart, txInitiate, proReset : out std_logic
    );
end routemanager_uc;

architecture arch of routemanager_uc is
    -- enum type for state
    type state_type is (waiting, proc_reset, wait_node, write_node, wait_dir, write_dir, send_err, process_route, send_start, send_car, send_route, send_end);
    signal state, nextState : state_type;

begin
    mainPro : process (clock)
    begin
        if (rising_edge(clock)) then
            if (reset = '1') then
                state <= waiting;
            else
                state <= nextState;
            end if;
        end if;
    end process;

    nextState <=
    wait_node when state = waiting and rxReady = '1' and rxData = "0000" else
    write_node when state = wait_node and rxReady = '1' else
    proc_reset when state = write_node else
    wait_dir when state = proc_reset or state = write_dir else
    --Probably will stay in this state indefinitely
    --Do logic later
    send_err when state = wait_dir and rxReady = '1' and rxErr = '1' else
    write_dir when state = wait_dir and rxReady = '1' and rxData /= "0000" else
    process_route when state = write_dir and rxReady = '1' and rxData = "0000" else
    send_start when state = process_route and proReady = '1' else
    send_route when state = send_start and txReady = '1' else
    send_end when state = send_route and endRoute = '1' and txReady = '1' else
    waiting  when state = send_route and txReady = '1' else
    state;

    nodeEn <= '1' when state = write_node else
             '0';
    routeEn <= '1' when state = write_dir else
               '0';
    proStart <= '1' when state = process_route else
                '0';
    txErr <= '1' when state = send_err else
             '0';
    txRoute <= '1' when state = send_route else
               '0';
    txStart <= '1' when state = send_start or state = send_end else
               '0';
    txInitiate <= '1' when state = send_route or state = send_car or state = send_start else
                  '0';
    proReset <= '1' when state = proc_reset else
                '0';

end architecture;