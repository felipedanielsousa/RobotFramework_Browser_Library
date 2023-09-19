*** Settings ***
Library    Browser
...        timeout=00:00:05  #setando de espera por elemento(padrão 10s)
#...        enable_presenter_mode=${true}  #Caso o valor seja true, irá executar de forma lenta e destacar o seletor em uso 
Library    FakerLibrary    locale=pt_BR
Library    Screenshot
Library    DateTime

*** Variables ***
${BROWSER}     chromium
${HEADLESS}    ${false}
${BASE_URL}    https://front.serverest.dev/login
*** Keywords ***
Abrir o navegador
    New Browser    browser=${BROWSER}
    ...            headless=${HEADLESS}
     
    ${TRACE_NAME}  FakerLibrary.Uuid 4
    ${NOW}         Get Current Date  result_format=%d-%m-%Y_%H%M%S
    #${OUTPUT_DIR} é uma variável builtin que informa o diretorio de saida dos logs, output e report
    New Context    viewport={'width': 1200, 'height': 800}  
    ...            tracing=${OUTPUT_DIR}/evidencies/traces/${NOW}/${TRACE_NAME}.zip 
    ...            recordVideo={'dir':'${OUTPUT_DIR}/evidencies/videos/${NOW}'}
Abrir o site serve rest
    New Page       url=${BASE_URL}
    ${title}    Get Title  ==  Front - ServeRest 
Preencher dados do novo usuario e clicar em cadastrar
    Click                css=a[data-testid='cadastrar']
    ${USER_NAME}=        FakerLibrary.cpf
    Set Test Variable    ${USER_NAME}
    Fill Text            css=input[data-testid='nome']     ${USER_NAME}    
      
    ${EMAIL}=            FakerLibrary.Email
    Set Test Variable    ${EMAIL}  
    Fill Text       css=input[data-testid='email']     ${EMAIL} 

    ${SENHA}    FakerLibrary.Password
    Fill Text    css=input[data-testid='password']    ${SENHA}

    Check Checkbox    css=input[data-testid='checkbox']
    Click             css=button[data-testid='cadastrar'] 
    
Validar usuário cadastrado com sucesso
    #Wait For Elements State    h1    visible
    Get Text    h1  ==  Bem Vindo ${USER_NAME}
    Get Element States    css=button[data-testid='logout']  validate  value & visible
Cadastrar usuário
    Abrir o navegador
    Abrir o site serve rest
    Preencher dados do novo usuario e clicar em cadastrar
    Validar usuário cadastrado com sucesso
Visualizar usuários cadastrados
    Click       css=a[data-testid='listarUsuarios']
    Get Text    xpath=// h1[text()="Lista dos usuários"]  ==  Lista dos usuários
Conferir usuário cadastrado com sucesso
    ${elemento}      Get Table Cell Element    css=table    "Nome"    "${mail}"
    Get Text  ${elemento}  ==  ${nome}
    Highlight Elements    ${elemento}   
    Take Screenshot       fullPage=${True}
Clicar na aba de produtos
    Click    css=a[data-testid='cadastrar-produtos']
Preencher dados e clicar em cadastrar o produto
    ${name}    FakerLibrary.Word
    Set Test Variable    ${name} 
    Fill Text  css=input[data-testid='nome']    ${name}

    ${price}    FakerLibrary.Random Number  digits=2  fix_len=true
    Fill Text   css=input[data-testid='preco']    ${price}

    ${descricao}    FakerLibrary.Text  max_nb_chars=5
    Set Test Variable    ${descricao}
    Fill Text       css=textarea[data-testid='descricao']    ${descricao}
    
    ${quantity}    FakerLibrary.Random Number  digits=2  fix_len=true
    Fill Text      css=input[data-testid='quantity']    ${quantity}

    Click  css=button[data-testid='cadastarProdutos'] 
Conferir se o novo produto foi cadastrado com sucesso
    ${elemento}  Get Table Cell Element    css=.table.table-striped    "Nome"    "${descricao}"
    Get Text    ${elemento}  ==  ${name}
    Highlight Elements  ${elemento}
    Take Screenshot       fullPage=${True}
   
Criar um usuário via API
    ${mail}  FakerLibrary.Email
    Set Suite Variable    ${mail}

    ${nome}  FakerLibrary.User Name
    Set Suite Variable    ${nome}

    ${SENHA}  FakerLibrary.Password
    Set Suite Variable    ${SENHA}
    ${RESPONSE}  Http    url=https://serverest.dev/usuarios
    ...                  method=POST
    ...                  body= {"nome": "${nome}", "email": "${mail}","password": "${SENHA}","administrador": "true"}
    
    Should Be Equal As Integers    ${RESPONSE["status"]}    201
Logar com o usuário cadastrado via API
    ${RESPONSE}  Http    url=https://serverest.dev/login
    ...                  method=POST
    ...                  body={"email": "${mail}", "password": "${SENHA}"}

    Should Be Equal As Integers    ${RESPONSE["status"]}    200

    LocalStorage Set Item    serverest/userNome     ${nome}
    LocalStorage Set Item    serverest/userEmail    ${mail}
    LocalStorage Set Item    serverest/userToken    ${RESPONSE["body"]["authorization"]}
    
    
    Go To    url=https://front.serverest.dev/admin/home

    Take Screenshot
Cadastrar usuário e logar
    New Browser
    New Page    url=${BASE_URL}
    Criar um usuário via API
    Logar com o usuário cadastrado via API
    ${STORAGE_FILE}    Save Storage State
    Set Suite Variable    ${STORAGE_FILE}
Abrir o site serve rest front logado
    New Browser    browser=${BROWSER}
    ...            headless=${HEADLESS}
    New Context    viewport={'width': 1200, 'height': 720}
    ...            storageState=${STORAGE_FILE}
    New Page       url=https://front.serverest.dev/admin/home
    Get Text       h1  ==  Bem Vindo ${nome}
    Take Screenshot       