/*
	Acknowledgement(s): (Akshat Karani)
*/

#ifndef ASSEMBLYCODE_HPP
#define ASSEMBLYCODE_HPP

#include <bits/stdc++.h>
#include "codeObject.hpp"
#include "symbolTable.hpp"
#include "ast.hpp"

class AssemblyCode
{
public:
	int reg = 0;
	std::map<std::string, std::string> tempToReg;
	std::vector<CodeLine> assembly;

	std::string getNewReg()
	{
		reg++;
		return "r" + std::to_string(reg);
	}

	std::string getWhatever(std::string temp)
	{
		if (temp[0] == '#')
		{
			temp[0] = '$';
			return temp;
		}
		if (temp[0] != '$')
			return temp;
		if (tempToReg.find(temp) != tempToReg.end())
			return tempToReg[temp];
		tempToReg[temp] = getNewReg();
		return tempToReg[temp];
	}

	std::string getRegForID(std::string ID)
	{
		tempToReg[ID] = getNewReg();
		return tempToReg[ID];
	}

	bool isTemp(std::string temp)
	{
		return temp[0] == '$';
	}

	void generateCode(CodeObject *code, std::vector<SymbolTable *> STvector)
	{
		auto getLower = [&](std::string s) -> std::string
		{
			for (char &i : s)
				i |= ' ';
			if (s.back() == 'f')
				s.back() = 'r';
			return s;
		};

		for (CodeLine *line : code->threeAC)
		{
			std::string com = line->command;

			std::string farg1, farg2, farg3;

			auto frameVar = [&](std::string s, std::string scope) -> std::string
			{
				if (s[0] != '$')
				{
					bool got = 0;
					for (int i = STvector.size() - 1; i >= 0; --i)
					{
						if (STvector[i]->scope == scope)
							got = 1;
						if (got == 1 && STvector[i]->scope[0] != '$')
						{
							scope = STvector[i]->scope;
							break;
						}
					}

					SymbolTable *curtable;
					for (SymbolTable *table : STvector)
					{
						if (table->scope == scope)
						{
							curtable = table;
							break;
						}
					}

					int no_parameters = 0;

					for (int i = 0; i < (int)curtable->ordered_symbols.size(); ++i)
					{
						if (curtable->ordered_symbols[i]->isParameter == true)
							no_parameters++;
					}

					for (int i = 0; i < (int)curtable->ordered_symbols.size(); ++i)
					{
						if (curtable->ordered_symbols[i]->name == s)
						{
							if (curtable->ordered_symbols[i]->isParameter == true)
								return "#" + std::to_string(5 + i + 1);
							return "#-" + std::to_string(i + 1 - no_parameters);
						}
					}
				}
				return s;
			};

			farg1 = frameVar(line->arg1, line->scope);
			farg2 = frameVar(line->arg2, line->scope);
			farg3 = frameVar(line->arg3, line->scope);

			std::string flag = "$";
			int no_parameters = 0;

			bool got = 0;
			std::string scope = line->scope;
			for (int i = STvector.size() - 1; i >= 0; --i)
			{
				if (STvector[i]->scope == scope)
					got = 1;
				if (got == 1 && STvector[i]->scope[0] != '$')
				{
					scope = STvector[i]->scope;
					break;
				}
			}

			SymbolTable *curtable;
			for (SymbolTable *table : STvector)
			{
				if (table->scope == scope)
				{
					curtable = table;
					break;
				}
			}
			for (int i = 0; i < (int)curtable->ordered_symbols.size(); ++i)
			{
				if (curtable->ordered_symbols[i]->isParameter == true)
					no_parameters++;
			}

			flag += std::to_string(6 + no_parameters);
			if (com == "RET")
			{
				if (farg1[0] == '$')
				{

					assembly.push_back(CodeLine(line->scope, "move", getWhatever(farg1), flag));
					assembly.push_back(CodeLine(line->scope, "unlnk", ""));
					assembly.push_back(CodeLine(line->scope, "ret", ""));
				}
				else
				{
					std::string newR = getNewReg();
					tempToReg[farg1] = newR;
					assembly.push_back(CodeLine(line->scope, "move", getWhatever(farg1), newR));
					assembly.push_back(CodeLine(line->scope, "move", newR, flag));
					assembly.push_back(CodeLine(line->scope, "unlnk", ""));
					assembly.push_back(CodeLine(line->scope, "ret", ""));
				}
			}
			if (com == "PUSH")
			{
				if (line->arg1 != "")
				{
					assembly.push_back(CodeLine(line->scope, "push", getWhatever(farg1)));
				}
				else
				{
					// return value push
					assembly.push_back(CodeLine(line->scope, "push", ""));
				}
			}
			if (com == "PUSHR")
			{
				assembly.push_back(CodeLine(line->scope, "push", "r0"));
				assembly.push_back(CodeLine(line->scope, "push", "r1"));
				assembly.push_back(CodeLine(line->scope, "push", "r2"));
				assembly.push_back(CodeLine(line->scope, "push", "r3"));
			}
			if (com == "LINK")
			{
				int cnt = 5;
				assembly.push_back(CodeLine(line->scope, "link", std::to_string(cnt)));
			}
			if (com == "JSR")
			{
				assembly.push_back(CodeLine(line->scope, "jsr", line->arg1));
			}
			if (com == "POP")
			{
				if (line->arg1 == "")
				{

					assembly.push_back(CodeLine(line->scope, "pop", ""));
				}
				else
					assembly.push_back(CodeLine(line->scope, "pop", getWhatever(farg1)));
			}
			if (com == "POPR")
			{
				assembly.push_back(CodeLine(line->scope, "pop", "r3"));
				assembly.push_back(CodeLine(line->scope, "pop", "r2"));
				assembly.push_back(CodeLine(line->scope, "pop", "r1"));
				assembly.push_back(CodeLine(line->scope, "pop", "r0"));
			}
			if (com == "STOREI" || com == "STOREF")
			{
				assembly.push_back(CodeLine(line->scope, "move", getWhatever(farg1), getWhatever(farg2)));
			}
			else if (com == "WRITEI" || com == "WRITEF" || com == "WRITES")
			{
				assembly.push_back(CodeLine(line->scope, "sys", getLower(com), getWhatever(farg1)));
			}
			else if (com == "READI" || com == "READF")
			{
				assembly.push_back(CodeLine(line->scope, "sys", getLower(com), getWhatever(farg1)));
			}
			else
			{
				const std::string Ids[] = {"ADD", "SUB", "DIV", "MUL"};
				const std::string cmps[] = {"GE", "GT", "LT", "LE", "NE", "EQ"};
				bool presentinId = false;
				for (std::string i : Ids)
				{
					if (i == com.substr(0, 3))
					{
						assembly.push_back(CodeLine(line->scope, "move", getWhatever(farg1), getWhatever(farg3)));

						assembly.push_back(CodeLine(line->scope, getLower(com), getWhatever(farg2), getWhatever(farg3)));

						presentinId = true;
						break;
					}
				}

				// handle jump statements
				for (std::string i : cmps)
				{
					if (i == com)
					{
						//Symbol table lookup for cmpi/cmpr
						std::string compcom = "cmpi";
						// std::cout<<"Line scope is "<<line->scope<<std::endl;
						int flag = 0;
						int globflag = 0;
						for (SymbolTable *table : STvector)
						{
							if (table->scope == line->scope)
							{

								Entry *entry1 = table->findEntry(farg1);

								Entry *entry2 = table->findEntry(farg2);

								if ((entry1 && entry1->type == "FLOAT") || (entry2 && entry2->type == "FLOAT"))
								{
									flag = 1;
									compcom = "cmpr";
								}
								break;
							}
							if (table->scope == "GLOBAL")
							{

								Entry *entry1 = table->findEntry(farg1);

								Entry *entry2 = table->findEntry(farg2);

								if ((entry1 && entry1->type == "FLOAT") || (entry2 && entry2->type == "FLOAT"))
								{
									globflag = 1;
								}
							}
						}
						if (flag == 0 && globflag == 1)
						{
							compcom = "cmpr";
						}
						if (line->arg2[0] != '$')
						{
							// no temporary
							std::string temp = getRegForID(line->arg2);
							assembly.push_back(CodeLine(line->scope, "move", getWhatever(farg2), temp));
							assembly.push_back(CodeLine(line->scope, compcom, getWhatever(farg1), temp));
						}
						else
						{
							assembly.push_back(CodeLine(line->scope, compcom, getWhatever(farg1), getWhatever(farg2)));
						}

						assembly.push_back(CodeLine(line->scope, "j" + getLower(com), getWhatever(farg3)));

						presentinId = true;
						break;
					}
				}

				if (com == "JUMP")
				{
					assembly.push_back(CodeLine(line->scope, "jmp", line->arg1));
					presentinId = true;
				}
				else if (com == "LABEL")
				{
					assembly.push_back(CodeLine(line->scope, "label", line->arg1));
					presentinId = true;
				}
			}
		}
	}

	void print()
	{
		for (auto c : assembly)
			c.print();
	}
};

#endif
