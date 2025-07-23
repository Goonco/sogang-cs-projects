#include "solve.hpp"
#include <stack>

using namespace std;

int solve(Party *party){
	// TODO
	int n = party->getN();
	stack<int> st;
	for(int i = 0; i < n; i++) st.push(i);

	int X, Y;
	while(st.size() != 1){
		X = st.top();
		st.pop();
		Y= st.top();
		st.pop();

		if(party->askAToKnowB(X,Y)) st.push(Y);
		else st.push(X);
	}

	int candidate = st.top();
	for(int i = 0; i < n; i++){
		if(i == candidate) continue;
		if(party->askAToKnowB(i, candidate) && !party->askAToKnowB(candidate, i)) continue;
		else return -1;
	}

	return candidate;
}