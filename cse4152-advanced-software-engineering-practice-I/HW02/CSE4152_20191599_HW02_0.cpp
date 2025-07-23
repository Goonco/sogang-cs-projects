#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;
typedef long long ll;

int* heap;
int main()
{
    ios::sync_with_stdio(false);
    cin.tie(NULL);

    int N;
    cin >> N;

    vector<int> heap(N*N, 0);

    int num;
    for(int i = 0; i < N*N; i++){
        cin >> num;
        heap.push_back(num);
    }

    make_heap(heap.begin(), heap.end());
    for(int i = 0; i < N; i++){
        pop_heap(heap.begin(), heap.end());
        cout << heap.back() << " ";
        heap.pop_back();
    }
    cout << "\n";
    return 0;
}