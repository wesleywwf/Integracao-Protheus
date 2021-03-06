#Include 'Totvs.ch'

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
��� Programa   � M030INC    � Autor � Simone Santos         � Data � __/__/____ ���
�������������������������������������������������������������������������������͹��
��� Empresa    � Sol Panamby                                                    ���
�������������������������������������������������������������������������������͹��
��� Descricao  � Ponto de entrada para o envio de email apos a inclusao no      ���
���            � cadastro de cliente                                            ���
�������������������������������������������������������������������������������͹��
��� Modulo     � SIGACOM                                                        ���
�������������������������������������������������������������������������������͹��
��� Uso        � Ponto de Entrada                                               ���
�������������������������������������������������������������������������������͹��
��� Parametros � Nil                                                            ���
�������������������������������������������������������������������������������͹��
��� Retorno    � Nil                                                            ���
�������������������������������������������������������������������������������͹��
��� Data       � Analista    �Descricao da Alteracao                            ���
���============�=============�==================================================���
��� 24/11/2014 � Alexandre S � Reorganizacao do programa                        ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
User Function M030INC()
Local aAreaSA1 := SA1->(GetArea())

If ParamIXB == 1
	If SM0->M0_CODIGO $ "75|80" .AND. SA1->A1_MSBLQL <> "1"
		U_ISA10001(INCLUI,ALTERA)
	EndIf
	If ! SM0->M0_CODIGO $ "A6|A7"
		WFCliente()
	EndIf
EndIf

RestArea(aAreaSA1)
Return(Nil)

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
��� Funcao     � WFCliente  � Autor � Alexandre Soares Reis � Data � 15/06/2016 ���
�������������������������������������������������������������������������������͹��
��� Descricao  � Montagem de WorkFlow e envio de email para confer�ncia         ���
���            �                                                                ���
�������������������������������������������������������������������������������͹��
��� Parametros � Nil                                                            ���
�������������������������������������������������������������������������������͹��
��� Retorno    � Nil                                                            ���
�������������������������������������������������������������������������������͹��
��� Data       � Analista    �Descricao da Alteracao                            ���
���============�=============�==================================================���
��� __/__/____ � ___________ �                                                  ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
Static Function WFCliente()
Local cMensagem := ""
Local cTitulo := "Cadastro de Cliente (inclus�o)"
Local aSuperior := {}
Local aHeader := {}
Local aItens := {}
Local aMeio := {}
Local aInferior := Nil
Local aLegenda := Nil
Local aObserv := {}

aAdd( aSuperior, { "Empresa"      , SM0->(AllTrim(M0_CODIGO) + " - " + AllTrim(M0_NOME))                                               , .F., .F. } )
aAdd( aSuperior, { "Filial"       , SM0->(Alltrim(M0_CODFIL) + " - " + AllTrim(M0_FILIAL))                                             , .F., .F. } )
aAdd( aSuperior, { "Data / Hora"  , Transform( Date() , PesqPict( "SC8", "C8_EMISSAO" ) ) + " - " + Transform( Time() , "99:99:99" )   , .F., .F. } )
aAdd( aSuperior, { "Usu�rio"      , __cUserID + " - " + cUserName                                                                      , .F., .F. } )
aAdd( aSuperior, { ""             , "Este Cliente dever� ser revisado pelos deptos respons�veis antes de sua utiliza��o no Sistema"    , .T., .F. } )

aAdd( aHeader, { RetTitle( "A1_COD"    ), "CENTER", "05%" } )
aAdd( aHeader, { RetTitle( "A1_LOJA"   ), "CENTER", "05%" } )
aAdd( aHeader, { RetTitle( "A1_NOME"   ), "CENTER", "15%" } )
aAdd( aHeader, { RetTitle( "A1_NREDUZ" ), "CENTER", "10%" } )
aAdd( aHeader, { RetTitle( "A1_CGC"    ), "CENTER", "10%" } )
aAdd( aHeader, { RetTitle( "A1_INSCR"  ), "CENTER", "10%" } )
aAdd( aHeader, { RetTitle( "A1_EST"    ), "CENTER", "05%" } )
aAdd( aHeader, { RetTitle( "A1_PESSOA" ), "CENTER", "05%" } )

aAdd( aItens,    {} )
aAdd( aItens[ Len( aItens ) ], { SA1->A1_COD                                                                                           , "LEFT", } )
aAdd( aItens[ Len( aItens ) ], { SA1->A1_LOJA                                                                                          , "LEFT", } )
aAdd( aItens[ Len( aItens ) ], { SA1->A1_NOME                                                                                          , "LEFT", } )
aAdd( aItens[ Len( aItens ) ], { SA1->A1_NREDUZ                                                                                        , "LEFT", } )
aAdd( aItens[ Len( aItens ) ], { AllTrim(Transform(SA1->A1_CGC,If(SA1->A1_PESSOA == "F","@R 999.999.999-99","@R 99.999.999/9999-99"))) , "LEFT", } )
aAdd( aItens[ Len( aItens ) ], { AllTrim(Transform(SA1->A1_INSCR,"@R 999.999.999.999"))                                                , "LEFT", } )
aAdd( aItens[ Len( aItens ) ], { SA1->A1_EST                                                                                           , "LEFT", } )
aAdd( aItens[ Len( aItens ) ], { If(SA1->A1_PESSOA == "F","Fisica","Juridica")                                                         , "LEFT", } )

aMeio := { aHeader, aItens }

aAdd( aObserv, { "Obs.: O Cadastro encontra-se bloqueado aguardando revis�o da �rea respos�vel!" , .F., .T. } )

cMensagem := U_MontaWF( cTitulo, aSuperior, aMeio, aInferior, aLegenda, aObserv )
U_EnvEmail( {iEmail()}, cTitulo, cMensagem )
Return(Nil)

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
��� Funcao     � iEmail     � Autor �                       � Data � __/__/____ ���
�������������������������������������������������������������������������������͹��
��� Descricao  � Funcao que determina para quais endere�os de email serao       ���
���            � enviados os avisos de inclusao                                 ���
�������������������������������������������������������������������������������͹��
��� Parametros � Nil                                                            ���
�������������������������������������������������������������������������������͹��
��� Retorno    � Nil                                                            ���
�������������������������������������������������������������������������������͹��
��� Data       � Analista    �Descricao da Alteracao                            ���
���============�=============�==================================================���
��� __/__/____ � ___________ �                                                  ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
Static Function iEmail()
Local cTabela := "SA1"
Local cEmail := ""

SZH->(dbSetOrder(1))
SZH->(dbGoTop())
SZH->(dbSeek(xFilial("SZH") + cTabela))

While ! SZH->(EOF()) .AND. SZH->ZH_TABELA == cTabela
	cEmail += AllTrim(SZH->ZH_EMAIL) + ";"
	SZH->(dbSkip())
EndDo
Return(cEmail)