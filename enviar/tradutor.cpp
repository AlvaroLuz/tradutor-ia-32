#include <algorithm>
#include <cstring>
#include <fstream>
#include <iostream>
#include <map>
#include <regex>
#include <sstream>
#include <string>
#include <vector>

/*-----------------------------------------------------------------------------------------
		Utils
-----------------------------------------------------------------------------------------*/
std::vector<std::string> parse(std::string s, std::string delimiter) {
	std::vector<std::string> parsed;
	size_t pos = 0;
	std::string token;
	while ((pos = s.find(delimiter)) != std::string::npos) {
    	token = s.substr(0, pos);
    	parsed.push_back(token);
    	s.erase(0, pos + delimiter.length());
  	}
  	parsed.push_back(s);
  	return parsed;
}
void lowercase(std::string& str){
	for(int i=0; i< str.size(); i++){
		str[i] = tolower(str[i]);
	}
}
void uppercase(std::string& str){
	for(int i=0; i< str.size(); i++){
		str[i] = toupper(str[i]);
	}
}
std::map<std::string, std::pair<int, int>> diretivas = {
    {"ADD", {1, 2}},     {"SUB", {2, 2}},    {"MUL", {3, 2}},
    {"DIV", {4, 2}},     {"JMP", {5, 2}},    {"JMPN", {6, 2}},
    {"JMPP", {7, 2}},    {"JMPZ", {8, 2}},   {"COPY", {9, 3}},
    {"LOAD", {10, 2}},   {"STORE", {11, 2}}, {"INPUT", {12, 2}},
    {"OUTPUT", {13, 2}}, {"STOP", {14, 1}}};

bool BothAreSpaces(char lhs, char rhs) { return (lhs == rhs) && (lhs == ' '); }

int open_file(std::string _file_name) {
  	std::ifstream input_stream;
  	input_stream.open(_file_name.c_str());
  	if (!input_stream) {
    	return 0;
  	}
  	return 1;
}

/*-----------------------------------------------------------------------------------------
		preprocessador
------------------------------------------------------------------------------------------*/
class Preprocessador {
  	std::vector<std::string> codigo;
    std::string filtraLinha(std::string linha) {
	    std::transform(linha.begin(), linha.end(), linha.begin(), ::toupper);
	    size_t comentario = linha.find(';');
	    // remove comentario
	    if (comentario != std::string::npos)
 			linha = linha.substr(0, comentario);
	
	    size_t progresso = 0, achou;
	    std::string rotulo = "";
	    achou = linha.find(':');
	    // separa o rotulo
	    if (achou != std::string::npos) {
	        rotulo = linha.substr(progresso, achou + 1);
	        rotulo.erase(std::remove_if(rotulo.begin(), rotulo.end(), ::isspace),
	                   rotulo.end());
	        progresso = achou + 1;
	    }
	    while (linha[progresso] == ' ' && progresso + 1 < linha.size())
	        progresso++;
	    while (linha.back() == ' ')
	        linha.pop_back();
	
	    // separa a diretiva
	    std::string diretiva = "";
	    std::string operandos = "";
	    linha = linha.substr(progresso, linha.size());
	    achou = linha.find(' ');
	    progresso = 0;
	    if (achou != std::string::npos) {
	        diretiva = linha.substr(progresso, achou + 1);
	        progresso = achou + 1;
	        // separa os operandos
	        operandos = linha.substr(progresso, linha.size());
	        operandos.erase(
	        std::remove_if(operandos.begin(), operandos.end(), ::isspace),
	          operandos.end());
	    } else {
	      diretiva = linha.substr(progresso, linha.size());
	    }
	    return rotulo + diretiva + operandos;
  }

  void resolveRotulos() {
    for (int i = 0; i < codigo.size(); i++) {
      	if (codigo[i].back() == ':') {
	        codigo[i] = codigo[i] + codigo[i + 1];
        	codigo.erase(codigo.begin() + i + 1);
      	}
    }
  }

