#include "protheus.ch"
#INCLUDE "RWMAKE.CH"

User Function EnterCpo(cCampo,ValorDoCampo,n)

	Local aArea    := GetArea()
	Local cVarAtu  := ReadVar()
	Local lRet     := .T.
	Local cPrefixo := "M->"
	Local bValid
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� A variavel __ReadVar e padrao do sistema, ela identifica o campo atualmente posicionado. �
	//� Mude o conteudo desta variavel para disparar as validacoes e gatilhos do novo campo.     �
	//� Nao esquecer de voltar o conteudo original no final desta funcao.                        �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	__ReadVar := cPrefixo+cCampo
	 
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Valoriza o campo atual "Simulado".                  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	&(cPrefixo+cCampo) := ValorDoCampo
	 
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Carrega validacoes do campo.                        �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	SX3->( dbSetOrder(2) )
	SX3->( dbSeek(cCampo) )
	bValid := "{|| "+IIF(!Empty(SX3->X3_VALID),Rtrim(SX3->X3_VALID)+IIF(!Empty(SX3->X3_VLDUSER),".And.",""),"")+Rtrim(SX3->X3_VLDUSER)+" }"
	 
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Executa validacoes do campo.                        �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	lRet := Eval( &(bValid) )
	 
	IF lRet
	 //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	 //� Executa gatilhos do campo.                          �
	 //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	 SX3->(DbSetOrder(2))
	 SX3->(DbSeek(cCampo))
	 IF ExistTrigger(cCampo)
	  RunTrigger(2,n)
	 EndIF
	EndIF
	 
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Retorna __ReadVar com o valor original.             �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	__ReadVar := cVarAtu
	 
	RestArea(aArea)
	
Return(lRet)
