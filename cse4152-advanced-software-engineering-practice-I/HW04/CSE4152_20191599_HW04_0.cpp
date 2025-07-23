#include <iostream>
#include <stack>
#include <queue>

using namespace std;

/*
    Test Case
    3
    5 1 2 3 4 5
    4 3 2 1 4
    5 3 2 5 4 1
*/

bool checkPossibleCase(queue<int> storage, int trainLen){
    int target = 1, next;
    
    stack<int> inter;
    while(target < trainLen){
        if(inter.empty()){ 
            inter.push(storage.front());
            storage.pop();
        }
        else if(inter.top() == target){
            inter.pop();
            target++;
        }
        else {
            if(inter.top() < storage.front()) return false;
            inter.push(storage.front());
            storage.pop();
        }
    }

    return true;
}

int main() {
	ios_base::sync_with_stdio(false);
	cin.tie(NULL);

    int TEST_CASE, trainLen, train;
    cin >> TEST_CASE;

    for(int i = 0; i < TEST_CASE; i++){
        cin >> trainLen;

        queue<int> qu;
        for(int j = 0; j < trainLen; j++) {
            cin >> train;
            qu.push(train);
        }

        if(checkPossibleCase(qu, trainLen)) cout << "POSSIBLE\n";
        else cout << "IMPOSSIBLE\n";
    }

    return 0;
}