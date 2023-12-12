library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity route_processor is
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
end route_processor;

architecture arch of route_processor is
    component rom_nodes is
        port (
            endereco : in std_logic_vector(3 downto 0);
            dado_saida : out std_logic_vector(23 downto 0)
        );
    end component rom_nodes;
    component rom_branches is
        port (
            endereco : in std_logic_vector(5 downto 0);
            dado_saida : out std_logic_vector(7 downto 0)
        );
    end component rom_branches;
    component ram is
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
    end component ram;

    component encoder_4x2 is
        port (
            i : in  std_logic_vector(3 downto 0);
            o : out std_logic_vector(1 downto 0)
        );
    end component encoder_4x2;

    signal s_stack_amount : std_logic_vector(5 downto 0);

    signal s_addr_ram_directions : std_logic_vector(5 downto 0);

    signal s_nodes_addr : std_logic_vector(3 downto 0) := (others => '0');
    signal s_nodes_data : std_logic_vector(23 downto 0);
    signal s_nodes_data_mux_out : std_logic_vector(5 downto 0);
    signal s_nodes_data_mux_sel : std_logic_vector(1 downto 0) := (others => '0');

    signal s_branches_addr : std_logic_vector(5 downto 0) := (others => '0');
    signal s_branches_data : std_logic_vector(7 downto 0);
    signal s_branches_data_mux_out : std_logic_vector(3 downto 0);
    signal s_branches_data_mux_sel : std_logic := '0';

    signal s_occ_nodes_wr : std_logic;
    signal s_occ_nodes_reset : std_logic := '0';
    signal s_occ_nodes_addr : std_logic_vector(3 downto 0) := (others => '0');
    signal s_occ_nodes_data_i : std_logic_vector(127 downto 0) := (others => '0');
    signal s_occ_nodes_data_o : std_logic_vector(127 downto 0);

    signal s_occ_branches_wr : std_logic;
    signal s_occ_branches_reset : std_logic := '0';
    signal s_occ_branches_addr : std_logic_vector(5 downto 0) := (others => '0');
    signal s_occ_branches_data_i : std_logic_vector(127 downto 0) := (others => '0');
    signal s_occ_branches_data_o : std_logic_vector(127 downto 0);

    signal s_stack_wr : std_logic;
    signal s_stack_reset : std_logic := '0';
    signal s_stack_counter : integer := 0;

    signal s_stack_addr_proc : std_logic_vector(5 downto 0) := (others => '0');
    signal s_stack_i : std_logic_vector(3 downto 0) := (others => '0');
    signal s_stack_o : std_logic_vector(3 downto 0);

    signal s_stack_addr : std_logic_vector(5 downto 0);

    signal s_cur_node : std_logic_vector(3 downto 0) := start_node;
    signal s_wait_branch : integer := 0;

    signal s_next_node : std_logic_vector(3 downto 0) := (others => '0');
    signal s_node_occupation : std_logic := '0';
    signal s_branch_occupation : std_logic := '0';

    signal s_data_ram_directions_encoded : std_logic_vector(1 downto 0);

    signal s_ctrl_write_occ : std_logic := '0';
    signal s_ctrl_write_stack : std_logic := '0';
    signal s_ctrl_write_wait : std_logic := '0';
    signal s_ctrl_set : std_logic := '0';
    signal s_ctrl_get_node : std_logic := '0';
    signal s_ctrl_get_branch : std_logic := '0';
    signal s_ctrl_get_occ : std_logic := '0';
    signal s_ctrl_set_occ : std_logic := '0';
    signal s_ctrl_reset_dir_addr : std_logic := '0'; 

    signal s_ready : std_logic := '1';
