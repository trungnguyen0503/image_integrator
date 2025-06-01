library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.project.all;

entity memory_tb is
end memory_tb;

architecture rtl of memory_tb is
  constant MEM_SIZE         : integer := 1024;
  constant ADDR_WIDTH       : integer := 32;
  constant DATA_BYTE_WIDTH  : integer := 1;
  constant CLK_PERIOD       : time := 10 ns;

  signal clk     : std_logic := '1';
  signal r_en    : std_logic;
  signal w_en    : std_logic;
  signal addr    : std_logic_vector(ADDR_WIDTH - 1 downto 0);
  signal d_in    : std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
  signal d_out   : std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
begin
  dut : memory 
    generic map(
      MEM_SIZE => MEM_SIZE,
      ADDR_WIDTH => ADDR_WIDTH,
      DATA_BYTE_WIDTH => DATA_BYTE_WIDTH
    )
    port map (
      clk => clk,
      r_en => r_en,
      w_en => w_en,
      addr => addr,
      d_in => d_in,
      d_out => d_out
    );

  clk <=  not clk after CLK_PERIOD/2;
  process
  begin
    -- TC 1: Write data to memory
    wait for CLK_PERIOD;
    w_en <= '1';
    r_en <= '0';
    
    wait for CLK_PERIOD;
    addr <= std_logic_vector(to_unsigned(20, ADDR_WIDTH));
    d_in <= (0 => '1', others => '0');
    
    wait for CLK_PERIOD*3;
    -- TC 2: Read data from memory
    w_en <= '0';
    r_en <= '1';
    addr <= std_logic_vector(to_unsigned(20, ADDR_WIDTH));
    wait;
  end process; 

end rtl;