  void resolveEquIf() {
    size_t achou;
    std::vector<std::string> resolved;
    std::string rotulo, valor;
    int ifFlag = 0;
    std::map<std::string, std::string> tabela;
    // acha os equ e if
    for (int i = 0; i < codigo.size(); i++) {
      // std::cout<< codigo[i]<<std::endl;
      	if (ifFlag) {
        	ifFlag = 0;
      	} 
	  	else {
       		achou = codigo[i].find("EQU");
        	if (achou != std::string::npos) {
          		rotulo = codigo[i].substr(0, achou - 1);
          		valor = codigo[i].substr(achou + 4, (codigo[i]).size());
          		tabela[rotulo] = valor;
          		continue;
        	}
        	achou = codigo[i].find("IF");
	        if (achou != std::string::npos) {
	          	rotulo = codigo[i].substr(achou + 3, codigo[i].size());
	          	if (stoi(tabela[rotulo]) == 0) {
	            	ifFlag = 1;
	          	}
	          	continue;
	        }
        	resolved.push_back(codigo[i]);
      	}
    }
    // substitui as ocorrencias da label do equ
    for (int i = 0; i < resolved.size(); i++) {
      	for (auto it = tabela.begin(); it != tabela.end(); it++) {
	        achou = resolved[i].find(it->first);
	        if (achou != std::string::npos) {
	          	resolved[i].replace(achou, it->first.size(), it->second);
	        }
      }
    }
    this->codigo = resolved;
  }

public:
  // preprocessa o codigo
  // remover comentarios, simplificar statements do tipo eq, remover trechos de
  // codigo com if se necessario
  	Preprocessador(std::string arquivo) {
	    std::ifstream fs(arquivo);
	    std::string linha;
	    this->codigo = {};
	    while (std::getline(fs, linha)) {
	      	// remove linhas vazias
	      	linha = filtraLinha(linha);
			uppercase(linha);
	      	if (linha != "") {
	        	this->codigo.push_back(linha);
	      	}
	    }
	    fs.close();
	    resolveRotulos();
	    resolveEquIf();
  	}

  	std::vector<std::string> getCodigo() { return this->codigo; }
};
/*-----------------------------------------------------------------------------------------
		TRADUTOR
------------------------------------------------------------------------------------------*/
class Tradutor {
  	std::vector<std::string> codigo;
	std::vector<std::string> str_labels;
	std::vector< std::string > 	text, bss, data; 

