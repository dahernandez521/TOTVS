#INCLUDE "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � limDivIt � Autor � Duvan Hernandez       � Data � 01/06/23 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � validar tipo de diverg�ncia                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCodDiver     = Divergencia origen 01,02,03,04             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
