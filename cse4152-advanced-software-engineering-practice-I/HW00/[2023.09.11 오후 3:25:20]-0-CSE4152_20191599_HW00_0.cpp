#include <iostream>

using namespace std;
typedef long long ll;

// !주의!
// Test Case 10000개 이상
// 모두 음수인 경우 0
// 입력값 정수겠지?

int main()
{
    ios::sync_with_stdio(false);
    cin.tie(NULL);

    int testN;
    cin >> testN;

    int MSS = 0;
    int sum = 0;

    int num;
    for(int i = 0; i < testN; i++) {
        cin >> num;
        sum += num;
        if(sum < 0) sum = 0;
        if(MSS < sum) MSS = sum;
    }

    cout << MSS << "\n";
    return MSS;
}