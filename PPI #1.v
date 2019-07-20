module chipset_8255(a,b,cu,cl,data_wire,reset,address,write,read,chip_select);
inout [7:0] a;
inout [7:0] b; 
inout [3:0] cu;
inout [3:0] cl;
input reset,chip_select,write,read;
input [1:0] address;
reg[7:0] porta;
reg[7:0] portb;
reg[7:0] portc; 
reg[7:0] control_reg;
reg[7:0] data;
inout[7:0] data_wire;
assign a = porta;
assign b = portb;
assign cu = portc[7:4];
assign cl = portc[3:0];
assign data_wire = data;
always@(reset,write,read,chip_select,address,control_reg)
begin
if(reset==1)
begin
control_reg<=8'b10011011;
end
else if(reset==0)
begin
if(control_reg[7]==0)//BSR mode check which bit to be set or set
begin
case(control_reg[3:0])
 4'b0000:portc[0]<=0;
 4'b0001:portc[0]<=1;

 4'b0010:portc[1]<=0;
 4'b0011:portc[1]<=1;

 4'b0100:portc[2]<=0;
 4'b0101:portc[2]<=1;

 4'b0110:portc[3]<=0;
 4'b0111:portc[3]<=1;

 4'b1000:portc[4]<=0;
 4'b1001:portc[4]<=1;

 4'b1010:portc[5]<=0;
 4'b1011:portc[5]<=1;

 4'b0110:portc[6]<=0;
 4'b0111:portc[6]<=1;

 4'b1110:portc[7]<=0;
 4'b1111:portc[7]<=1;
endcase
end
else if(control_reg[7]==1)    // I/O mode0
begin
if(chip_select==0) //enable data communication
begin
if(read == 0 && write==1 &&((control_reg[1]==1'b0)||(control_reg[4]==1'b0)||(control_reg[0]==1'b0)||(control_reg[3]==1'b0)) )// check if read and output
begin
if(address==2'b00)
data<=porta;
else if(address==2'b01)
data<=portb;
else if(address==2'b10)
data<=portc;
else
data<=8'bzzz_zzzz;
end
else if(write == 0 && read == 1 &&((control_reg[1]==1'b1)||(control_reg[4]==1'b1)||(control_reg[0]==1'b1)||(control_reg[3]==1'b1)))//check if input and write
begin
if(address==2'b00)
porta<=data;
else if(address==2'b01)
portb<=data;
else if(address==2'b10)
portc<=data;
else if(address==2'b11)
control_reg<=data;
else
data<=8'bzzzz_zzzz;
end
else
begin
data<=8'bzzzz_zzzz;
end
end
else
begin
data<=8'bzzzz_zzzz;
end
end
else
begin
data<=8'bzzzz_zzzz;
end
end
else
data<=8'bzzzz_zzzz;
end
endmodule







module tb();
reg [7:0] porta; //Define PORTA as i/o port 
wire [7:0] a;

reg [7:0]  portc; //Define PORTC as i/o port 
wire [7:4] cu;
wire[3:0]cl;

reg [7:0] portb; //Define PORTB as i/o port 
wire [7:0] b;

wire [7:0] data_wire; //Define Communication Databus buffer between 8255 AND processor as i/o port
reg [7:0] d;

//Define Control Logic
reg read,write,chip_select,reset; 
reg [1:0] address;

wire [7:0] control_reg;
//assign data_wire =(outnotinD)?8'bzzzz_zzzz:d;
assign control_reg =(address==2'b11 && read == 1 && write == 0 &&  reset == 0 && chip_select==0)?d:(reset==1)?8'b1001_1011:control_reg;
//assign data_wire =(read == 1 && write == 0 && reset==0 &&address==2'b11)?d:8'bzzzz_zzzz;

assign data_wire =(read == 1 && write == 0 &&chip_select==0 )?d:8'bzzzz_zzzz;

//assign a =((control_reg[7]==1 && control_reg[4]==1 && chip_select==0 && reset==0))?d:(control_reg[7]==0) ? d : d;
assign a = 5;
assign b =5;//((control_reg[7]==1 && control_reg[2]==0 && control_reg[1]==1)||reset)?portb:(control_reg[7]==0) ? b :8'bzzzz_zzzz;
assign cu =((control_reg[7:5]==3'b100 && control_reg[3]==1)||reset)?portc[7:4]:4'bzzzz;
assign cl =((control_reg[7]==1 && control_reg[2]==0 && control_reg[0]==1)||reset)?portc[3:0]:4'bzzzz;
/*
assign control_reg =(address==2'b11 && read == 1 && write == 0 &&  reset == 0)?data_wire:(reset==1)?8'b1001_1011:control_reg;
assign data_wire =(outnotinD)?8'bzzzz_zzzz:d;
assign a =(outnotinA && control_reg[7:4]==4'b1001 && write==0 && read==1)?porta:8'hzz;
assign b =((control_reg[7]==1 && control_reg[2]==0 && control_reg[1]==1)||reset)?portb:(control_reg[7]==0) ? b :8'bzzzz_zzzz;
assign cu =((control_reg[7:5]==3'b100 && control_reg[3]==1)||reset)?portc[7:4]:4'bzzzz;
assign cl =((control_reg[7]==1 && control_reg[2]==0 && control_reg[0]==1)||reset)?portc[3:0]:4'bzzzz;
*/
chipset_8255 s1(a,b,cu,cl,data_wire,reset,address,write,read,chip_select);
initial
begin

$monitor($time ,,, " a: %b .b: %b .cl: %b .cu:%b .data_wire: %b .read: %b .write: %b .address: %b .reset: %b .chip_select: %b .control_reg: %b",a,b,cl,cu,data_wire,read,write,address,reset,chip_select,control_reg);

chip_select=0;
reset=1;

#5
reset=0;
address=2'b11;
write=0;
read=1;
d=8'b1001_0000;
#5
write=0;
read=1;
address=2'b00;
d=8'b1001_0000;

#5
address=2'b01;
d=8'b0000_0000;
/*
#5
address=2'b10;
d=8'b0000_0000;

#15
address=2'b11;
d=8'b1001_0000;
write=0;
read=1;
#5
address=2'b00;
write=1;
read=0;
porta=8'b0000_1111;

#15
address=2'b11;
d=8'b1001_0010;
write=0;
read=1;
#5
address=2'b00;
write=1;
read=0;
portb=8'b1111_1111;
porta=8'b0110_1111;

//.............BSR............
#15
address=2'b11;
read=1;
write=0;
d=8'b0xxx_0001;
#5
d=8'b0xxx_0111;
#5
d=8'b0xxx_1011;
#5
d=8'b0xxx_1101;

#15
read=1;
write=0;
d=8'b0xxx_0110;
#5
d=8'b0xxx_1010;

//----- upper only nput
#15
address=2'b11;
d=8'b1000_1000;
write=0;
read=1;*/
end 

endmodule

