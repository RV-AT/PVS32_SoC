library verilog;
use verilog.vl_types.all;
entity UART_Tx is
    generic(
        Idle            : vl_logic_vector(0 to 1) := (Hi0, Hi0);
        Start           : vl_logic_vector(0 to 1) := (Hi0, Hi1);
        Tb              : vl_logic_vector(0 to 1) := (Hi1, Hi0);
        Stop            : vl_logic_vector(0 to 1) := (Hi1, Hi1)
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        en              : in     vl_logic;
        ChkEn           : in     vl_logic;
        send            : in     vl_logic;
        dat             : in     vl_logic_vector(7 downto 0);
        busy            : out    vl_logic;
        TINT            : out    vl_logic;
        TxD             : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Idle : constant is 1;
    attribute mti_svvh_generic_type of Start : constant is 1;
    attribute mti_svvh_generic_type of Tb : constant is 1;
    attribute mti_svvh_generic_type of Stop : constant is 1;
end UART_Tx;
