library ieee;
use ieee.std_logic_1164.all;

entity rx_serial_hamming7x4_fd is
    port (
        clock : in std_logic;
        reset : in std_logic;
        -- zera : in std_logic;
        -- conta : in std_logic;
        -- carrega : in std_logic;
        desloca : in std_logic;
        dado_serial : in std_logic;
        zera_dados : in std_logic;
        dados : out std_logic_vector(3 downto 0);
        erro : out std_logic;
        fim : out std_logic
    );
end entity;

architecture arch of rx_serial_hamming7x4_fd is

    component deslocador_n
        generic (
            constant N : integer
        );
        port (
            clock : in std_logic;
            reset : in std_logic;
            carrega : in std_logic;
            desloca : in std_logic;
            entrada_serial : in std_logic;
            dados : in std_logic_vector(N - 1 downto 0);
            saida : out std_logic_vector(N - 1 downto 0)
        );
    end component;

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
    end component;

    signal s_saida : std_logic_vector(10 downto 0);
	 signal s_saida_tratada : std_logic_vector(3 downto 0);
	 signal s_erros : std_logic_vector(2 downto 0);
	 
	 signal s_paridade_calculada : std_logic;
	 signal s_erro_paridade : std_logic;
begin

    U1 : deslocador_n
    generic map(
        N => 11
    )
    port map(
        clock => clock,
        reset => reset,
        carrega => '0', -----------------------
        desloca => desloca,
        entrada_serial => dado_serial,
        dados => (others => '0'),
        saida => s_saida
    );

    U2 : contador_m
    generic map(
        M => 11,
        N => 4
    )
    port map(
        clock => clock,
        zera => zera_dados,
        conta => desloca,
        Q => open,
        fim => fim,
        meio => open
    );
	 
	 s_erros(0) <= (s_saida(2) xor s_saida(3) xor s_saida(4) xor s_saida(6));
	 s_erros(1) <= (s_saida(2) xor s_saida(3) xor s_saida(5) xor s_saida(7));
	 s_erros(2) <= (s_saida(2) xor s_saida(4) xor s_saida(5) xor s_saida(8));

	 s_paridade_calculada <= not (s_saida(2) xor s_saida(3) 
                             xor s_saida(4) xor s_saida(5) 
                             xor s_saida(6) xor s_saida(7) 
                             xor s_saida(8));
									 
	 s_erro_paridade <= (s_paridade_calculada xor s_saida(9));
	 
    dados(0) <= (not s_saida(2)) when ((s_erros = "111") and (s_erro_paridade = '1')) else
					 s_saida(2);
    dados(1) <= (not s_saida(3)) when ((s_erros = "110") and (s_erro_paridade = '1')) else
					 s_saida(3);
    dados(2) <= (not s_saida(4)) when ((s_erros = "101") and (s_erro_paridade = '1')) else
					 s_saida(4);
    dados(3) <= (not s_saida(5)) when ((s_erros = "011") and (s_erro_paridade = '1')) else
					 s_saida(5);
	 
    erro <=	'1' when (s_erro_paridade = '0' and ((s_erros = "111")
														   or (s_erros = "110")
											        	   or (s_erros = "101")
												         or (s_erros = "011"))) else
				'0';

end architecture;