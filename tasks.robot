
*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.Dialogs

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the intranet website
    ${response.Downloadlink}=    Download excel file
    ${output}=    Read csv file
    FOR    ${row}    IN    @{output}
        Click Ok Button
        fill the robot order from    ${row}
    END
    Create a zip for Reciepts

*** Variables ***
${folder_path}=    ${OUTPUT_DIR}${/}Reciepts

*** Keywords ***
Open the intranet website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    ...    maximized=true

Click Ok Button
    Wait Until Page Contains Element    xpath://button[text()='OK']
    Click Element    xpath://button[text()='OK']

Download excel file
    Add text input    Downloadlink    Label=Enter_the_csv_link
    ${response}=    Run dialog
    [Return]    ${response.Downloadlink}
    #Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Read csv file
    ${table}=    Read table from CSV    orders.csv
    ...    header=true
    [Return]    ${table}

fill the robot order from
    [Arguments]    ${row}
    Wait Until Page Contains Element    head
    Select From List By Value    head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Set Focus To Element    xpath://input[@type="number"]
    Input Text    xpath://input[@type="number"]    ${row}[Legs]
    Set Focus To Element    xpath://input[@type="text"]
    Input Text    xpath://input[@type="text"]    ${row}[Address]
    Click Button    preview
    Wait Until Page Contains Element    id:robot-preview-image
    Click Button    order
    FOR    ${counter}    IN RANGE    10
        ${Check-order-another}=    Is Element Visible    order-another
        IF    ${Check-order-another} == False
            Click Button    order
        ELSE
            Exit For Loop
        END
    END
    ${screenshot}=    Set Variable    ${OUTPUT_DIR}${/}Screenshot${/}${row}[Order number].PNG
    Wait Until Page Contains Element    id:robot-preview-image
    Screenshot    id:robot-preview-image    ${screenshot}
    Wait Until Page Contains Element    id:receipt
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    ${pdf-path}=    Set Variable    ${OUTPUT_DIR}${/}Reciepts${/}${row}[Order number].pdf
    Html To Pdf    ${receipt}    ${pdf-path}
    Open Pdf    ${pdf-path}
    Add Watermark Image To Pdf    ${OUTPUT_DIR}${/}Screenshot${/}${row}[Order number].PNG    ${pdf-path}
    Close Pdf
    Wait Until Page Contains Element    order-another
    Click Button    order-another

Create a zip for Reciepts
    ${Folder-path}=    Set Variable    ${OUTPUT_DIR}/Receipts.zip
    Archive Folder With Zip    ${folder_path}    ${Folder-path}
