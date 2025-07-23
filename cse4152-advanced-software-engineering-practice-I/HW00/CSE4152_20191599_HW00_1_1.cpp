#include <iostream>
#include <stack>
#include <utility>
#include <vector>
#include <algorithm>

using namespace std;

struct Coins {
    int sum;
    int index;
    vector<int> used;
    int nCoins;
};

int Type, target;
vector<pair<int, int> > coins;
vector<Coins> saver;

bool compareCoins(const Coins &a, const Coins &b){
    if(a.nCoins == b.nCoins){
        for(int i = 0; i < a.used.size(); i++){
            if(a.used[i] == b.used[i]) continue;
            return a.used[i] > b.used[i];
        }
    }
    else
    return a.nCoins < b.nCoins;
}

int printCombinations(){
    int possible = 0;

    stack<Coins> st;
    vector<int> v;
    Coins init = {0,0,v,0};
    st.push(init);
    
    Coins poped;
    while(!st.empty()){
        poped = st.top();
        st.pop();

        if(poped.sum == target){
            saver.push_back(poped);
            possible++;
            continue;
        }
        if(poped.index == Type) continue;
        
        for(int i = 0; i <= coins[poped.index].second; i++){
            int total = poped.sum + coins[poped.index].first * i;
            if(total > target) break;

            vector<int> newUsed(poped.used);
            newUsed.push_back(i);
            Coins newCoin = {total, poped.index+1, newUsed, poped.nCoins + i};
            st.push(newCoin);
        }
    }

    return possible;
}

int main()
{
    ios::sync_with_stdio(false);
    cin.tie(NULL);

    cin >> Type >> target;

    int coin, num;
    for(int i = 0; i < Type; i++){
        cin >> coin >> num;
        coins.push_back(make_pair(coin, num));
    }

    int ans = printCombinations();
    sort(saver.begin(), saver.end(), compareCoins);
    cout << ans << "\n";
    for(int s = 0; s < saver.size(); s++){
        vector<int> poped = saver[s].used;
        for(int i = 0; i < poped.size(); i++){
            for(int j = 0; j < poped[i]; j++)
            cout << coins[i].first << " ";
    }
    cout << "\n";
    }

    return 1;
}