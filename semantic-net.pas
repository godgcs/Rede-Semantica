//////////////////////////////////////////////////////////////////////////////////////////////
//											    //
//				Aplicativo : semantic-net				    //
//		   									    //
//////////////////////////////////////////////////////////////////////////////////////////////
//		   									    //
//			Trabalho Prático 02 - Matemática Discreta			    //
//				Alunos: Flávia Ribeiro 		0022651			    //
//					Guilherme Cardoso Silva	0022645			    //
//					Luiz Eduardo Pereira	0021619			    //
//						 	Data  : 02/03/2016		    //
//			  								    //
//////////////////////////////////////////////////////////////////////////////////////////////
//											    //
//	Implementação feita no Windows 10 usando FPC, testada e executado no Ubuntu 	    //
//	Compilação: Gere o Executavel do Aplicativo no FPC e então vá no terminal e 	    //
//		o execute	passando como parametro o arquivo de entrada e de Saida	    //
//		user@machine$ ./semantic-net <arquivo-entrada> <arquivo-saida>		    //
//											    //
//////////////////////////////////////////////////////////////////////////////////////////////
//											    //
//	Objetivo do Trabalho :	Gerar uma aplicação que repesente uma estruturalisação	    //
// 			de uma Rede Semantica, gerando relatorios a partir de suas relações //
//											    //
//////////////////////////////////////////////////////////////////////////////////////////////
Program semantic_net;

Uses CRT, SysUtils;

//3.2 Requisito: Lookup Table para Armazenar Objetos, Conceitos e Idéias da Rede
//3.3 Requisito: Lookup Table para Armazenar Tipos de Relacionamentos

Type 
  dadosNos = Record
             codigo:integer;
             nome:String; 
  End; 
  Vet_DadosNos = Array of DadosNos;

  dadosTipos = Record
               codigo:integer;
               nome:String;
  End;
  Vet_DadosTipos = Array of dadostipos;

  dadosRelacoes =  Record
                   codigo1:integer;
                   codigo2:integer;
                   relacao:integer;
  End;
  Vet_DadosRelacoes = Array of dadosRelacoes;

  Vet_MatrizIncidencia = Array of Array of Integer;

Var V_NomesNos : Vet_DadosNos;

    V_TipoRela : Vet_DadosTipos;
	
    V_DadosRelacoes : Vet_DadosRelacoes;

    Matriz : Vet_MatrizIncidencia;
//-------------------------------------------------------------------	

    Entrada,Saida,Linha : String;
    ArqEntrada,ArqSaida : TextFile;
    QtdNos, QtdTipos		: Integer;

Procedure IniciaVetores;
  Begin		//Inicia Vetores, e variaveis de Dados
      SetLength(V_NomesNos,0);
      SetLength(V_TipoRela,0);
      SetLength(V_DadosRelacoes,0);
      QtdTipos:=0;
      qtdNos:=0;
  End;  

//3.1 Requisito: Entrada de Dados via Arquivo

