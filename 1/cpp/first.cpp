#include <iostream>
#include <string>
#include <fstream>
#include <vector>
#include <algorithm>

class FileError {};

struct Rotation
{
    char direction;
    int clicks;
};

class Dial
{
public:
    Dial() : number{ 50 } {}

    int getNumber() const;
    int turn(Rotation rotation);
private:
    int number;
};

int Dial::getNumber() const
{
    return number;
}

int Dial::turn(Rotation rotation)
{
    int clicks{ rotation.clicks };
    if (rotation.direction == 'L') {
        clicks = -clicks;
    }
    number = (number + clicks) % 100;
    return number;
}

std::vector<Rotation> parse(const std::string& filename)
{
    std::vector<Rotation> result{};
    std::ifstream file{ filename };
    if (!file) {
        throw FileError{};
    }
    std::string line{};
    while (std::getline(file, line)) {
        Rotation r;
        r.direction = line.front();
        r.clicks = std::stoi(line.substr(1, line.size() - 1));
        result.push_back(r);
    }
    return result;
}

int main()
try {
    using namespace std::string_literals;

    std::vector<Rotation> rotations{ parse("input1.txt"s) };
    Dial dial{};
    int acc{ 0 };
    std::for_each(rotations.cbegin(), rotations.cend(), [&acc, &dial](Rotation r) {
        dial.turn(r);
        if (dial.getNumber() == 0) {
            acc += 1;
        }
    });
    std::cout << acc << '\n';

}
catch (const FileError& e) {
    std::cerr << "Can't read from file.\n";
    return 1;
}
