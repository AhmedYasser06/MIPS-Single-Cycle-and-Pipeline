library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RegFile is
    port (	
        clk       : in  std_logic;
        reset     : in  std_logic;
        reg_write : in  std_logic;
        wr_addr   : in  std_logic_vector(4 downto 0);
        wr_data   : in  std_logic_vector(31 downto 0);
        rd_addr1  : in  std_logic_vector(4 downto 0);
        rd_addr2  : in  std_logic_vector(4 downto 0);
        rd_data1  : out std_logic_vector(31 downto 0);
        rd_data2  : out std_logic_vector(31 downto 0)
    ); 
end entity RegFile;

architecture RTL of RegFile is

    type reg_array_t is array (0 to 31) of std_logic_vector(31 downto 0);

    -- Register file storage
    signal reg_array : reg_array_t := (others => (others => '0'));

begin

    -- ================= Write Port (Synchronous) =================
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- Keep register 0 as zero, reset all others to zero
                reg_array <= (others => (others => '0'));
                
            elsif reg_write = '1' then
                if wr_addr /= "00000" then       -- $zero is read-only
                    reg_array(to_integer(unsigned(wr_addr))) <= wr_data;
                end if;
            end if;
        end if;
    end process;

    -- ================= Read Ports (Asynchronous) =================
    rd_data1 <= reg_array(to_integer(unsigned(rd_addr1)));
    rd_data2 <= reg_array(to_integer(unsigned(rd_addr2)));

end architecture RTL;
