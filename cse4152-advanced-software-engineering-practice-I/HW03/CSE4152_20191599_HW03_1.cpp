#include <iostream>

using namespace std;

int main() {
	ios_base::sync_with_stdio(false);
	cin.tie(NULL);

    int N;
    cin >> N;

    double a, b;
    cin >> a >> b;

    double leftDis = 0, rightDis = 0;
    double lx = 0, ly = 0, rx = 0, ry = 0;

    bool leftSide = false, rightSide = false;
    double x, y, dis;
    for(int i = 0; i < N-1; i++){
        cin >> x >> y;
        dis = ((x - a) * (x - a)) + ((y - b) * (y - b));

        if(x == -a && y == -b){
                rightDis = dis;
                rx = x;
                ry = y;
        }
        else if(a*(y - b) < b*(x-a)){
            rightSide = true;
            // Right Side
            if(dis > rightDis){
                rightDis = dis;
                rx = x;
                ry = y;
            }
        }
        else {
            leftSide = true;
            // Left Side
            if(dis > leftDis){
                leftDis = dis;
                lx = x;
                ly = y;
            }
        }
    }

    // cout << rx << " " << ry << " ||| " << lx << " " << ly << "\n";
    if(!(leftSide && rightSide)) cout << "HCP\n";
    else {
        double A = ry - ly;
        double B = lx - rx;
        double C = (rx * ly) - (lx * ry);

        double Dist = (A * a + B * b + C) * (A * a + B * b + C) / (A * A + B * B);
        // cout << "\n********** " << Dist;
        double radius = a * a + b * b;

        if(radius >= Dist) cout << "HCP\n";
        else cout << "NO HCP\n";
    }
    return 0;
}