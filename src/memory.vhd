library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity memory is
  generic (
    MEM_SIZE        : integer;
    ADDR_WIDTH      : integer;
    DATA_BYTE_WIDTH : integer
  );
  port (
    clk     : in std_logic;
    r_en    : in std_logic;
    w_en    : in std_logic;
    addr    : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
    d_in    : in std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
    d_out   : out std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0)
  );
end memory;

architecture rtl of memory is
  -- define new type for mem
  type mem_array is array (0 to MEM_SIZE) of std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
  signal mem : mem_array;

begin
  process(clk)
  begin
    if rising_edge(clk) then
      if w_en = '1' then
        mem(to_integer(unsigned(addr))) <= d_in;
      elsif r_en = '1' then
        d_out <= mem(to_integer(unsigned(addr)));
      end if;
    end if;
  end process;
end rtl;