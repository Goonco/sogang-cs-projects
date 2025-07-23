#include <iostream>
#include <stack>

using namespace std;
typedef long long ll;

//  _ 6 _ 5 _
//  7 _ 1 _ 12
//  _ 2 S 4 _
//  8 _ 3 _ 11
//  _ 9 _ 10 _

struct Coord {
    int i;
    int j;
    int lv ;
};

int width;
int height;
int K;
int moveI[12] = {1, 0, -1, 0, 2, 2, 1, -1, -2, -2, -1, 1};
int moveJ[12] = {0, -1, 0, 1, 1, -1, -2, -2, -1, 1, 2, 2};
int **board;

ll countPossiblePath(int startI,int startJ, int endI,int endJ){
    ll pathN = 0;

    stack<Coord> st;
    Coord init = {startI, startJ, 0};
    st.push(init);

    Coord coord;
    while(!st.empty()){
        coord = st.top();
        st.pop();

        if(coord.lv > K) continue;
        if(coord.i == endI && coord.j == endJ){
            if(coord.lv == K) pathN++;
            continue;
        }

        for(int dir = 0; dir < 12; dir++){
            int movedI = coord.i + moveI[dir];
            int movedJ = coord.j + moveJ[dir];

            if(movedI < 0 || movedI >= height) continue;
            if(movedJ < 0 || movedJ >= width) continue;
            if(board[movedI][movedJ] == 1) continue;

            Coord newMove = {movedI, movedJ, coord.lv + 1};
            st.push(newMove);
        }
    }

    return pathN;
}

int main()
{
    ios::sync_with_stdio(false);
    cin.tie(NULL);

    cin >> height >> width >> K;
    int startI, startJ, endI, endJ;

    board = new int*[height];

    char input;
    for(int i = 0; i < height; i++){
        board[i] = new int[width];

        for(int j = 0; j < width; j++){
            cin >> input;
            if(input == 'S') {
                startI = i;
                startJ = j;
            }
            else if(input == 'E') {
                endI = i;
                endJ = j;
            }

            if(input == '1') board[i][j] = 1;
            else board[i][j] = 0;
        }
    }

    int pathN = countPossiblePath(startI, startJ, endI, endJ);
    cout << "Possible Path : " << pathN << "\n";
    return 1;
}