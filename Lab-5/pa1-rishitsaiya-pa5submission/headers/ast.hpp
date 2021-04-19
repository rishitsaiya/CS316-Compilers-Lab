/*
    Acknowledgement(s): (Akshat Karani)
*/

#ifndef AST_HPP
#define AST_HPP

#include <bits/stdc++.h>
#include "entry.hpp"
#include "codeObject.hpp"

class ASTNode
{
public:
    static std::string id_type;
    std::string type;
    ASTNode *left;
    ASTNode *right;

    virtual std::string generateCode(CodeObject *code)
    {
        return "N/A";
    };
};

class ASTNode_Expr : public ASTNode
{
public:
    std::string type = "EXPR";
    char optype;

    ASTNode_Expr(char optype)
    {
        this->optype = optype;
    }

    std::string generateCode(CodeObject *code)
    {
        std::string left = this->left->generateCode(code);
        std::string right = this->right->generateCode(code);
        std::string temp = code->getTemp();
        std::string command = "";
        if (ASTNode::id_type == "INT")
        {
            if (optype == '+')
                command += "ADDI";
            else if (optype == '-')
                command += "SUBI";
            else if (optype == '*')
                command += "MULI";
            else if (optype == '/')
                command += "DIVI";
        }
        else if (ASTNode::id_type == "FLOAT")
        {
            if (optype == '+')
                command += "ADDF";
            else if (optype == '-')
                command += "SUBF";
            else if (optype == '*')
                command += "MULF";
            else if (optype == '/')
                command += "DIVF";
        }
        code->threeAC.push_back(new CodeLine(code->symbolTableStack->table_stack.top()->scope, command, left, right, temp));
        return temp;
    }
};

class ASTNode_INT : public ASTNode
{
public:
    std::string type = "INT";
    int value;

    ASTNode_INT(int value)
    {
        this->value = value;
    }

    std::string generateCode(CodeObject *code)
    {
        std::string temp = code->getTemp();
        code->threeAC.push_back(new CodeLine(code->symbolTableStack->table_stack.top()->scope, "STOREI", std::to_string(this->value), temp));
        return temp;
    }
};

class ASTNode_FLOAT : public ASTNode
{
public:
    std::string type = "FLOAT";
    float value;

    ASTNode_FLOAT(float value)
    {
        this->value = value;
    }

    std::string generateCode(CodeObject *code)
    {
        std::string temp = code->getTemp();
        char str[10];
        sprintf(str, "%f", value);
        code->threeAC.push_back(new CodeLine(code->symbolTableStack->table_stack.top()->scope, "STOREF", str, temp));
        return temp;
    }
};

class ASTNode_ID : public ASTNode
{
public:
    std::string type = "ID";
    Entry *variable;

    ASTNode_ID(Entry *variable)
    {
        this->variable = variable;
    }

    std::string generateCode(CodeObject *code)
    {
        return this->variable->name;
    }
};

class ASTNode_Assign : public ASTNode
{
public:
    std::string type = "ASSIGN";

    ASTNode_Assign(Entry* var)
    {
        this->left = new ASTNode_ID(var);
        ASTNode::id_type = var->type;
    }

    std::string generateCode(CodeObject *code)
    {
        std::string command = "";
        if (ASTNode::id_type == "INT")
            command += "STOREI";
        else if (ASTNode::id_type == "FLOAT")
            command += "STOREF";
        code->threeAC.push_back(new CodeLine(code->symbolTableStack->table_stack.top()->scope,
                                             command, 
                                             this->right->generateCode(code),
                                             this->left->generateCode(code)));
        return "";
    }
};

class ASTNode_CallExpr : public ASTNode
{
public:
    std::string type = "CALLEXPR";
    std::string funct_name = "";
    std::vector<ASTNode*>* parameter_list;

    ASTNode_CallExpr(std::string func_name, std::vector<ASTNode*>* plist)
    {
        this->funct_name = func_name;
        this->parameter_list = plist;
    }


    std::string generateCode(CodeObject *code)
    {

        std::string comm = "PUSH";

        code->threeAC.push_back(new CodeLine(code->symbolTableStack->table_stack.top()->scope, comm, ""));

        for(auto& node : *parameter_list) {
            std::string para = node->generateCode(code);
            code->threeAC.push_back(new CodeLine(code->symbolTableStack->table_stack.top()->scope, comm, para));
        }

        code->threeAC.push_back(new CodeLine(code->symbolTableStack->table_stack.top()->scope, comm + "R", ""));
        code->threeAC.push_back(new CodeLine(code->symbolTableStack->table_stack.top()->scope, "JSR", funct_name));
        code->threeAC.push_back(new CodeLine(code->symbolTableStack->table_stack.top()->scope, "POPR", ""));

        for(int i=0;i<(int)(*parameter_list).size();++i)
            code->threeAC.push_back(new CodeLine(code->symbolTableStack->table_stack.top()->scope, "POP", ""));

        std::string temp = code->getTemp();

        code->threeAC.push_back(new CodeLine(code->symbolTableStack->table_stack.top()->scope, "POP", temp)); 
        
        return temp;
    }
};

class ASTNode_Cond : public ASTNode 
{
public:
    std::string comp_op;
    ASTNode_Cond(std::string comp_op) {
        this->comp_op = comp_op;
    }

    std::string generateCode(CodeObject *code) {
        std::string op, label;
        std::string arg1 = this->left->generateCode(code);
        std::string arg2 = this->right->generateCode(code);

        code->lb += 1;
        code->lbList.push_back(code->lb);
        label = "LABEL" + std::to_string(code->lb);

        if (comp_op == ">") {
            op = "LE";
        } else if (comp_op == "<") {
            op = "GE";
        } else if (comp_op == "=") {
            op = "NE";
        } else if (comp_op == "!=") {
            op = "EQ";
        } else if (comp_op == ">=") {
            op = "LT";
        } else if (comp_op == "<=") {
            op = "GT";
        }
        code->threeAC.push_back(new CodeLine(code->symbolTableStack->table_stack.top()->scope, op, arg1, arg2, label));
        return "";
    }
};

#endif