begin
    s_nodes_data_mux_out <= s_nodes_data(5 downto 0) when (s_nodes_data_mux_sel = "00") else
                            s_nodes_data(11 downto 6) when (s_nodes_data_mux_sel = "01") else
                            s_nodes_data(17 downto 12) when (s_nodes_data_mux_sel = "10") else
                            s_nodes_data(23 downto 18);

    s_stack_addr <= s_stack_addr_proc when s_ready = '0' else
                    stack_addr;

    ENC: encoder_4x2 port MAP (
        i => data_ram_directions,
        o => s_data_ram_directions_encoded
    );

    ROM_N: rom_nodes port map(
        endereco => s_nodes_addr,
        dado_saida => s_nodes_data
    );

    ROM_B: rom_branches port map(
        endereco => s_branches_addr,
        dado_saida => s_branches_data
    );

    RAM_OCC_N: ram generic map(
        addr_s => 4,
        word_s => 128
    )
    port map(
        ck => clock,
        wr => s_occ_nodes_wr,
        reset => s_occ_nodes_reset,
        addr => s_occ_nodes_addr,
        data_i => s_occ_nodes_data_i,
        data_o => s_occ_nodes_data_o
    );

    RAM_OCC_B: ram generic map(
        addr_s => 6,
        word_s => 128
    )
    port map(
        ck => clock,
        wr => s_occ_branches_wr,
        reset => s_occ_branches_reset,
        addr => s_occ_branches_addr,
        data_i => s_occ_branches_data_i,
        data_o => s_occ_branches_data_o
    );

    RAM_STACK: ram generic map(
        addr_s => 6,
        word_s => 4
    )
    port map(
        ck => clock,
        wr => s_stack_wr,
        reset => s_stack_reset,
        addr => s_stack_addr,
        data_i => s_stack_i,
        data_o => s_stack_o
    );

    P0: process(clock) is
    begin
        if(rising_edge(clock)) then
            if(fullreset = '1') then
                s_occ_nodes_reset <= '1';
                s_occ_branches_reset <= '1';
            end if;
            
            if(reset = '1') then
                s_cur_node <= start_node;
                s_wait_branch <= 0;
                s_addr_ram_directions <= "000000";
                s_stack_addr_proc <= "000000";
                s_stack_amount <= "000000";
                s_stack_counter <= 0;
                s_stack_reset <= '1';
                s_ctrl_write_stack <= '0';
                s_ctrl_write_wait <= '0';
                s_ctrl_write_occ <= '0';
                s_ctrl_set <= '0';
                s_ctrl_get_node <= '0';
                s_ctrl_get_branch <= '0';
                s_ctrl_get_occ <= '0';
                s_ctrl_set_occ <= '0';
                s_ctrl_reset_dir_addr <= '0';
                s_ready <= '0';
                s_occ_branches_data_i <= s_occ_branches_data_o;
                s_occ_nodes_data_i <= s_occ_nodes_data_o;
                s_stack_wr <= '0';

            elsif(enable = '1') then
                if(s_ctrl_write_stack = '0') then
                    if(s_addr_ram_directions < directions_amount) then
                        if(s_ctrl_set = '0') then
                            if(s_ctrl_get_node = '0') then
                                s_stack_reset <= '0';
                                s_occ_nodes_reset <= '0';
                                s_occ_branches_reset <= '0';

                                s_nodes_addr <= s_cur_node;
                                s_nodes_data_mux_sel <= s_data_ram_directions_encoded;
                                s_ctrl_get_node <= '1';
                            else
                                s_ctrl_get_node <= '0'; 
                                if(s_ctrl_get_branch = '0') then
                                    s_branches_addr <= s_nodes_data_mux_out;
                                    s_ctrl_get_branch <= '1';
                                else
                                    s_ctrl_get_branch <= '0';
                                    if(s_ctrl_get_occ = '0') then
                                        if(s_branches_data(3 downto 0) /= s_cur_node) then
                                            s_next_node <= s_branches_data(3 downto 0);
                                            s_occ_nodes_addr <= s_branches_data(3 downto 0);
                                        else
                                            s_next_node <= s_branches_data(7 downto 4);
                                            s_occ_nodes_addr <= s_branches_data(7 downto 4);
                                        end if;

                                        s_occ_branches_addr <= s_nodes_data_mux_out;
                                        s_ctrl_get_occ <= '1';
                                    
                                    else
                                        s_ctrl_get_occ <= '0';
                                        s_node_occupation <= s_occ_nodes_data_o(s_wait_branch + s_stack_counter + to_integer(unsigned(s_addr_ram_directions)));
                                        s_branch_occupation <= s_occ_branches_data_o(s_wait_branch + s_stack_counter + to_integer(unsigned(s_addr_ram_directions)));
                                        s_occ_branches_data_i <= s_occ_branches_data_o;
                                        s_occ_nodes_data_i <= s_occ_nodes_data_o;
                                        s_ctrl_set <= '1';
                                    end if;
                                end if;
                            end if;

                        else
                            if(s_node_occupation = '1' or s_branch_occupation = '1') then
                                s_wait_branch <= s_wait_branch + 1;
                                s_stack_counter <= 0;
                                s_addr_ram_directions <= "000000";
                            else
                                if(s_ctrl_set_occ = '0') then
                                    s_cur_node <= s_next_node;

                                    s_occ_nodes_addr <= s_next_node;
                                    s_occ_branches_addr <= s_nodes_data_mux_out;
                                    s_ctrl_set_occ <= '1';
                                else
                                    s_ctrl_set_occ <= '0';
                                    s_occ_nodes_data_i(s_wait_branch + s_stack_counter + to_integer(unsigned(s_addr_ram_directions))) <= '1';
                                    s_occ_branches_data_i(s_wait_branch + s_stack_counter + to_integer(unsigned(s_addr_ram_directions))) <= '1';
                                    s_occ_nodes_wr <= '1';
                                    s_occ_branches_wr <= '1';
                                    if(s_ctrl_write_occ = '0') then
                                        s_ctrl_write_occ <= '1';
                                    else
                                        s_ctrl_set <= '0';
                                        s_ctrl_write_occ <= '0';
                                        s_occ_nodes_wr <= '0';
                                        s_occ_branches_wr <= '0';
                                        s_stack_counter <= s_stack_counter + 1;
                                        s_addr_ram_directions <= std_logic_vector(to_unsigned(to_integer(unsigned(s_addr_ram_directions)) + 1, 6));
                                    end if;
                                end if;
                            end if;
                        end if;
                    else
                        s_ctrl_write_stack <= '1';
                    end if;
                else
                    if(s_wait_branch > 0) then
                        s_stack_i <= "1111";
                        s_stack_addr_proc <= std_logic_vector(to_unsigned(to_integer(unsigned(s_stack_addr_proc)) + 1, 6));
                        s_stack_wr <= '1';
                        if(s_ctrl_write_wait = '0') then
                            s_ctrl_write_wait <= '1';
                        else
                            s_wait_branch <= s_wait_branch - 1;
                            s_stack_amount <= std_logic_vector(to_unsigned(to_integer(unsigned(s_stack_amount)) + 1, 6));
                            s_ctrl_write_wait <= '0';
                        end if;

                    else
                        s_stack_wr <= '0';
                        if(s_stack_counter > 0) then
                            if(s_ctrl_reset_dir_addr = '0') then
                                s_addr_ram_directions <= (others => '0');
                                s_ctrl_reset_dir_addr <= '1';
                            else
                                if(s_ctrl_write_wait = '0') then
                                    s_stack_wr <= '1';
                                    s_stack_i <= data_ram_directions;
                                    s_ctrl_write_wait <= '1';
                                else
                                    s_stack_wr <= '0';
                                    s_stack_counter <= s_stack_counter - 1;
                                    s_stack_amount <= std_logic_vector(to_unsigned(to_integer(unsigned(s_stack_amount)) + 1, 6));
                                    s_ctrl_write_wait <= '0';
                                    s_addr_ram_directions <= std_logic_vector(to_unsigned(to_integer(unsigned(s_addr_ram_directions)) + 1, 6));
                                    s_stack_addr_proc <= std_logic_vector(to_unsigned(to_integer(unsigned(s_stack_addr_proc)) + 1, 6));
                                end if;
                            end if;
                        else
                            s_stack_wr <= '0';
                            s_ready <= '1';
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process P0;

    addr_ram_directions <= s_addr_ram_directions;
    stack_amount <= s_stack_amount;
    stack_o <= s_stack_o;
    ready <= s_ready;
end architecture;