Procedure LeArquivo;
var i : Integer;
  Begin
      Assign(ArqEntrada,entrada);
        Reset(ArqEntrada);
          While (not EOF(ArqEntrada)) do
            Begin
                Readln(ArqEntrada,linha);//associa a linha do arquivo com uma variavel do tipo string para manipulaçao de strings
                  if length(linha)<>0
                    Then Begin
                             //Deleta qualquer comentario no codigo
                             For i:=1 to length(linha) do
                               Begin
                                   if linha[1]='#'
                                     Then Begin
                                              //caso existam comentarios no arquivo serão apagados aqui para leitura
                                              Delete(linha,1,Length(linha));
                                              Break;
                                          End;
                               End;
                             //Pega dados dos nos da Rede Semantica   
                             if linha[1]+linha[2]='N '
                               Then Begin
                                        //pega o valor da quantidade de nos
                                        qtdNos:=StrToInt(copy(linha,3,length(Linha)));
                                    End;
                             if linha[1]+linha[2]='n '
                               Then Begin
                                        //deleta o n
                                        Delete(linha,1,2);
                                        i:=pos(' ',linha);
                                        //pega o valor do codigo
                                        SetLength(V_NomesNos,length(V_NomesNos)+1);
                                        V_NomesNos[length(V_NomesNos)-1].codigo:=StrToInt(copy(linha,1,i-1));
                                        Delete(linha,1,i);
                                        //pega o valor do nome
                                        V_NomesNos[length(V_NomesNos)-1].nome:=copy(linha,1,length(linha));
                                    End;
                             //Pega dados dos tipos de relacionamentos da rede semantica         
                             if linha[1]+linha[2]='K '
                               Then Begin
                                        qtdTipos:=StrToInt(copy(linha,3,length(Linha)));
                                    End;
                             if linha[1]+linha[2]='k ' 
                               Then Begin
                                        //deleta o k
                                        Delete(linha,1,2);
                                        //pega o valor do codigo
                                        i:=pos(' ',linha);
                                        SetLength(V_TipoRela,length(V_TipoRela)+1);
                                        V_TipoRela[length(V_TipoRela)-1].codigo:=StrToInt(copy(linha,1,i-1));
                                        Delete(linha,1,i);
                                        //pega o valor do nome 
                                        V_TipoRela[length(V_TipoRela)-1].nome:=copy(linha,1,length(linha));
                                    End; 
                             //Pega dados dos relacionamentos 
                             if linha[1]+linha[2]='r ' 
                               Then Begin
                                        //deleta o r
                                        Delete(linha,1,2);
                                        //pega valor do primeiro codigo
                                        i:=pos(' ',linha);
                                        SetLength(V_DadosRelacoes,length(V_DadosRelacoes)+1);
                                        V_DadosRelacoes[length(V_DadosRelacoes)-1].codigo1:=StrToInt(copy(linha,1,i-1));
                                        Delete(linha,1,i);
                                        //pega valor do segundo codigo
                                        i:=pos(' ',linha);                                        
                                        V_DadosRelacoes[length(V_DadosRelacoes)-1].codigo2:=StrToInt(copy(linha,1,i-1));
                                        Delete(linha,1,i);
                                        //pega valor da relação                                    
                                        V_DadosRelacoes[length(V_DadosRelacoes)-1].relacao:=StrToInt(copy(linha,1,length(linha)));
                                    End; 
                             if linha[1]='f' Then Break; 
                         End;
            End;
      Close(ArqEntrada);
  End;
//-----------------------------------------------------------

//3.4 Requisito: Matriz de Incidência da Rede Semântica 

Procedure GerarMatrizIncidencia; 
var i,ind1,ind2,relacao : Integer;
  	Begin
  		//ind1 = Out
  		//ind2 = In
	  	SetLength(Matriz,qtdNos);
	  	For i:= 0 to qtdNos-1 do	//Cria  tamanho da Matriz
	  		Begin
	  			SetLength(Matriz[i],qtdNos); 
	  		End;

	  	For i:= 0 to length(V_DadosRelacoes)-1 do	
	  		Begin
	  			ind1:=V_DadosRelacoes[i].codigo1-1;	//atribuio o valor de cada indice de relação a uma variavel
	  			ind2:=V_DadosRelacoes[i].codigo2-1;
	  			relacao:=V_DadosRelacoes[i].relacao;

	  			Matriz[ind1][ind2]:=relacao; //Coloco o codigo da relação na posição correspondente da matriz
	  		End;
  	End;
//-----------------------------------------------------------

//3.5 Requisito: Mapeamento de ID para Objeto, Conceito ou Idéia

Function RetornaNomeNo(cod:integer):String;  //passarei como parametro o codigo do nó e vasculharei o vetor até encontrar o nome correspondente
 var i : Integer;
	Begin
		For i := 0 to Length(V_NomesNos)-1 do
			Begin
				if V_NomesNos[i].codigo=cod
					Then RetornaNomeNo:=V_NomesNos[i].nome;
				End;
	End;
//-----------------------------------------------------------

//3.6 Requisito: Mapeamento de ID para tipo de Relacionamento

Function RetornaNomeRelacao(cod:integer):String;  //passarei como parametro o codigo da relação e vasculharei o vetor até encontrar o nome correspondente
 var i : Integer;
	Begin
		For i := 0 to Length(V_TipoRela)-1 do
			Begin
				if V_TipoRela[i].codigo=cod
					Then RetornaNomeRelacao:=V_TipoRela[i].nome;
			End;
	End;
//-----------------------------------------------------------

//3.7 Requisito: Estatísticas da Rede no Terminal
// Processos separados de Estatisticas

Function QuantidadeDeNos:integer; //quantidade de nos
	Begin
		QuantidadeDeNos:=qtdNos;
	End;

Function QuantidadeDeRelacoes:integer; //quatidade de relações
	Begin
		QuantidadeDeRelacoes:=length(V_DadosRelacoes);
	End;

Function Density:String; //Density
	Begin
		Density:=FloatToStr((length(V_DadosRelacoes)/((qtdNos)*(qtdNos)))*100)+'%';
	End;

