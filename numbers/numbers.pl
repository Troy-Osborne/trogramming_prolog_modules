/* Num_W/1 are the whole numbers from 0 to infinity.
If a variable is used as an argument it should act as a generator that produces 0,1,2,3,4 and so on ad infinitum.
If a ground state is entered as an argument it should simply opperate as a checker, a predicate to determine if the input is a valid non-negative integer.

Most functions will be designed to select one of two branches based on which arguments are ground values
depending on which args are variables it will forward the to either the generator function or check function.
On rare occasions it can be more legibly writen as a single function

In future additional functions may be added for implicitly casting arguments of similar types where appropriate.
example: 
	floating point numbers could be either truncated or rounded (consistently 1, not both) so num_W(1.5,W) would define W as 1 or 2 respectively,
	Negative numbers could have their sign inverted so num_W(-2,W) would define W as 2,
	or combinations of this so that num_W(-3.2,W) would become W
	
	These are simply examples if added type casting would likely be more explicit for clarity.
*/

num_W_gen(0).

num_W_gen(W):- 
	var(W),
	num_W_gen(Last),
	succ(Last,W).
	
num_W_check(W):- 
	integer(W),
	W>=0.

num_W(W):-
	var(W),
	num_W_gen(W).

num_W(W):-
	ground(W),
	num_W_check(W).

num_W(Limit,W):-
	num_W(0,Limit,W).


num_W(Min,Max,W) :- %Alias for between, generates a number in the inclusive-interval Min...Max or checks if W falls within the interval
	num_W(Min),
	num_W(Max),
	Max>=Min,
	between(Min,Max,W).
	
/*
Even and odd whole numbers.
Generate or check if arguments are even or odd.
Known issues: 
":- odd_W(_)" will endlessly recurse returning an endless list of true;
*/

num_N(N):-
	num_W(N),
	N>0.

even_W_check(W):-
	num_W_check(W),
	Wm is (W mod 2),
	Wm == 0.	

odd_W_check(W):-
	num_W_check(W),
	Wm is (W mod 2),
	Wm == 1.
	
even_W_gen(0).

even_W_gen(W):-
	even_W_gen(Last),
	W is Last + 2.

odd_W_gen(1).
	
odd_W_gen(W):-
	odd_W_gen(Last),
	W is Last + 2.
	
even_W(W):-
	var(W),
	even_W_gen(W).
	
even_W(W):-
	ground(W),
	even_W_check(W).
	
odd_W(W):-
	var(W),
	odd_W_gen(W).
	
odd_W(W):-
	ground(W),
	odd_W_check(W).
	
odd_W(Min,Max,W):-
	W >= 0,
	between(Min,Max,W),
	Wm is W mod 2,
	Wm == 1.
	
even_W(Min,Max,W):-
	W >= 0,
	between(Min,Max,W),
	Wm is W mod 2,
	Wm == 0.
	
/* End Of Whole and Natural numbers

*/

/*
Num_Z/2 isn't for end users, it's only a part of Num_Z/1, 
and as such it needn't work in all edge cases as long as it fully works within the context its used in of Num_Z/1.

Num_Z/1 represents the integers from negative infinity to infinity in the order 0,1,-1,2,-2, and so on ad infinitum.
If a ground state is entered as an argument it should simply determine if the input is an integer.

known issues:
--num_Z(0,Z). Can make Z=0 in 4 different ways, each list of num_Z(Z) therefore starts with 4 0s as solutions.

num_Z(W,Z). Begins by iterating through all the odd numbered values of W before doing the even numbers and therefore skips 0 and the negative numbers.
W = 1, Z = 1 ;
W = 3, Z = 2 ;
W = 5, Z = 3 ; and so on.
Luckily this problem doesn't occur for num_Z/1 which is the main version, so priority is to fix the 0s, and to ensure that num_Z(_) doesn't return an endless string of true;
*/	
	
num_W_Z_Mag(W,Magnitude):-
	Magnitude is W//2.

num_W_Z_Bijection(W,Z):-
	num_W(W),
	even_W(W),
	num_W_Z_Mag(W,Mag),
	Z is 0 - Mag.

num_W_Z_Bijection(W,Z):-
	num_W(W),
	odd_W(W),
	num_W_Z_Mag(W,Mag),
	Z is Mag + 1.	

num_Z_gen(Z):-  %% This generator is defined in a way where W is generated into a group value and then the bijection is called. Otherwise it would have to have through every even number before the first odd number
	num_W_gen(W),
	num_W_Z_Bijection(W,Z).

