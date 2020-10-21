library verilog;
use verilog.vl_types.all;
entity BaudGen is
    port(
        clkdivL         : in     vl_logic_vector(15 downto 0);
        en              : in     vl_logic;
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        BaudOut         : out    vl_logic;
        BaudOutL        : out    vl_logic
    );
end BaudGen;
