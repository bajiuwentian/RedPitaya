////////////////////////////////////////////////////////////////////////////////
// Module: PWM (pulse width modulation)
// Author: Iztok Jeras <iztok.jeras@redpitaya.com>
// (c) Red Pitaya  (redpitaya.com)
////////////////////////////////////////////////////////////////////////////////

module pwm #(
  int unsigned CW = 8,  // counter width (resolution)
  int unsigned OW = 1   // output  width
)(
  // system signals
  input  logic                  clk ,  // clock
  input  logic                  rstn,  // reset (active low)
  input  logic                  cke ,  // clock enable (synchronous)
  // configuration
  input  logic                  ena,   // enable
  input  logic         [CW-1:0] rng,   // range
  // stream input
  input  logic [OW-1:0][CW-1:0] str_dat,  // data
  input  logic                  str_vld,  // valid (it is ignored for now
  output logic                  str_rdy,  // ready
  // PWM output
  output logic [OW-1:0]         pwm
);

// local signals
logic [CW-1:0] cnt;  // counter current value
logic [CW-1:0] nxt;  // counter next value

// counter current value
always_ff @(posedge clk)
if (~rstn)  cnt <= '0;
else begin
  if (ena)  cnt <= str_rdy ? '0 : nxt;
  else      cnt <= '0;
end

// counter next value
assign nxt = cnt + cke;

// counter cycle end
assign str_rdy = nxt == rng;

generate
for (genvar i=0; i<OW; i++) begin: out

logic [CW-1:0] dat;

// stream input data copy
always_ff @(posedge clk)
if (~rstn)            dat <= '0;
else begin
  if (ena & str_rdy)  dat <= str_dat[i];
end

// PWM output
always_ff @(posedge clk)
if (~rstn)                pwm[i] <= 1'b0;
else begin
  if (ena) begin
    if      (cnt == 0  )  pwm[i] <= |dat;
    else if (cnt == dat)  pwm[i] <= 1'b0;
  end else                pwm[i] <= 1'b0;
end

end: out
endgenerate

endmodule: pwm
