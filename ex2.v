/* 
Maquina de estado exercicio 2. Diagrama de estado:

+-----+       0,1     +-----+         0      +-----+    0,1    +-----+
|     +--------------->     +---------------->     +----------->     |
|  0  |               |  3  |                |  2  |           |  4  |
|     |               |     |                |     |           |     |
+--^--+               +--^--+                +--^--+           ++---++
   |                     |  |                   |               |   |
   |                     |  |     +-----+       |               |   |
   |                     |  |     |     |       |               |   |
   |                     |  +----->  5  +-------+               |   |
   |                     |    1   |     |   0,1                 |   |
   |                     |        +-----+                       |   |
   |                     |                                      |   |
   |                     |                   1                  |   |
   |                     +--------------------------------------+   |
   |                                                                |
   +----------------------------------------------------------------+
                                    0

Matricula 92555: 264613 : 0 => 2, 2 => 6, 3 => 4, 4 => 7, 5 => 1
*/


module ff0 ( input data, input c, input r, output q);
reg q;
always @(posedge c or negedge r) 
begin
 if(r==1'b0)
  q <= 1'b0; 
 else 
  q <= data; 
end 
endmodule

module ff1 ( input data, input c, input r, output q);
reg q;
always @(posedge c or negedge r) 
begin
 if(r==1'b0)
  q <= 1'b1; 
 else 
  q <= data; 
end 
endmodule

module statem(clk, reset, a, s);
input clk, reset;
input a;
output [2:0] s;
reg [2:0] state; 
parameter zero=3'b010, dois=3'b110, tres=3'b100, quatro=3'b111, cinco=3'b001;

assign s[2] = state[0];
assign s[1] = state[2]&~state[0];
assign s[0] =  ~state[1] ;

always @(posedge clk or negedge reset)
     begin
          if (reset==0)
               state = zero;
          else
               case (state)
                    zero: state = tres;
                    tres: 
                      if(a==1) state = cinco;
                      else state = dois;
                    dois: state= quatro;
                    quatro: 
                      if(a==1) state = tres;
                      else state = zero;
                    cinco: state = dois;
               endcase
     end
endmodule


module statePorta(input clk, input res, input a, output [2:0]s);
wire [2:0] e;
wire [2:0] p;
assign s[2] = e[0]; // 0 operadores
assign s[1] = e[2]&~e[0]; //2 operadores
assign s[0] =  ~e[1]; // 1 operador
assign p[2] = ~e[2]|(~e[0]&~a)|(e[1]&a); //7 operadores
assign p[1] = (~e[2]&~e[1])|(e[2]&~a)|(e[2]&e[1]&~e[0]); //9 operadores
assign p[0] = (e[2]&~e[0]&a)|(e[2]&e[1]&~e[0]); //6 operadores
ff0  e0(p[0],clk,res,e[0]); // total = 25 operadores
ff1  e1(p[1],clk,res,e[1]);
ff0  e2(p[2],clk,res,e[2]);
endmodule 




module stateMem(input clk,input res, input a, output [2:0] s);
reg [5:0] StateMachine [0:15];
initial
begin 
StateMachine[2] = 6'h35;  StateMachine[3] =  6'h35;
StateMachine[4] =  6'h20;  StateMachine[5] = 6'h20;
StateMachine[8] = 6'h33;  StateMachine[9] = 6'hB; 
StateMachine[12] = 6'h3A;  StateMachine[13] =  6'h3A;
StateMachine[14] =  6'h14;  StateMachine[15] = 6'h24;
end
wire [3:0] address; // 16 linhas , 4 bits de endereco
wire [5:0] dout;  // 6 bits de largura
assign address[0] = a;
assign dout = StateMachine[address];
assign s = dout[2:0];
ff0 st0(dout[3],clk,res,address[1]);
ff1 st1(dout[4],clk,res,address[2]);
ff0 st2(dout[5],clk,res,address[3]);
endmodule

module main;
reg c,res;
reg a;
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
      #1 res=0; a=0;
      #1 res=1;
      #18 a = 1;
      $finish ;
    end
endmodule