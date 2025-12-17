library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DataMem is
    port(
        clk        : in  std_logic;
        addr_in    : in  std_logic_vector(31 downto 0);
        mem_write  : in  std_logic;
        mem_read   : in  std_logic;
        write_data : in  std_logic_vector(31 downto 0);
        read_data  : out std_logic_vector(31 downto 0)
    );
end entity DataMem;

architecture RTL of DataMem is

    -- 256 bytes of data memory
    type mem_type is array (0 to 255) of std_logic_vector(7 downto 0);
    signal data_mem : mem_type := (others => (others => '0'));

begin

    -- ================= Write Operation (Synchronous) =================
    process(clk)
        variable byte_addr : integer;
    begin
        if rising_edge(clk) then
            if mem_write = '1' then
                byte_addr := to_integer(unsigned(addr_in(7 downto 0)));
                data_mem(byte_addr)     <= write_data(31 downto 24);
                data_mem(byte_addr + 1) <= write_data(23 downto 16);
                data_mem(byte_addr + 2) <= write_data(15 downto 8);
                data_mem(byte_addr + 3) <= write_data(7 downto 0);
            end if;
        end if;
    end process;

    -- ================= Read Operation (Combinational) =================
    read_data <= data_mem(to_integer(unsigned(addr_in(7 downto 0))))     &
             data_mem(to_integer(unsigned(addr_in(7 downto 0))) + 1) &
             data_mem(to_integer(unsigned(addr_in(7 downto 0))) + 2) &
             data_mem(to_integer(unsigned(addr_in(7 downto 0))) + 3)
             when mem_read = '1'
             else (others => '0');

end architecture RTL;
