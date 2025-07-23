#include <iostream>
#include <string>
#include <queue>
#include <stack>

using namespace std;
typedef long long ll;

struct Node {
    int value;
    Node* prev;
    vector<Node*> next;
};

int node_count = 0;
Node node_pool[100000];

Node* getNode(int value, Node* parent){
    node_pool[node_count].value = value;
    // node_pool[node_count].next = nullptr;
    node_pool[node_count].prev = parent;

    return &node_pool[node_count++];
}

int main() {
	ios_base::sync_with_stdio(false);
	cin.tie(NULL);

    int target;
    cin >> target;

    Node* root = getNode(1, nullptr);
    queue<Node*> bfs;
    bfs.push(root);
    
    Node* iter;
    Node* sum;
    Node* newNode;
    while(true){
        iter = bfs.front();
        bfs.pop();

        if(iter->value == target) break;

        sum = iter;
        while(sum != nullptr) {
            newNode = getNode(iter->value + sum->value, iter);
            iter->next.push_back(newNode);
            bfs.push(newNode);
            sum = sum->prev;
        }
    }

    int ansCount = -1;
    stack<int> st;
    while(iter != nullptr){
        ansCount++;
        st.push(iter->value);
        iter = iter->prev;
    }

    cout << ansCount << " ";
    while(!st.empty()){
        cout << st.top() << " ";
        st.pop();
    }
    cout << "\n";
	return 0;
}