Procedure ProporcaoDeRelacoes; //Proporção de Relações 
var i,j,Cont 		  : Integer;
	RelatorioRelacoes : Array of Integer;
	Begin			
	    SetLength(RelatorioRelacoes,Length(V_TipoRela));
	    For i := 0 to Length(Matriz)-1 do
	    	Begin
	    		For j := 0 to Length(Matriz[i])-1 do
					Begin
	    				if Matriz[i][j]<>0
	    					Then Begin
	    							 Cont:= Matriz[i][j];
	    							 inc(RelatorioRelacoes[Cont-1]);
	    						 End;
	    				End;
	    	End;
	    For i := 0 to Length(V_TipoRela)-1 do
	    	Begin
	    		Writeln('- ',RetornaNomeRelacao(V_TipoRela[i].codigo),': ',RelatorioRelacoes[i],'/',Length(V_DadosRelacoes));	
	    	End;
	End;

Procedure ProporcaoDeNos;
Type 
	By_Nodes = Record  //usarei um registro para armazenar a quantidade de vezes que entra e sai um arco na matriz, sempre que for <> 0 a existe um arco
			   Entra: Integer;
			   Sai  : Integer;
	End;
var i,j			 : Integer;
	mens,mens2	 : String;
	RelatorioNos : Array of By_Nodes; //cada posição do vetor representa um nó que tem entrada e saida de arcos
	Begin			
		SetLength(RelatorioNos,qtdNos);
		For i := 0 to Length(Matriz)-1 do
			Begin
				For j := 0 to Length(Matriz[i])-1 do
					Begin
						if Matriz[i][j]<>0
							Then Begin
									 inc(RelatorioNos[i].Sai);	//Out
									 inc(RelatorioNos[j].Entra);//In									 
								 End;	
					End;
			End;
			
		For i := 0 to qtdNos-1 do
			Begin
				mens:='';	
				mens2:='';
				if RelatorioNos[i].Entra = 0 		//Caso Seja Sink ou Source aplicarei uma mensagem extra para ser mostrado, caso contrario será vazio
					Then mens2:='(it’s a source)'
					Else mens2:='';
				if RelatorioNos[i].Sai = 0 
					Then mens:='(it’s a sink)'
					Else mens:='';
						Writeln('- ',RetornaNomeNo(V_NomesNos[i].codigo),': In ',RelatorioNos[i].Entra,mens2,', Out ',RelatorioNos[i].Sai,mens);
			End;		
	End;

Procedure EstatisticasLeitura;
  	Begin     
		Writeln('Statistics:');
		Writeln('===========');
		Writeln;

		Writeln('1. General');
		Writeln;

	    Writeln('- Number of Nodes : ',QuantidadeDeNos);
	    Writeln('- Number of Edges : ',QuantidadeDeRelacoes);
	    Writeln('- Density         : ',Density);
	    Writeln;

	    Writeln('2. By Types of Relationship');
	    Writeln;

	    ProporcaoDeRelacoes;
	    Writeln;

	    Writeln('3. By Nodes');
	    Writeln;

	    ProporcaoDeNos;
	    Writeln;

	    Writeln('End of processing.');
  	End;
//-----------------------------------------------------------

//3.8 Requisito: Saída de Dados no Formato Dot

Procedure GeraArquivoDot;
var i,j:integer;
	Begin
		Assign(ArqSaida,saida);
    	Rewrite(ArqSaida);
		
		Writeln(ArqSaida,'digraph Rede {');
		For i := 0 to length(V_NomesNos)-1 do	//percorro o vetor de nos e escrevo todos no arquivo
			Begin
				Writeln(ArqSaida,V_NomesNos[i].codigo,' ','[label="',RetornaNomeNo(V_NomesNos[i].codigo),'"];');
			End;

		For i := 0 to Length(Matriz)-1 do	//percorro toda a matriz buscando por relaçoes e quando encontrar irei escreve-la no arquivo
			Begin
				For j := 0 to Length(Matriz[i])-1 do
					Begin
						if Matriz[i][j]<>0
							Then Begin
									Writeln(ArqSaida,i+1,' -> ',j+1,' [label="',RetornaNomeRelacao(Matriz[i][j]),'"];');
								 End;
					End;
 			End;
		Writeln(ArqSaida,'}');

		Close(ArqSaida);
	End;
//-----------------------------------------------------------

//Escopo Principal do Trabalho

Begin
    ClrScr;
	if(ParamCount < 2) //verifica parametros passados
	  	Then Begin
			   	writeln('Erro. Usar parametros <Arquivo-Entrada> <Arquivo-Saida>'); 
			   	Readkey;
			   	Exit;
		   	 End;

	Entrada:=ParamStr(1);
	Saida:=ParamStr(2);	
	
    IniciaVetores;
    LeArquivo;
	GerarMatrizIncidencia;

    EstatisticasLeitura;

    GeraArquivoDot;
End.
//-----------------------------------------------------------