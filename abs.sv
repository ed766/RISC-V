//Absolute value function
function [63:0] abs;
    input [63:0] data;
    begin
        if (data < 0)  // Assuming a 32-bit signed integer, check the sign bit
            abs = -data;
        else
            abs = data;
    end
endfunction
