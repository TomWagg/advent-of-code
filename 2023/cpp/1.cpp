#include <iostream>
#include <string>
#include <fstream>

using namespace std;

int calibration_value(string doc) {
    const string digits = "123456789";
    return stoi(string() + doc[doc.find_first_of(digits)] + doc[doc.find_last_of(digits)]);
}

int true_calibration_value(string doc) {
    // track the minimum index in string and location
    const string numbers[9] = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine"};
    int min_first = 100000;
    int min_loc = -1;
    int max_last = -10;
    int max_loc = -1;

    // search for each string number in the document
    for (int i = 0; i < 9; i++) {
        int forward_search = doc.find(numbers[i]);
        int backward_search = doc.rfind(numbers[i]);

        // if the number is found then track its index and value
        if (forward_search != -1 && forward_search < min_first) {
            min_first = forward_search;
            min_loc = i;
        }
        if (backward_search != -1 && backward_search > max_last) {
            max_last = backward_search;
            max_loc = i;
        }
    }

    // same as part one search
    const string digits = "123456789";
    int first_digit = doc.find_first_of(digits);
    int last_digit = doc.find_last_of(digits);

    // decide whether to use the digits or string version of the numbers
    string first_num, last_num;
    if (first_digit < min_first && first_digit != -1) {
        first_num = string() + doc[first_digit];
    } else {
        first_num = to_string(min_loc + 1);
    }
    if (last_digit > max_last && last_digit != -1) {
        last_num = string() + doc[last_digit];
    } else {
        last_num = to_string(max_loc + 1);
    }

    // stick em together and sit back in fear at the difficulty of day 1
    return stoi(string() + first_num + last_num);
}

int main(void) {
    string line;
    int total = 0;
    int part_two_total = 0;
    ifstream file("../inputs/1.txt");
    if (file.is_open()) {
        while (getline(file, line))
        {
            total += calibration_value(line);
            part_two_total += true_calibration_value(line);
        }
        file.close();
        cout << "PART ONE: " << total << endl;
        cout << "PART TWO: " << part_two_total << endl;
    } else {
        cout << "Unable to open file"; 
    }
}
