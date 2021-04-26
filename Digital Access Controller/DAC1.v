module DAC1(DOOR_OPEN_CLOSE,ALARM,use_code,ONE,THREE,FIVE,SEVEN,A,RESET);
                                
input use_code,ONE,THREE,FIVE,SEVEN,A,RESET;
output reg DOOR_OPEN_CLOSE,ALARM;
 
parameter start=4'b0000,day=4'b0001,use1111=4'b0010,use53A17=4'b0011,got1=4'b0100,got11=4'b0101,got111=4'b0110,
          got5=4'b0111,got53=4'b1000,got53A=4'b1001,got53A1=4'b1010,open_door=4'b1011,alarm=4'b1100,auto_off=4'b1101;

               //for cuurent state and next state of finite state machines
reg[3:0]current_state,next_state; 
initial
begin
current_state=4'b0000;
end

reg CLK;                                          //to distinguish between day and night if high then day otherwise night
initial 
CLK=0;                                            // 0 indicates night
always 
begin
#250 CLK=1'b1;                                     //suppose  night is of 8 hrs and scale is 250 = 8 hrs
#500 CLK=1'b0;                                    // suppose day is of 16 hrs and scale is 500 ns = 16 hrs               
end

reg clk;
initial
clk=0;
always
begin
#1 clk=~clk;
end

always@(posedge clk)
begin
current_state=next_state;
end




always@(use_code or ONE  or THREE or  FIVE or  SEVEN or  A or RESET or current_state or posedge CLK or negedge CLK or posedge clk )
begin
DOOR_OPEN_CLOSE=0;
ALARM=0;
case(current_state)
start:next_state=CLK?day:use53A17;            //if clock is low then it idicates night and it will give output only when sequence 53A17 is followed

day:next_state=use_code?use1111:use53A17;   

use1111:next_state=ONE?got1:alarm;

got1:next_state=ONE?got11:alarm;

got11:next_state=ONE?got111:alarm;

got111:next_state=ONE?open_door:alarm;

use53A17:next_state=FIVE?got5:alarm;

got5:next_state=THREE?got53:alarm;

got53:next_state=A?got53A:alarm;

got53A:next_state=ONE?got53A1:alarm;

got53A1:next_state=SEVEN?open_door:alarm;

open_door:begin
          DOOR_OPEN_CLOSE=1'b1;
          next_state=RESET?start:open_door;
          
          end
alarm:begin
      ALARM=1'b1;
      next_state=RESET?start:auto_off;
    
      end
auto_off:#5 next_state=start;                           //for 5 seconds delay after alarm
         
default:next_state=4'bxxxx;
endcase

end

endmodule
