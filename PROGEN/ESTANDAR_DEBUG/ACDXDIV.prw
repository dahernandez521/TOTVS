#INCLUDE "protheus.ch"

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    � limDivIt � Autor � Duvan Hernandez       � Data � 01/06/23 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � validar tipo de diverg阯cia                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cCodDiver     = Divergencia origen 01,02,03,04             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   �                                                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � SIGAACD                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/

Function limDivIt(cOrdsep,cPedio,cProd,cLocal,cItem,cSequen,cCodDiver)

	If Alltrim(cCodDiver) $ cMVDIVERIT
		// Liberar CB8

		//
		// liberar SDC

		//
		// Liberar SBF

		//

	Else
		CB8->(DbSetOrder(1))
		CB8->(DbSeek(xFilial('CB8')+CB8->CB8_ORDSEP+CB8->CB8_ITEM+CB8->CB8_SEQUEN+CB8->CB8_PROD))
		While CB8->(!Eof()) .AND. CB8->(CB8_FILIAL+CB8_ORDSEP+CB8_ITEM+CB8_SEQUEN+CB8_PROD)==xFilial("CB8")+cOrdsep+cItem+cSequen+cProd
			RecLock("CB8",.F.)
			CB8->CB8_OCOSEP := cCodDiver
			CB8->(MsUnlock())
			CB8->(DbSkip())	

		EndDo

		CB9->(DbSetOrder(9))
		CB9->(DbSeek(xFilial("CB9")+CB8->(CB8_ORDSEP+CB8_PROD+CB8_LOCAL)))
		While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOCAL == xFilial("CB9")+CB8->(CB8_ORDSEP+CB8_PROD+CB8_LOCAL))
			If CB9->(CB9_ITESEP+CB9_SEQUEN) == cItem+cSequen
				RecLock("CB9")
				CB9->(DbDelete())
				CB9->(MsUnlock())
			EndIf
			CB9->(DbSkip())
		EndDo

	Endif

Return
