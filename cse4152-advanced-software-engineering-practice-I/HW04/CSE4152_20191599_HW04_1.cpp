// #include "EnvGame.h"

// enum Side {
//     A, B
// };

// vector<int> AtoB;
// vector<int> BtoA;
// EnvGame* G;
// Side curSide = A;

// vector<int> getUnsolvedNode(int n){
//     vector<int> nodes;
//     int count = 0;
    
//     for(int i = 0; i < G->getNodeN(); i++){
//         if(curSide == A && AtoB[i] == -1){
//             nodes.push_back(i);
//             count++;
//         }
//         else if(curSide == B && BtoA[i] == -1){
//             nodes.push_back(i);
//             count++;
//         }
//         if(count == n) return nodes;
//     }

//     nodes.push_back(-1);
//     return nodes;
// }

// vector<int> findSet(){
//     vector<int> found;

//     for(int i = 0; i < G->getNodeN() - 1; i++){
//         for(int j = i+1; j < G->getNodeN(); j++){
//             if(G->checkConnectivity(i,j)){
//                 found.push_back(i);
//                 found.push_back(j);
//                 return found;
//             }
//         }
//     }

//     return found;
// }

// void connectAll(){
//     for(int i = 0; i < G->getNodeN() -1; i++){
//         G->connectWire(i, i+1);
//     }
// }

// void changeSide(){
//     curSide = curSide == A ? B : A;
//     G->goToOtherSide();
// }

// vector<int> solve(EnvGame &a){
//     G = &a;
//     int NodeNum = a.getNodeN();
//     AtoB.resize(NodeNum);
//     BtoA.resize(NodeNum);
//     for(int i = 0; i < NodeNum; i++)
//         AtoB[i] = BtoA[i] = -1;

//     int nodeCnt = 0;
//     while(nodeCnt < NodeNum){
//         // A
//         vector<int> needToFind = getUnsolvedNode(2);
//         printf("#1__ %d %d\n", needToFind[0], needToFind[1]);
//         G->connectWire(needToFind[0], needToFind[1]);
//         changeSide();
        

//         // B
//         G->cleanAllWires();
//         vector<int> check = findSet();
//         printf("#2__ %d %d\n", check[0], check[1]);
        
//         AtoB[needToFind[0]] = check[0];
//         AtoB[needToFind[1]] = check[1];
//         BtoA[check[0]] = needToFind[0];
//         BtoA[check[1]] = needToFind[1];

//         vector<int> oneMore = getUnsolvedNode(1);
//         if(oneMore[-1]) break;
//         G->connectWire(check[1], oneMore[0]);
//         changeSide();

//         // A
//         G->cleanAllWires();
//         vector<int> check2 = findSet();

//         bool is0 = false;
//         for(int i = 0; i < 2; i++){
//             if(needToFind[0] == check2[i]) is0 = true;
//         }
//         if(is0){
//             AtoB[needToFind[0]] = check[1];
//             AtoB[needToFind[1]] = check[0];
//             BtoA[check[0]] = needToFind[1];
//             BtoA[check[1]] = needToFind[0];
//         }
//         nodeCnt+=2;
//     }

//     return AtoB;
// }

#include "EnvGame.h"

using namespace std;

vector<int> solve(EnvGame &a){
    int n = a.getNodeN();
    vector<int> ans;
    vector<int> check;
    
    ans.resize(n);

    vector<vector<int>> map;

    map.resize(n);
    for(int j=0;j<n;j++) {map[j].clear();map[j].reserve(5);}

    int iter = 0;
    while(iter < n){
        int ni = (iter + 1) % n;

        a.cleanAllWires();
        a.connectWire(iter, ni);
        a.goToOtherSide();

        for (int j = 0; j < n; j++) {
            for (int k = j + 1; k < n; k++) {

                bool light = a.checkConnectivity(j, k);

                if (light) {
                    map[iter].push_back(j);
                    map[iter].push_back(k);
                    map[ni].push_back(j);
                    map[ni].push_back(k);
                }
            }
        }
        a.goToOtherSide();
        iter+=2;
    }

    iter = 1;
    while(iter < n){
        int ni = (iter + 1) % n;
        a.cleanAllWires();

        a.connectWire(iter, ni);

        a.goToOtherSide();

        for (int j = 0; j < n; j++) {
            for (int k = j + 1; k < n; k++) {

                bool light = a.checkConnectivity(j, k);

                if (light) {
                    if (find(map[iter].begin(), map[iter].end(), j) != map[iter].end())
                        ans[iter] = j;
                    if (find(map[iter].begin(), map[iter].end(), k) != map[iter].end())
                        ans[iter] = k;
                    if (find(map[ni].begin(), map[ni].end(), j) != map[ni].end())
                        ans[ni] = j;
                    if (find(map[ni].begin(), map[ni].end(), k) != map[ni].end())
                        ans[ni] = k;
                }
            }
        }
        a.goToOtherSide();
        iter+=2;
    }

    if (n % 2 != 0) {
        int i = 2;
        int odd = 0;
        a.cleanAllWires();
        a.connectWire(i, odd);
        a.goToOtherSide();

        for (int j = 0; j < n; j++) {
            for (int k = j + 1; k < n; k++) {

                bool light = a.checkConnectivity(j, k);

                if (light) {
                    if (find(map[i].begin(), map[i].end(), j) != map[i].end())
                        ans[i] = j;
                    if (find(map[i].begin(), map[i].end(), k) != map[i].end())
                        ans[i] = k;
                    if (find(map[odd].begin(), map[odd].end(), j) != map[odd].end())
                        ans[odd] = j;
                    if (find(map[odd].begin(), map[odd].end(), k) != map[odd].end())
                        ans[odd] = k;
                }
            }
        }
        a.goToOtherSide();
    }
    return ans;
}