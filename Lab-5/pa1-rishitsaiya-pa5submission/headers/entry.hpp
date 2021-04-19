/*
    Acknowledgement(s): (Akshat Karani)
*/

#ifndef ENTRY_HPP
#define ENTRY_HPP

#include <bits/stdc++.h>

class Entry
{
public:
    std::string name, type, value;
    std::string stackname;
    bool isParameter = false;

    Entry(std::string name, std::string type) {
        this->name = name;
        this->type = type;
        this->value = "";
    }
    
    Entry(std::string name, std::string type, std::string value) {
        this->name = name;
        this->type = type;
        this->value = value;
    }

    Entry(std::string name, std::string type, bool isParameter) {
        this->name = name;
        this->type = type;
        this->isParameter = isParameter;
    }

};

#endif
