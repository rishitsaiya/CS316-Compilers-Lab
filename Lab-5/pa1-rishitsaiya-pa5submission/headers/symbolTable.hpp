/*
    Acknowledgement(s): (Akshat Karani)
*/

#ifndef SYMBOL_TABLE_HPP
#define SYMBOL_TABLE_HPP

#include <bits/stdc++.h>
#include "entry.hpp"

class SymbolTable
{
public:
    std::string scope;
    
    // Map of name and Entry
    std::unordered_map<std::string, Entry *> symbols;
    std::vector<Entry *> ordered_symbols;
    int total_parameters = 0;
    int total_non_parameters = 0;

    SymbolTable(std::string scope) {
        this->scope = scope;
    }

    int linkSize() {
        return total_non_parameters;
    }

    Entry* findEntry(std::string name) {
        return symbols[name];
    }

    void addEntry(std::string name, std::string type) {
        total_non_parameters++;
        Entry* variable = new Entry(name, type);
        variable->stackname = "$-" + std::to_string(total_non_parameters);
        ordered_symbols.push_back(variable);
        symbols[name] = variable;
        std::cout << "var " << name << std::endl;
    }

    void addEntry(std::string name, std::string type, std::string value) {
        total_non_parameters++;
        Entry* variable = new Entry(name, type, value);
        variable->stackname = value;
        ordered_symbols.push_back(variable);
        symbols[name] = variable;
        if(value ==""){
            std::cout << "var " << name << std::endl;
        }
        else{
            std::cout << "str " << name << " " << value << std::endl;
        }
    }

    void addEntry(std::string name, std::string type, bool isParameter) {
        total_parameters++;
        Entry* variable = new Entry(name, type, isParameter);
        variable->stackname = "$" + std::to_string(total_parameters+1);
        ordered_symbols.push_back(variable);
        symbols[name] = variable;
        std::cout<<"var "<<name<<std::endl;
    }

    bool ifExists(std::string name) {
        if (symbols.find(name) == symbols.end())
            return false;
        else
            return true;
    }

    void printTable() {
        std::cout << "Symbol table " << scope << std::endl;

        for (auto it = ordered_symbols.begin(); it != ordered_symbols.end(); ++it) {
            std::cout << "name " << (*it)->name << " type " << (*it)->type;    
            if ((*it)->value != "")
                std::cout << " value " << (*it)->value;
            std::cout << std::endl;
        }
    }
};

#endif
