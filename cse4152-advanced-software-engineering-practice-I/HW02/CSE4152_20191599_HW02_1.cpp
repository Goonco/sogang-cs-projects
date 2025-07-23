#include <iostream>

using namespace std;
typedef long long ll;

int moveY[5] = {-1, 0, 1, 1, 1};
int moveX[5] = {-1, -1, -1, 0, 1}; 

int main()
{
    ios::sync_with_stdio(false);
    cin.tie(NULL);

    int N,K;
    cin >> N;

    int** board = new int*[N];
    for(int i = 0; i < N; i++){
        board[i] = new int[N];
        for(int j = 0; j < N; j++)
            cin >> board[i][j];
    }

    cin >> K;

    int curY = 0;
    int curX = N-1;    
    int i, tmpY, tmpX;
    
    // Matrix에 없을 경우?
    while(true){
        if(board[curY][curX] == K) break;

        bool notChanged = true;
        for(i = 0; i < 5; i++){
            tmpY = curY + moveY[i];
            tmpX = curX + moveX[i];

            if(tmpY < 0 || tmpY >= N || tmpX < 0 || tmpX >= N) continue;
            if(K <= board[tmpY][tmpX]){
                curY = tmpY;
                curX = tmpX;
                notChanged = false;
                break;
            }         
        }

        if(notChanged){
            if(tmpY < 0 || tmpY >= N || tmpX < 0 || tmpX >= N) // 하나 밑으로 가기
                curY += 1;
            else { // 오른쪽 아래로 가기
                curY = tmpY;
                curX = tmpX;
            }
        }   
    }

    cout << curY + 1 << " " << curX + 1 << "\n";
    return 0;
}