	void param_fix(std::string& par){
		auto parvec = parse(par, ",");
		std::string res = "", variavel;
		for(int i=0; i<parvec.size();i++, res+=","){
			if (parvec[i][0]!= '\'' && !isdigit(parvec[i][0])){
				lowercase(parvec[i]);
				variavel = parvec[i];
			}
			else{
				variavel = parvec[i];
			}
			res += variavel;
		}
		res.pop_back();
		par = res;
	}
	void parse_instruction(std::string codigo,std::string& rot, std::string& ins, std::string& par){
		rot = "", ins = "", par = "";
		auto auxvec = parse(codigo, ":");
		if(auxvec.size()>1){
			rot = auxvec[0];
			ins = auxvec[1];
		}
		else{
			rot = "\t";
			ins = auxvec[0];
		}
		auxvec = parse(ins, " ");
		if(auxvec.size()>1){
			ins = auxvec[0];
			par = auxvec[1];
		}
		lowercase(rot);
		param_fix(par);
	}
  	void resolve_text( int& i ){
		std::string rot, ins, par, newline;
		std::vector<std::string> parvec;
		for(i++;i<codigo.size() && codigo[i] != "SECTION DATA";i++){
			text.push_back("\n\t;"+codigo[i]);
			parse_instruction(codigo[i], rot, ins, par);
			newline = rot + (rot == "\t"?"\t":":\t") ;
			if (ins == "ADD" || ins == "SUB"){
				newline += (std::string) (ins == "ADD"?"add ":"sub ") + "eax,[" + par+ "]";
			}
			else if(ins == "MUL" || ins == "DIV"){
				text.push_back(newline + "cdq");
				newline += (ins == "MUL"?newline+"imul dword [":"\tidiv dword [") + par+ "]";
			}
			else if(ins == "JMP"){
				newline +=  "jmp "+ par;
			}
			else if(ins == "JMPP"|| ins =="JMPZ"|| ins == "JMPN"){
				text.push_back(newline+"cmp eax,0");
				newline = "\t\t";
				if (ins == "JMPP"){
					newline+= "jg "+ par;
				}
				else if (ins == "JMPZ"){
					newline+= "jz "+ par;
				}
				else{
					newline+= "jl "+ par;
				}
			}
			else if(ins == "COPY"){
				auto auxvec = parse (par, ",");
				text.push_back(newline +"mov ebx,[" + auxvec[0]+ "]");
				newline = "\t\tmov ["+auxvec[1]+"],ebx";
			}
			else if(ins == "STORE" || ins == "LOAD"){
				newline += "mov "+ (std::string) (ins == "STORE"? "["+par+"],eax":"eax,["+ par+ "]");
			}
			else if(ins == "INPUT" || ins == "INPUT_C" || ins == "INPUT_S"){
				parvec = parse(par,",");
				text.push_back(newline+"push dword "+parvec[0]);
				if (ins == "INPUT_S"){
					str_labels.push_back(parvec[0]);
					text.push_back("\t\tpush dword "+parvec[1]);
					newline =("\t\tcall input_s");
				}
				else if(ins == "INPUT_C"){
					str_labels.push_back(parvec[0]);
					newline =("\t\tcall input_c");
				}
				else{
					newline =("\t\tcall input_int");
				}
			}
			else if(ins == "OUTPUT" || ins == "OUTPUT_C" || ins == "OUTPUT_S"){
				parvec = parse(par,",");
				if (ins == "OUTPUT_S"){
					text.push_back(newline+"push dword "+parvec[0]);
					text.push_back("\t\tpush dword "+parvec[1]);
					newline =("\t\tcall output_s");
				}
				else if(ins == "OUTPUT_C"){
					text.push_back(newline+"push dword "+parvec[0]);
					newline =("\t\tcall output_c");
				}
				else{
					text.push_back(newline+"push dword ["+parvec[0]+"]");
					newline =("\t\tcall output_int");
				}
			}
			else if(ins == "STOP"){
				text.push_back("\t\tmov eax,1");
				text.push_back("\t\tmov ebx,0");
				newline = "\t\tint 0x80";
			}
			text.push_back(newline);
		}
	}
	void resolve_data(int& i){
		std::string rot, ins, par, newline;
		for(i++;i<codigo.size();i++){
			parse_instruction(codigo[i], rot, ins, par);
			newline  = rot + "\t";
			if (ins == "SPACE"){
				par = par==""? "1": par;
				auto it = std::find(str_labels.begin(),str_labels.end(), rot);
				for(auto i : str_labels){
					std::cout<<i <<"\n";
				}
				if(it != str_labels.end()){
					newline += "resb " + par;
				}
				else{
					newline += "resd " + par;
				}
				bss.push_back(newline);
			}
			else if (ins == "CONST"){
				if( par[0] == '\''){
					newline += "db " + par;
				}
				else{
					newline += "dd " + par;
				}
				data.push_back(newline);
			}
		}
	}
	void traduz(){
		int i = 0;
		if (codigo[i]!= "SECTION TEXT"){
			//tbw botar um throw aqui sla
		}
		else{
			resolve_text(i);
			resolve_data(i);
		}
	}
	void file_to_text(std::string arquivo){
		std::ifstream fs(arquivo);
	    std::string linha;
	    this->codigo = {};
	    while (std::getline(fs, linha)) {	      
			this->text.push_back(linha);
	    }
	    fs.close();
	}
public:
  	Tradutor(std::string arquivo) {
		this->text =    {"section .text", 
						 "global _start",
						 "_start:"}; 
		this->bss  =    {"section .bss"}; 
		this->data = 	{"section .data",
						 "_byte_str  db 0dh,0ah,\"Bytes lidos/escritos = \"",
						 "_newline   db 0dh,0ah"}; 

    	this->codigo = Preprocessador(arquivo).getCodigo();
		
		traduz();
		file_to_text("IO-functions/output_bytes.asm");
		file_to_text("IO-functions/input.asm");
		file_to_text("IO-functions/input_c.asm");
		file_to_text("IO-functions/input_s.asm");
		file_to_text("IO-functions/output.asm");
		file_to_text("IO-functions/output_c.asm");
		file_to_text("IO-functions/output_s.asm");
		this->codigo = {};
		codigo.insert(codigo.end(),text.begin(), text.end());
		codigo.insert(codigo.end(),data.begin(), data.end());
		codigo.insert(codigo.end(),bss.begin(), bss.end());
		
  	}

  	std::vector<std::string> get_traducao() { return this->codigo; }
};
int main(int argc, char** argv) { 
	if(argc == 2){
      std::string aux(argv[1]);
      if (open_file(aux)){
        auto temp =  Tradutor(argv[1]).get_traducao();
        std::ofstream arquivo(parse(aux,".")[0]+".s");
        for (auto i : temp){
        	arquivo<< i<<"\n";
        }
        arquivo.close();
      }
      else{
        std::cout<< "ERRO: Arquivo passado como argumento nao pode ser aberto"<<"\n";
        return 0;
      }
    }
	else{
		std::cout<<"ERRO: Numero errado de parametros\n";
	}
	return 0; 
}
