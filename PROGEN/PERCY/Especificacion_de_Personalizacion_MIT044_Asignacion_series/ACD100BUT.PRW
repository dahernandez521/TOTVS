#Include "Rwmake.ch"
#Include "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ACD100BUT �Autor  �Percy Arias,SISTHEL � Data �  10/12/22   ���
�������������������������������������������������������������������������͹��
���Desc.     � Importa itens del archivo Excel p/orden de separacion      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function ACD100BUT

    local aBotao := {}

    //aAdd(aBotao,{'Carga Masiva',{|| u_STHWMS07() } , 'Carga Masiva' , 'Carga Masiva' })
    SetKey(VK_F9,{|| u_STHWMS07() } )

Return( aBotao )
