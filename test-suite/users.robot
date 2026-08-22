*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    DateTime

Resource    ../resources/variables.robot


*** Test Cases ***

Scenario 1 - Create New employee and Verify ID
    [Documentation]    Create a new user and verify the returned ID is numeric

    Should Not Be Empty    ${TOKEN}

    Create Session
    ...    create user
    ...    ${BASE_URL}
    ...    headers={"Authorization": "Bearer ${TOKEN}", "Content-Type": "application/json"}

    #Create random status
    ${status}=         Evaluate    random.choice(["active", "inactive"])    modules=random
    ${timestamp}=    Get Current Date    result_format=%Y%m%d%H%M%S
    ${email}=    Set Variable    annas.${timestamp}@email.com

    ${body}=    Create Dictionary
    ...    name=Annas test
    ...    gender=male
    ...    email=${email}
    ...    status=${status}

    ${response}=    POST On Session
    ...    create user
    ...    ${USERS}
    ...    json=${body}
    ...    expected_status=201

    ${response_body}=    Set Variable    ${response.json()}

    Log    Created user: ${response_body}

    ${user_id}=    Get From Dictionary
    ...    ${response_body}
    ...    id
    #This one is to verify id returned is INT (number)
    ${user_id}=    Convert To Integer    ${user_id} 

Scenario 2 - Verify Status of First entry
    [Documentation]    Verify the first user status is active or inactive

    Create Session
    ...    get user
    ...    ${BASE_URL}
    ...    headers={"Authorization": "Bearer ${TOKEN}", "Content-Type": "application/json"}

    ${response}=    GET On Session
    ...    get user
    ...    ${USERS}
    ...    expected_status=200

    ${USERS}=    Set Variable    ${response.json()}

    Should Not Be Empty    ${USERS}

    ${first_user}=    Get From List
    ...    ${USERS}
    ...    0

    ${status}=    Get From Dictionary
    ...    ${first_user}
    ...    status

    Log    First user status: ${status}
    
    #To verify the status only active/inactive
    Should Be True
    ...    '${status}' == 'active' or '${status}' == 'inactive'