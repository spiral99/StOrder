*** Settings ***
Library  RequestsLibrary
Library  Collections
Library  String
Library  BuiltIn
Library  FakerLibrary
Library  DateTime
Library  OperatingSystem
Library  DataDriver  test data\\data.csv
Library  Process
Test Template  Run Each Row As A Single Test Case

*** Variables ***
${BASE_URL}  https://ms-standingorder-gateway.consumer-payments.apps.devocp.safaricom.net
${DeleteSchedule_URL}  https://ms-standingorder-gateway.consumer-payments.apps.hqocp.safaricom.net

*** Test Cases ***
DeleteIndividualReminderSchedule Test Case   ${msisdn}    ${x-user-auth}    ${x-token-key}

*** Keywords ***
Run Each Row As A Single Test Case
    [Tags]    data-driven
    [Arguments]    ${msisdn}    ${x-user-auth}    ${x-token-key}

    Log    Testing with msisdn: ${msisdn}, x-user-auth: ${x-user-auth}, and x-token-key: ${x-token-key}
    Test GET Token Request
    Test Post DeleteIndividualReminderSchedule Request    ${msisdn}    ${x-user-auth}    ${x-token-key}

Test GET Token Request
    ${username}    Set Variable  test
    ${password}    Set Variable  .T$whAceJ?#%&1t)/*@&R&mZO*BfF0vm
    ${auth_string}    Evaluate    "{0}:{1}".format($username, $password)
    ${base64_auth}    Evaluate    $auth_string
    ${headers}    Create Dictionary    Authorization=Basic dGVzdDouVCR3aEFjZUo/IyUmMXQpLypAJlImbVpPKkJmRjB2bQ==
    Create Session    Token    ${BASE_URL}    headers=${headers}
    ${response}    GET On Session    Token    /token
    ${response_body}    Set Variable    ${response.json()}
    Should Be Equal As Strings    ${response.status_code}    200
    ${response_text}    Convert To String    ${response.content}
    Should Contain    ${response_text}   "Token generated successfully"
    ${token}       Evaluate    json.loads('''${response.content}''')["ResponseBody"]["jwt"]["token"]
    Log    Token: ${token}
    Set Global Variable    ${token}

Test Post DeleteIndividualReminderSchedule Request
    ${guid}=  Password  length=18  special_chars=false  digits=True  upper_case=True  lower_case=True
    ${timestamp}=    Get Current Date    result_format=%Y-%m-%d_%H:%M:%S
    Log    Generated GUID: ${guid}
    Log    Timestamp: ${timestamp}

    [Arguments]    ${msisdn}    ${x-user-auth}    ${x-token-key}
    ${token}=    Get Variable Value    ${token}
    ${headers}    Create Dictionary
    ...           x-user-auth=${x-user-auth}
    ...           x-token-key=${x-token-key}
    ...           x-source-msisdn=${token}
    ...           Authorization=Bearer ${token}
    ...           Cookie=b24c6d4b7474117e03f467b43fc0585a=71479e62b7c9844052179744ffc6c48a
    ...           Content-Type=application/json
    ...           Connection=keep-alive
    ...           Accept-Encoding=gzip, deflate, br
    ...           Accept=*/*
    ...           X-Correlation-ConversationID=${guid}
    ...           X-Source-System=dxl-ms-starter
    ...           X-App=web-portal
    ...           Accept=application/json
    ...           x-msisdn=${msisdn}
    ...           x-devicetoken=hjksdsdkjskks
    ...           x-messageID=asasasas|Asasasasaadw|aass22|2asasas
    ...           X-Source-CountryCode=KE
    ...           X-Source-Division=DIT
    ...           X-Source-Operator=Safaricom
    ...           X-Source-Timestamp=${timestamp}
    ...           X-Version=1.0.0
    ...           X-Source-msisdn=${msisdn}
    ...           x-miniapp-session=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VybmFtZSIsImF1ZCI6WyJhZG1pbiIsInVzZXIiXSwiaXNzIjoiZW5jcnlwdGlvbi5zYWZhcmljb20ubmV0IiwiZXhwIjoxNjk1OTcxMDk0LCJpYXQiOjE2OTU5Njc0OTQsImp0aSI6IjQzNzY2NjczLTVmMWQtNDgyYy04ZDVjLWM1NzVjZTQwYWYwZSJ9.hIO06LmV8P7KwW1YtU78Atoy6jxJ2tHxl-IBidmBBQ0
    ...           X-Source-channel=app

    ${body}=    Set Variable    {"receiverPartyIdentifierType":"1","receiverPartyIdentifier":"${msisdn}","reminderScheduleID":"3097105"}

    Create Session    Delete    ${DeleteSchedule_URL}

    ${response}  POST On Session    Delete    /api/v1/deleteIndividualReminderSchedule   data=${body}    headers=${headers}

    Should Be Equal As Strings  ${response.status_code}  200

    ${json_data}  Set Variable  ${response.json()}

    Log    ${response.json()}

    Delete All Sessions
    # Further assertions or verifications can be performed on the response