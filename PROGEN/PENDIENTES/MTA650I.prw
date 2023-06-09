#Include "Protheus.ch"

User Function MTA650I()

Local cProducto := SC2->C2_PRODUTO

dbSelectArea("SC2")
Reclock("SC2",.F.)
Replace C2_LOCAL With Posicione("SB1",1,xFilial("SB1")+cProducto,"B1_LOCPAD")
MsUnLock() 

Return
