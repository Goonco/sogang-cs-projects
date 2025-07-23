#include <iostream>
#include <vector>

using namespace std;
typedef long long ll;

int N;

int main() {
	ios_base::sync_with_stdio(false);
	cin.tie(NULL);

    cin >> N;
    vector<vector<double> > A(N, vector<double>(N, 0));

    for (int k = 0; k < N; ++k) {
        int R1, R2, C1, C2;
        double V;
        cin >> R1 >> R2 >> C1 >> C2 >> V;

        // 누적 합 행렬 업데이트
        A[R1 - 1][C1 - 1] += V;
        if (R2 < N) A[R2][C1 - 1] -= V;
        if (C2 < N) A[R1 - 1][C2] -= V;
        if (R2 < N && C2 < N) A[R2][C2] += V;
    }

    // 누적 합 행렬로부터 최종 행렬 계산
    for (int i = 1; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            A[i][j] += A[i - 1][j];
        }
    }
    for (int i = 0; i < N; ++i) {
        for (int j = 1; j < N; ++j) {
            A[i][j] += A[i][j - 1];
        }
    }

    // 최종 행렬 출력
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            cout << A[i][j] << " ";
        }
        cout << endl;
    }

    return 0;
}