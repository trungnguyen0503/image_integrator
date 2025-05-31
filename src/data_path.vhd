library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.project.all;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity data_path is
  generic (
    INDEX_WIDTH     : integer;
    ADDR_WIDTH      : integer;
    DATA_BYTE_WIDTH : integer
  );
  port (
    -- reset and clock
    rst          : in  std_logic;
    clk          : in  std_logic;
    -- user
    src_addr     : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
    dst_addr     : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
    src_col      : in  std_logic_vector(INDEX_WIDTH - 1 downto 0);
    src_row      : in  std_logic_vector(INDEX_WIDTH - 1 downto 0);
    size_error   : out std_logic;
    -- memory
    d_out        : in  std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
    addr         : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
    d_in         : out std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
    -- controller
    cnt_set      : in  std_logic;
    r_cnt_en     : in  std_logic;
    c_cnt_en     : in  std_logic;
    base_sel     : in  std_logic;
    r_sel        : in  std_logic_vector(1 downto 0);
    c_sel        : in  std_logic_vector(1 downto 0);
    alu_sel      : in  std_logic;
    d_sel        : in  std_logic;
    r_le_src_row : out std_logic;
    c_le_src_row : out std_logic
  );
end entity;

architecture rtl of data_path is
  signal r         : std_logic_vector(INDEX_WIDTH - 1 downto 0);
  signal c         : std_logic_vector(INDEX_WIDTH - 1 downto 0);
  signal r_prev    : std_logic_vector(INDEX_WIDTH - 1 downto 0);
  signal c_prev    : std_logic_vector(INDEX_WIDTH - 1 downto 0);
  signal base_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
  signal r_final   : std_logic_vector(INDEX_WIDTH - 1 downto 0);
  signal c_final   : std_logic_vector(INDEX_WIDTH - 1 downto 0);
  signal alu_out   : std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
  signal pixel_out : std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
begin
  size_error <= '1' when not (5 <= unsigned(src_col) and unsigned(src_col) <= 255 and 5 <= unsigned(src_row) and unsigned(src_row) <= 255) else '0';

  counter_r: counter
    generic map (DATA_BYTE_WIDTH => DATA_BYTE_WIDTH)
    port map (
      rst => rst,
      clk => clk,
      en  => r_cnt_en,
      set => cnt_set,
      d   => (1 => '1', others => '0'),
      q   => r
    );
  counter_c: counter
    generic map (DATA_BYTE_WIDTH => DATA_BYTE_WIDTH)
    port map (
      rst => rst,
      clk => clk,
      en  => c_cnt_en,
      set => cnt_set,
      d   => (1 => '1', others => '0'),
      q   => c
    );

  reg_r_prev: reg
    generic map (DATA_BYTE_WIDTH => DATA_BYTE_WIDTH)
    port map (
      rst => rst,
      clk => clk,
      en  => '1',
      d   => r,
      q   => r_prev
    );
  reg_c_prev: reg
    generic map (DATA_BYTE_WIDTH => DATA_BYTE_WIDTH)
    port map (
      rst => rst,
      clk => clk,
      en  => '1',
      d   => c,
      q   => c_prev
    );

  r_le_src_row <= '1' when unsigned(r) <= unsigned(src_row) else '0';
  c_le_src_row <= '1' when unsigned(c) <= unsigned(src_row) else '0';

  base_addr <= src_addr when base_sel = '0' else dst_addr;

  r_final <= (others => '0') when r_sel = "00" else
            r                when r_sel = "01" else
            r_prev;
  c_final <= (others => '0') when c_sel = "00" else
            c                when c_sel = "01" else
            c_prev;
  address_calc_block: address_calc
    generic map (
      INDEX_WIDTH     => INDEX_WIDTH,
      ADDR_WIDTH      => ADDR_WIDTH,
      DATA_BYTE_WIDTH => DATA_BYTE_WIDTH
    )
    port map (
      base_sel  => base_sel,
      r         => r_final,
      c         => c_final,
      col       => src_col,
      base_addr => base_addr,
      addr      => addr
    );

  alu_block: alu
    generic map (DATA_BYTE_WIDTH => DATA_BYTE_WIDTH)
    port map (
      sel => alu_sel,
      a   => pixel_out,
      b   => d_out,
      z   => alu_out
    );
  reg_pixel: reg
    generic map (DATA_BYTE_WIDTH => DATA_BYTE_WIDTH)
    port map (
      rst => rst,
      clk => clk,
      en  => '1',
      d   => alu_out,
      q   => pixel_out
    );
  d_in <= pixel_out when d_sel = '0' else (others => '0');

  -- TODO: Connection to memory interface
end architecture;
