; Uncomment the line below to be able to compile the script from within the IDE.
;#define COMPILE_FROM_IDE

#define sAppName            'ONLYOFFICE Document Builder'
#define APP_PATH            'ONLYOFFICE\DocumentBuilder'
#define NAME_EXE_OUT        'docbuilder.exe'
#define URL_HELP            'http://helpcenter.onlyoffice.com/developers/document-builder/index.aspx'

#ifndef COMPILE_FROM_IDE
#define sAppVersion         '{{PRODUCT_VERSION}}.{{BUILD_NUMBER}}'
#else
#define sAppVersion         '0.0.0.0'
#endif

#define sAppVerShort        Copy(sAppVersion, 0, 3)

[Setup]
AppName                   ={#sAppName}
AppVerName                ={#sAppName} {#sAppVerShort}
AppVersion                ={#sAppVersion}
VersionInfoVersion        ={#sAppVersion}

AppPublisher              = Ascensio System SIA.
AppPublisherURL           = http://www.onlyoffice.com/
AppSupportURL             = http://www.onlyoffice.com/support.aspx
AppCopyright              = Copyright (C) 2016 Ascensio System SIA.

DefaultGroupName          = ONLYOFFICE\Document Builder
WizardImageFile           = res\dialogpicture.bmp
WizardSmallImageFile      = res\dialogicon.bmp
LicenseFile               = .\LICENSE.rtf

UsePreviousAppDir         = no
DirExistsWarning          = no
DefaultDirName            = C:\{#APP_PATH}
DisableProgramGroupPage   = yes
DisableWelcomePage        = no
AllowNoIcons              = yes
UninstallDisplayIcon      = {app}\{#NAME_EXE_OUT}
OutputDir                 = .\
Compression               = lzma
PrivilegesRequired        = admin
;ChangesEnvironment        = yes
SetupMutex                = ASC
AppMutex                  = TEAMLAB

[CustomMessages]
;======================================================================================================
Launch =Launch %1
;ru.Launch =Запустить %1
;de.Launch =%1 starten
;fr.Launch =Lancer %1
;es.Launch =Ejecutar %1
;it.Launch =Eseguire %1
;======================================================================================================
CreateDesktopIcon =Create %1 &desktop icon
;ru.CreateDesktopIcon =Создать иконку %1 на &рабочем столе
;de.CreateDesktopIcon =%1 &Desktop-Icon erstellen
;fr.CreateDesktopIcon =Crйer l'icфne du bureau pour %1
;es.CreateDesktopIcon =Crear %1 &icono en el escritorio
;it.CreateDesktopIcon =Creare un collegamento %1 sul &desktop
;======================================================================================================
InstallAdditionalComponents =Installing additional system components. Please wait...
;ru.InstallAdditionalComponents =Установка дополнительных системных компонентов. Пожалуйста, подождите...
;de.InstallAdditionalComponents =Installation zusдtzlicher Systemkomponenten. Bitte warten...
;fr.InstallAdditionalComponents =L'installation des composants supplйmentaires du systиme. Attendez...
;es.InstallAdditionalComponents =Instalando componentes adicionales del sistema. Por favor espere...
;it.InstallAdditionalComponents =Installazione dei componenti addizionali del sistema. Per favore, attendi...
;======================================================================================================
;en.AdditionalTasks =Tasks:
;ru.AdditionalTasks =Задачи:
; de.AdditionalTasks =Aufgaben:
;fr.AdditionalTasks =Tвches:
;es.AdditionalTasks =Tareas:
;it.AdditionalTasks =Compiti:
;======================================================================================================
Uninstall =Uninstall
;ru.Uninstall =Удаление
;de.Uninstall =Deinstallieren
;fr.Uninstall =Desinstaller
;es.Uninstall =Desinstalar
;it.Uninstall =Disinstalla
;======================================================================================================
WarningWrongArchitecture =You are trying to install the %1-bit application version over the %2-bit version installed. Please uninstall the previous version first or download the correct version for installation.
;ru.WarningWrongArchitecture =Вы устанавливаете %1-битную версию приложения на уже установленную %2-битную. Пожалуйста, удалите предыдущую версию приложения или скачайте подходящую.
;de.WarningWrongArchitecture =Sie versuchen die %1-Bit-Version der Anwendung über die %2-Bit-Version, die schon installiert ist, zu installieren. Entfernen Sie bitte die Vorgängerversion zuerst oder laden Sie die richtige Version für die Installation herunter.
;fr.WarningWrongArchitecture =Vous essayez d'installer la version %1-bit sur la version %2-bit déjà installée. Veuillez désinstaller l'ancienne version d'abord ou télécharger la version correcte à installer.
;es.WarningWrongArchitecture =Usted está tratando de instalar la versión de la aplicación de %1 bits sobre la versión de %2 bits instalada. Por favor, desinstale la versión anterior primero o descargue la versión correcta para la instalación.
;it.Uninstall =Disinstalla
;======================================================================================================

RunSamples =Generate samples documents

[Code]
procedure installVCRedist(FileName, LabelCaption: String);
var
  Params:    String;
  ErrorCode: Integer;
begin
  if Length(LabelCaption) > 0 then WizardForm.StatusLabel.Caption := LabelCaption;

  Params := '/quiet';

  ShellExec('', FileName, Params, '', SW_SHOW, ewWaitUntilTerminated, ErrorCode);

  WizardForm.StatusLabel.Caption := SetupMessage(msgStatusExtractFiles);
end;

function GetHKLM: Integer;
begin
  if IsWin64 then
    Result := HKLM64
  else
    Result := HKEY_LOCAL_MACHINE;
end;

function checkVCRedist: Boolean;
var
  isExists: Boolean;
begin
  isExists := False;

  if not IsWin64 or Is64BitInstallMode then
    isExists := RegKeyExists(GetHKLM(), 'SOFTWARE\Microsoft\DevDiv\vc\Servicing\12.0\RuntimeMinimum')
  else
    isExists := RegKeyExists(GetHKLM(), 'SOFTWARE\Wow6432Node\Microsoft\DevDiv\vc\Servicing\12.0\RuntimeMinimum');

  Result := isExists;
end;

[Files]
Source: ..\..\documentbuilder-{#sAppVerShort}-{#sAppArch}\*;    DestDir: {app};


Source: res\license.htm;                                  DestDir: {app};
Source: res\readme.txt;                                   DestDir: {app}; Flags: isreadme;

[Icons]
Name: {group}\README;           Filename: {app}\readme.txt;   WorkingDir: {app}; 
Name: {group}\LICENSE;          Filename: {app}\license.htm;  WorkingDir: {app};
Name: {group}\Samples;          Filename: {app}\samples.bat;  WorkingDir: {app};
Name: {group}\Help;             Filename: {#URL_HELP};
Name: {group}\{cm:Uninstall};   Filename: {uninstallexe};     WorkingDir: {app};

[Run]
Filename: {app}\samples.bat;   Description: {cm:RunSamples}; WorkingDir: {app}; Flags: postinstall nowait;
