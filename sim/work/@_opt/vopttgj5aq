library verilog;
use verilog.vl_types.all;
entity UART_IP is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        mode            : in     vl_logic_vector(7 downto 0);
        DIV             : in     vl_logic_vector(15 downto 0);
        send            : in     vl_logic;
        TxD             : out    vl_logic;
        RxD             : in     vl_logic;
        TxReg           : in     vl_logic_vector(7 downto 0);
        RxReg           : out    vl_logic_vector(7 downto 0);
        TxBusy          : out    vl_logic;
        RxError         : out    vl_logic;
        INT             : out    vl_logic;
        ACK             : out    vl_logic
    );
end UART_IP;
