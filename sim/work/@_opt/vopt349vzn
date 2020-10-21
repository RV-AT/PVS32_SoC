library verilog;
use verilog.vl_types.all;
entity UART_Rx is
    generic(
        Idle            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        wait16          : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        CLR             : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        Rb              : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0);
        Stop            : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi1)
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        en              : in     vl_logic;
        ChkEn           : in     vl_logic;
        RxD             : in     vl_logic;
        dat             : out    vl_logic_vector(7 downto 0);
        ERR             : out    vl_logic;
        INT             : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Idle : constant is 1;
    attribute mti_svvh_generic_type of wait16 : constant is 1;
    attribute mti_svvh_generic_type of CLR : constant is 1;
    attribute mti_svvh_generic_type of Rb : constant is 1;
    attribute mti_svvh_generic_type of Stop : constant is 1;
end UART_Rx;
