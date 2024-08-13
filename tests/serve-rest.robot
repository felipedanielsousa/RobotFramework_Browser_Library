Language: Brazilian Portuguese
*** Settings ***
Resource        ../resources/serve-rest.resource
Suite Setup     Cadastrar usuário e logar 
Suite Teardown  Close Browser  ALL
*** Test Cases ***
Login com sucesso server rest front
    [Tags]  login
    Abrir o navegador
    Abrir o site serve rest
    Preencher dados do novo usuario e clicar em cadastrar
    Validar usuário cadastrado com sucesso
   
Desafio 1: Validar novo usuário na lista
    [Tags]  lista_usuario
    Abrir o site serve rest front logado
    Visualizar usuários cadastrados
    Conferir usuário cadastrado com sucesso
Desafio 2: Validar produto cadastrado na listagem
    [Tags]  cad_produto
    Abrir o site serve rest front logado
    Clicar na aba de produtos
    Preencher dados e clicar em cadastrar o produto
    Conferir se o novo produto foi cadastrado com sucesso
Exemplo utilizando o storage armazenado no contexto
    [Tags]  storage_contexto
    Abrir o site serve rest front logado
    Visualizar usuários cadastrados
Exemplo utilizando requisições http
    [Tags]  http
    Abrir o navegador
    Abrir o site serve rest
    Criar um usuário via API
    Logar com o usuário cadastrado via API




    