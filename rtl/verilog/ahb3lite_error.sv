/////////////////////////////////////////////////////////////////////
//   ,------.                    ,--.                ,--.          //
//   |  .--. ' ,---.  ,--,--.    |  |    ,---. ,---. `--' ,---.    //
//   |  '--'.'| .-. |' ,-.  |    |  |   | .-. | .-. |,--.| .--'    //
//   |  |\  \ ' '-' '\ '-'  |    |  '--.' '-' ' '-' ||  |\ `--.    //
//   `--' '--' `---'  `--`--'    `-----' `---' `-   /`--' `---'    //
//                                             `---'               //
//   AHB3-Lite Error Module                                        //
//                                                                 //
/////////////////////////////////////////////////////////////////////
//                                                                 //
//             Copyright (C) 2021 ROA Logic BV                     //
//             www.roalogic.com                                    //
//                                                                 //
//   This source file may be used and distributed without          //
//   restriction provided that this copyright statement is not     //
//   removed from the file and that any derivative work contains   //
//   the original copyright notice and the associated disclaimer.  //
//                                                                 //
//      THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY        //
//   EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED     //
//   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS     //
//   FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR OR     //
//   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,  //
//   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT  //
//   NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;  //
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)      //
//   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN     //
//   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR  //
//   OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS          //
//   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  //
//                                                                 //
/////////////////////////////////////////////////////////////////////

// +FHDR -  Semiconductor Reuse Standard File Header Section  -------
// FILE NAME      : ahb3lite_error.sv
// DEPARTMENT     :
// AUTHOR         : rherveille
// AUTHOR'S EMAIL :
// ------------------------------------------------------------------
// RELEASE HISTORY
// VERSION DATE        AUTHOR      DESCRIPTION
// 1.0     2021-11-27  rherveille  initial release
// ------------------------------------------------------------------
// KEYWORDS : AMBA AHB AHB3-Lite Error
// ------------------------------------------------------------------
// PURPOSE  : Generate an AHB3Lite error transaction
// ------------------------------------------------------------------
// PARAMETERS
//  PARAM NAME        RANGE    DESCRIPTION              DEFAULT UNITS
//  HDATA_SIZE        1+       Data bus size            32      bits
// ------------------------------------------------------------------
// REUSE ISSUES 
//   Reset Strategy      : external asynchronous active low; HRESETn
//   Clock Domains       : HCLK, rising edge
//   Critical Timing     : 
//   Test Features       : na
//   Asynchronous I/F    : no
//   Scan Methodology    : na
//   Instantiations      : na
//   Synthesizable (y/n) : Yes
//   Other               :                                         
// -FHDR-------------------------------------------------------------


module ahb3lite_error
import ahb3lite_pkg::*;
#(
  parameter HDATA_SIZE = 32
)
(
  input  logic                   HRESETn,
         logic                   HCLK,

  input  logic                   HSEL,
  output logic [HDATA_SIZE -1:0] HRDATA,
  input  logic [HTRANS_SIZE-1:0] HTRANS,
  input  logic                   HREADY,
  output logic                   HREADYOUT,
  output logic                   HRESP
);


  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //

  enum logic {IDLE=1'b0, ERROR=1'b1} state;


  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  assign HRDATA = {HDATA_SIZE{1'b0}};

  
  //raise error when addressed
  always @(posedge HCLK, negedge HRESETn)
    if (!HRESETn)
    begin
        state     <= IDLE;
        HRESP     <= HRESP_OKAY;
        HREADYOUT <= 1'b1;
    end
    else
    case (state)
      IDLE :  if (HREADY && HSEL && HTRANS != HTRANS_IDLE)
              begin
                  //1st cycle error response
                  state     <= ERROR;
                  HRESP     <= HRESP_ERROR;
                  HREADYOUT <= 1'b0;
              end
              else
              begin
                  state     <= IDLE;
                  HRESP     <= HRESP_OKAY;
                  HREADYOUT <= 1'b1;
              end

      ERROR:  begin
                  //2nd cycle error response
                  state     <= IDLE;
                  HRESP     <= HRESP_ERROR;
                  HREADYOUT <= 1'b1;
	      end
    endcase

endmodule
