/*
Maquina de estado exercicio 1. Diagrama de estado:

                          2,3
              +------------------------+
              |                        |
              |          +----+        |
              |   0,1,2,3|    |        |                0,1,2,3
              | +--------+ 3' |        |    +------------------------------+
              | |        |    |        |    |                              |
              | |        +--^-+        |    |                              |
              | |        2,3|          |    |                              |
+---+        ++-v+        +---+       +v--+ |     +---+       +---+      +-+-+
|   |0,1,2,3 |   |  0,1   |   | 0,1,2 |   <-+     |   |       |   |  0,1 |   |
| 0 +--------> 1 +--------> 2 <-------+ 3 |0,1,2,3| 4 |       | 5 +------> 6 |
|   |        |   |        |   |       |   <-------+   |       |   |  2,3 |   |
+-^-+        +---+        +---+       ++--+       +-^-+       +-^-+      +---+
  |            0          |   |        |            |           |
  +-----------------------+   +---------------------+           |
                                       |   1                    |
                                       |                        |
                                       +------------------------+
                                                    3




Matricula 92555: 10110100110001011 : 112212023                                                           
*/ 

module ff ( input data, input c, input r, output q);
reg q;
always @(posedge c or negedge r) 
begin
 if(r==1'b0)
  q <= 1'b0; 
 else 
  q <= data; 
end 
endmodule

module statem(clk, reset, a, s);
input clk, reset;
input [1:0] a;
output [2:0] s;
reg [2:0] state; 
parameter zero=3'b000, um=3'b001,dois=3'b010, tres=3'b011, quatro=3'b100, cinco=3'b101, seis = 3'b110, treslinha=3'b111;

assign s[2] = (state[2]&~state[1])|(state[2]&~state[0]);
assign s[1] = state[1];
assign s[0] = state[0];


always @(posedge clk or negedge reset)
     begin
          if (reset==0)
               state = zero;
          else
               case (state)
                    zero: state = um;
                    um: 
                      if(a==2'd0 | a==2'd1) state = dois;
                      else state = tres;
                    dois:
                      if(a==2'd0) state = zero;
                      else if (a==2'd2 | a==2'd3) state = treslinha;
                      else state = quatro;
                    tres:
                      if(a==2'd3) state = cinco;
                      else state = dois;
                    quatro: state = tres;
                    cinco: state = seis;
                    seis: state = tres;
                    treslinha: state = um;
               endcase
     end
endmodule


module statePorta(input clk, input res, input [1:0] a, output [2:0]s);
wire [2:0] e;
wire [2:0] p;
assign s[2] = (e[2]&~e[1])|(e[2]&~e[0]);
assign s[1] = e[1];
assign s[0] = e[0];
assign p[2] = (e[2]&~e[1]&e[0])|(~e[2]&e[1]&~e[0]&a[0])|(~e[2]&e[1]&~e[0]&a[1])|(~e[2]&e[1]&a[1]&a[0]);
assign p[1] =(~e[1]&e[0])|(e[2]&~e[0])|(e[1]&~e[0]&a[1])|(~e[2]&e[0]&~a[1]&a[0])|(~e[2]&e[0]&a[1]&~a[0]);
assign p[0] = (~e[1]&~e[0])|(~e[0]&a[1])|(e[2]&e[1])|(~e[2]&~e[1]&a[1])|(~e[2]&a[1]&a[0])|(e[1]&e[0]&~a[1]&~a[0]);
ff  e0(p[0],clk,res,e[0]);
ff  e1(p[1],clk,res,e[1]);
ff  e2(p[2],clk,res,e[2]);
endmodule 




module stateMem(input clk,input res, input [1:0] a, output [2:0] s);
reg [5:0] StateMachine [0:31];
initial
begin 
StateMachine[0] = 6'h8;  StateMachine[1] = 6'h8;
StateMachine[2] = 6'h8;  StateMachine[3] =  6'h8;
StateMachine[4] =  6'h11;  StateMachine[5] = 6'h11;
StateMachine[6] = 6'h19;  StateMachine[7] = 6'h19;
StateMachine[8] = 6'h2;  StateMachine[9] = 6'h22; 
StateMachine[10] = 6'h3A;  StateMachine[11] = 6'h3A;
StateMachine[12] = 6'hB;  StateMachine[13] =  6'h13;
StateMachine[14] =  6'h13;  StateMachine[15] = 6'h2B;
StateMachine[16] = 6'h1C;  StateMachine[17] = 6'h1C;
StateMachine[18] = 6'h1C;  StateMachine[19] = 6'h1C; 
StateMachine[20] = 6'h35;  StateMachine[21] = 6'h35;
StateMachine[22] = 6'h35;  StateMachine[23] =  6'h35;
StateMachine[24] =  6'h1E;  StateMachine[25] = 6'h1E;
StateMachine[26] = 6'h1E;  StateMachine[27] = 6'h1E;
StateMachine[28] =  6'hB;  StateMachine[29] = 6'hB;
StateMachine[30] = 6'hB;  StateMachine[31] = 6'hB;
end
wire [4:0] address; // 31 linhas , 5 bits de endereco
wire [5:0] dout;  // 6 bits de largura
assign address[0] = a[0];
assign address[1] = a[1];
assign dout = StateMachine[address];
assign s = dout[2:0];
ff st0(dout[3],clk,res,address[2]);
ff st1(dout[4],clk,res,address[3]);
ff st2(dout[5],clk,res,address[4]);
endmodule

module main;
reg c,res;
reg [1:0] a;
wire [2:0] s;
wire [2:0] s1;
wire [2:0] s2;
statem FSM(c,res,a,s);
statePorta FSM1(c,res,a,s1);
stateMem FSM2(c,res,a,s2);


initial
    c = 1'b0;
  always
    c= #(1) ~c;

// visualizar formas de onda usar gtkwave out.vcd
initial  begin
     $dumpfile ("out.vcd"); 
     $dumpvars; 
   end 

  initial 
    begin
     $monitor($time," c %b res %b a %b s %d s1 %d s2 %d",c,res,a,s,s1,s2);
      #1 res=0; a=2'd1;
      #1 res=1;
      #2 a = 2'd1;
      #2 a = 2'd1;
      #2 a = 2'd2;
      #2 a = 2'd2;
      #2 a = 2'd1;
      #2 a = 2'd2;
      #2 a = 2'd0;
      #2 a = 2'd2;
      #2 a = 2'd3;
      $finish ;
    end
endmodule