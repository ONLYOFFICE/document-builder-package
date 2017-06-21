[Setup]
OutputBaseFileName      =onlyoffice-documentbuilder-{#sAppVersion}-x86
MinVersion              =0,5.0.2195
;ShowUndisplayableLanguages = true
;UsePreviousLanguage=no


[Files]
Source: res\vcredist_x86.exe;       DestDir: {app}\; Flags: deleteafterinstall; \
    AfterInstall: installVCRedist(ExpandConstant('{app}\vcredist_x86.exe'), ExpandConstant('{cm:InstallAdditionalComponents}')); Check: not checkVCRedist;
