//Reused from lab 2 submission
module SevenSegEncoder(input [3:0] m, output[6:0] n);

	//a is the most significant bit, d is the least significant bit
	wire a,b,c,d;
	assign a = m[3];
	assign b = m[2];
	assign c = m[1];
	assign d = m[0];

	//n[0]-n[6] = LED0-LED6, respectively
	assign n[0] = (~a&~b&~c&d)|(~a&b&~c&~d)|(a&~b&c&d)|(a&b&~c&d);
	assign n[1] = (~a&b&~c&d)|(~a&b&c&~d)|(a&~b&c&d)|(a&b&~c&~d)|(a&b&c&~d)|(a&b&c&d);
	assign n[2] = (~a&~b&c&~d)|(a&b&~c&~d)|(a&b&c&~d)|(a&b&c&d);
	assign n[3] = (~a&~b&~c&d)|(~a&b&~c&~d)|(~a&b&c&d)|(a&~b&c&~d)|(a&b&c&d);
	assign n[4] = (~a&~b&~c&d)|(~a&~b&c&d)|(~a&b&~c&~d)|(~a&b&~c&d)|(~a&b&c&d)|(a&~b&~c&d);
	assign n[5] = (~a&~b&~c&d)|(~a&~b&c&~d)|(~a&~b&c&d)|(~a&b&c&d)|(a&b&~c&d);

	//algebraic simplicication
	//Unsimplified: (~a&~b&~c&~d)|(~a&~b&~c&d)|(~a&b&c&d)|(a&b&~c&~d)
	//a similar term (~a&~b&~c) is present in first two terms. we use the distributive property to extract the common term
	//--> (~a&~b&~c)(~d|d)|(~a&b&c&d)|(a&b&~c&~d)
	//we use theorem 8 to convert (~d|d) to 1
	//we use the theorem that says x&1 = x to remove the (1)
	//--> (~a&~b&~c)(1)|(~a&b&c&d)|(a&b&~c&~d)
	//Simplified: (~a&~b&~c)|(~a&b&c&d)|(a&b&~c&~d)
	assign n[6] = (~a&~b&~c)|(~a&b&c&d)|(a&b&~c&~d);

endmodule

