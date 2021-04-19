/*
    Acknowledgement(s): (Akshat Karani)
*/

#ifndef CodeObject_HPP
#define CodeObject_HPP

#include <bits/stdc++.h>
#include "codeLine.hpp"
#include "symbolTableStack.hpp"

class CodeObject
{
    int temp_value = 0;
public:
    std::vector<CodeLine*> threeAC;
    SymbolTableStack* symbolTableStack;
    int lb = 0;
    std::deque<int> lbList;
    
    CodeObject(SymbolTableStack* symbolTableStack)
    {
        this->symbolTableStack = symbolTableStack;
    }

    std::string getTemp()
    {
        return "$T" + std::to_string(++temp_value);
    }

    void addRead(std::string var_name, std::string type)
    {
        if (type == "INT")
            threeAC.push_back(new CodeLine(symbolTableStack->table_stack.top()->scope, "READI", var_name));
        else if (type == "FLOAT")
            threeAC.push_back(new CodeLine(symbolTableStack->table_stack.top()->scope, "READF", var_name));
    }

    void addWrite(std::string var_name, std::string type)
    {
        if (type == "INT")
            threeAC.push_back(new CodeLine(symbolTableStack->table_stack.top()->scope, "WRITEI", var_name));
        else if (type == "FLOAT")
            threeAC.push_back(new CodeLine(symbolTableStack->table_stack.top()->scope, "WRITEF", var_name));
        else if (type == "STRING")
            threeAC.push_back(new CodeLine(symbolTableStack->table_stack.top()->scope, "WRITES", var_name));
    }

    void print()
    {
        for (auto s: threeAC)
            s->print();
    }

};

#endif
