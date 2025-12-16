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
    signal reg_array : reg_array_t := (
        0  => x"00000000",  -- $zero
        1  => x"00000001",
        2  => x"00000002",
        3  => x"00000003",
        4  => x"00000004",
        5  => x"00000005",
        6  => x"00000006",
        7  => x"00000007",
        8  => x"00000008",
        9  => x"00000009",
        10 => x"0000000A",
        11 => x"0000000B",
        12 => x"0000000C",
        13 => x"0000000D",
        14 => x"0000000E",
        15 => x"0000000F",
        16 => x"00000010",
        17 => x"00000011",
        18 => x"00000012",
        19 => x"00000013",
        20 => x"00000014",
        21 => x"00000015",
        22 => x"00000016",
        23 => x"00000017",
        24 => x"00000018",
        25 => x"00000019",
        26 => x"0000001A",
        27 => x"0000001B",
        28 => x"0000001C",
        29 => x"0000001D",
        30 => x"0000001E",
        31 => x"0000001F"
    );

begin

    -- ================= Write Port (Synchronous) =================
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
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