num_Z(Z):-
	ground(Z),
	integer(Z).

num_Z(Z):-
	var(Z),
	num_Z_gen(Z).

num_Z(Magnitude,Z):-
	NM is 0 - Magnitude,
	between(NM,Magnitude,Z).

num_Z(Low,High,Z):-
	between(Low,High,Z).

%%%% End Integers %%%%%	

%%%% Rationals  %%%%%%%

num_R_check(R):-
	rational(R).

%Turn a Numerator and Denominator into a Rational Number
num_R_ND(Numerator,Denominator,R):-
	R is Numerator / Denominator.
	
%Zig Zag back and forward across an infinite 2d matrix.

num_R_zig_zag(1,1,pos2d(1,0),next(pos2d([2|0]),pos2d([-1|1]))). %%Start Pos

num_R_zig_zag(X,Y,pos2d(1,0),Next):- %%If Travelling Right take a single step and then travel diagonal up-left
	NX is X + 1,
	NY is Y + 0,
	Next = next(pos2d(NX,NY),pos2d(-1 , 1)).
	
num_R_zig_zag(X,Y,pos2d(0,1),Next):- %%If Travelling Up take a single step and then travel diagonal down-right
	Nx is X + 0,
	Ny is Y + 1,
	Next = next(pos2d(Nx,Ny), pos2d(1 , -1)).
	
num_R_zig_zag(X,Y,pos2d(-1,1),Next):-  %% If travelling diagonal up-left and not on a wall continue in same direction.
	NX is X - 1,
	NY is Y + 1,
	NX > 1,
	Next = next(pos2d(NX,NY),pos2d( -1 , 1)).
	
num_R_zig_zag(X,Y,pos2d(-1,1),Next):-  %% If travelling diagonal up-left and next step is on a wall then next direction is down.
	NX is X - 1,
	NY is Y + 1,
	NX = 1,
	Next = next(pos2d(NX,NY),pos2d(0,1)).
	
num_R_zig_zag(X,Y,pos2d(1,-1),Next):-  %% If travelling diagonal down-right and next step is not top wall continue same direction.
	NX is X + 1,
	NY is Y - 1,
	NY > 1,
	Next = next(pos2d(NX,NY),pos2d(1,-1)).
	
num_R_zig_zag(X,Y,pos2d(1,-1),Next):-  %% If travelling diagonal down-right and next step is on a wall then next direction is right.
	NX is X + 1,
	NY is Y - 1,
	NY = 1,
	Next = next(pos2d(NX,NY),pos2d(1,0)).
	
%num_R_Properties(W,XPos,YPos,XDir,YDir).

num_R_Properties(0,1,1,1,0).

num_R_Properties(W,XPos,YPos,XDir,YDir):-
	num_N(W),
	W>0,
	succ(LW,W),
	num_R_Properties(LW,LX,LY,LXD,LYD),
	num_R_zig_zag(LX,LY,pos2d(LXD,LYD), next(pos2d(XPos,YPos),pos2d(XDir,YDir))).

num_Rpos_gen(R):-
	num_W(W),
	num_R_Properties(W,Numerator,Denominator,_,_),
	num_R_ND(Numerator,Denominator,R).
	
num_Rpos(R):-
	var(R),
	num_Rpos_gen(R).
	
num_Rpos(R):-
	ground(R),
	R>0,
	num_R_check(R).

num_W_Rpos_Bijection(W,R):-
	num_R_Properties(W,N,D,_,_),
	num_R_ND(N,D,R).
	
num_W_R_Bijection(0,0).

num_W_R_Bijection(W,R):-
	num_N(W),
	even_W(W),
	HW is (W - 1)//2,
	num_W_Rpos_Bijection(HW,NR),
	R is 0 - NR.
	
num_W_R_Bijection(W,R):-
	num_N(W),
	odd_W(W),
	HW is (W - 1)//2,
	num_W_Rpos_Bijection(HW,NR),
	R is NR.
	
num_R_gen(R):-
	num_W(W),
	num_W_R_Bijection(W,R).
	
num_R(R):-
	var(R),
	num_R_gen(R).
	
num_R(R):-
	ground(R),
	num_R_check(R).
	
%%%%% End Rationals %%%%%%
	
number_types([['whole number'|num_W],['natural number'|num_N],['integer number'|num_Z],['rational number'|num_R]]).
