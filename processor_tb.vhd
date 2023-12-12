library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor_tb is
end processor_tb;

architecture arch of processor_tb is
    constant clockPeriod : time := 20 ns; -- clock de 50MHz
    signal keep_simulating : std_logic := '0'; -- delimita o tempo de geração do clock

    type t_routes is array(127 downto 0) of std_logic_vector(3 downto 0);

    signal routes : t_routes := (0  => "1000",
                                 1  => "0100",
                                 2  => "0001",
                                 3  => "0001",
                                 4  => "0010",
                                 5  => "0001",
                                 others => "0000");

    signal s_routesAmount : std_logic_vector(5 downto 0) := "000110";
    signal s_startNode : std_logic_vector(3 downto 0) := "0000";
    signal s_ready : std_logic;
    signal s_proReset, s_reset, s_enable : std_logic := '0';
    signal s_dir_addr : std_logic_vector(6 downto 0) := (others => '0');
    signal s_proc_dir_addr : std_logic_vector(5 downto 0);
    signal s_dir_data : std_logic_vector(3 downto 0);

    signal s_stack_i, s_stack_amount : std_logic_vector(5 downto 0);
    signal s_stack_o : std_logic_vector(3 downto 0);

    component route_processor is
        port (
            clock, reset, fullreset, enable : in std_logic;
            data_ram_directions : in std_logic_vector(3 downto 0);
            addr_ram_directions : out std_logic_vector(5 downto 0);
            directions_amount : in std_logic_vector(5 downto 0);
            stack_addr : in std_logic_vector(5 downto 0);
            stack_o : out std_logic_vector(3 downto 0);
            stack_amount : out std_logic_vector(5 downto 0);
            start_node : in std_logic_vector(3 downto 0);
            ready : out std_logic
        );
    end component;

	 signal clock_in : std_logic := '0';
	 
begin
    clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;
    s_dir_addr(5 downto 0)<= s_proc_dir_addr;
    s_dir_data <= routes(to_integer(unsigned(s_dir_addr)));

    uut : route_processor
    port map (
        clock => clock_in,
        reset => s_proReset,
        fullreset => s_reset,
        enable => s_enable,
        data_ram_directions => s_dir_data,
        addr_ram_directions => s_proc_dir_addr,
        directions_amount => s_routesAmount,
        stack_addr => s_stack_i,
        stack_o => s_stack_o,
        stack_amount => s_stack_amount,
        start_node => s_startNode,
        ready => s_ready
    );

    stimulus : process is
    begin
        assert false report "Inicio das simulacoes" severity note;
        keep_simulating <= '1';

        -- Insira lógica de preparação dos testes aqui

        s_reset <= '1';
        s_proReset <= '1';

        wait for (clockPeriod);

        s_reset <= '0';
        s_proReset <= '0';

        s_enable <= '1';

        -- Insira lógica de teste aqui

        wait for (routes'length * 5 + 3) * clockPeriod * 100;

        assert false report "Fim das simulacoes" severity note;
        keep_simulating <= '0';

        wait; -- fim da simulação: aguarda indefinidamente (não retirar esta linha)
    end process;
end arch; -- arch