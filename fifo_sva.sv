module fifo_sva #(
    parameter int DEPTH = 8,
    parameter DATA_WIDTH = 8
    )(
    input clk,
    input rst_n,
    input wr_en,
    input rd_en,
    input full,
    input empty,
    input [$clog2(DEPTH+1)-1:0] count,
    input [DATA_WIDTH-1:0] dout
    );

    // SVA SECTION

    default clocking cb @(posedge clk);
    endclocking

    default disable iff (!rst_n);

    property count_equal_DEPTH_when_full;
        full |-> count == DEPTH;
    endproperty

    property count_equal_0_when_empty;
        empty |-> count == 0;
    endproperty

    property simultanious_full_empty;
        !(full && empty);
    endproperty

    property count_write_only;
        (wr_en && !rd_en && !full) |-> ##1 count == $past(count) + 1;
    endproperty

    property count_read_only;
        (!wr_en && rd_en && !empty) |-> ##1 count == $past(count) - 1;
    endproperty

    property count_simultanious_read_write;
        (wr_en && rd_en && !full && !empty) |-> ##1 count == $past(count);
    endproperty

    property idle_op_then_stable_count;
        !(wr_en || rd_en) |-> ##1 $stable(count);
    endproperty

    assert property (count_equal_DEPTH_when_full)
    $timeformat(-9, 0, " ns");
    else $error("Time = %0t\tASSERTION FAILED count != DEPTH when full", $time);

    assert property (count_equal_0_when_empty)
    else $error("Time = %0t\tASSERTION FAILED count != 0 when empty", $time);

    assert property (simultanious_full_empty)
    else $error("Time = %0t\tASSERTION FAILED empty and full flags raised simultaniously", $time);

    assert property (count_write_only)
    else $error("Time = %0t\tASSERTION FAILED counting when write only", $time);

    assert property (count_read_only)
    else $error("Time = %0t\tASSERTION FAILED counting when read only", $time);

    assert property (count_simultanious_read_write)
    else $error("Time = %0t\tASSERTION FAILED counting when simultanious read write", $time);

    assert property (idle_op_then_stable_count)
    else $error("Time = %0t\tASSERTION FAILED operation and changed count", $time);

endmodule