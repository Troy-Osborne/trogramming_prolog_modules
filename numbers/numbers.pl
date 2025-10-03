/* Num_W/1 are the whole numbers from 0 to infinity.
If a variable is used as an argument it should act as a generator that produces 0,1,2,3,4 and so on ad infinitum.
If a ground state is entered as an argument it should simply opperate as a checker, a predicate to determine if the input is a valid non-negative integer.

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

num_W(Min,Max,W) :- %Alias for between, generates a number in the inclusive-interval Min...Max or checks if W falls within the interval
	between(Min,Max,W).
	
/*
Even and odd whole numbers.
Generate or check if arguments are even or odd.
Known issues: 
":- odd_W(_)" will endlessly recurse returning an endless list of true;
*/

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
	
/*Natural numbers

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
	
num_Z(W,Z):-
	var(Z),
	num_W(W),
	odd_W(W),
	Z is ((W + 1) / 2).

num_Z(W,Z):-
	var(Z),
	num_W(W),
	even_W(W),
	Z is (0 - (W / 2)).

num_Z(Z):-
	not(var(Z)),
	integer(Z).

num_Z(Z):-
	var(Z),
	num_W(W),
	num_Z(W,Z).
