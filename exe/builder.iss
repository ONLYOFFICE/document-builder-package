; -- Document Builder Installer --

#ifndef BRANDING_DIR
  #define BRANDING_DIR '.'
#endif

#include BRANDING_DIR + '\defines.iss'

#ifndef VERSION
  #define VERSION '0.0.0.0'
#endif
#define ARCH 'x64'
#define NAME_EXE_OUT 'docbuilder.exe'
#ifndef BASE_DIR
  #define BASE_DIR '..\base'
#endif
#ifndef OUTPUT_DIR
  #define OUTPUT_DIR '.'
#endif
#ifndef OUTPUT_BASENAME
  #define OUTPUT_BASENAME sIntCompanyName + '_' + sIntProductName + '_' + VERSION + '_' + ARCH
#endif

#if FileExists(BRANDING_DIR + '\branding.iss')
  #include BRANDING_DIR + '\branding.iss')
#endif

[Setup]
AppName                   ={#sAppName}
AppVerName                ={#sAppName} {#Copy(VERSION,1,RPos('.',VERSION)-1)}
AppVersion                ={#VERSION}
VersionInfoVersion        ={#VERSION}
OutputBaseFileName        ={#OUTPUT_BASENAME}

AppPublisher              ={#sPublisherName}
AppPublisherURL           ={#sPublisherURL}
AppSupportURL             ={#sSupportURL}
AppCopyright              ={#sCopyright}

ArchitecturesAllowed      =x64
ArchitecturesInstallIn64BitMode=x64

DefaultGroupName          ={#sAppPath}
WizardImageFile           ={#BRANDING_DIR}\res\dialogpicture.bmp
WizardSmallImageFile      ={#BRANDING_DIR}\res\dialogicon.bmp
LicenseFile               ={#BRANDING_DIR}\res\LICENSE.rtf

UsePreviousAppDir         = no
DirExistsWarning          = no
DefaultDirName            ={pf}\{#sAppPath}
DisableProgramGroupPage   = yes
DisableWelcomePage        = no
AllowNoIcons              = yes
UninstallDisplayIcon      = {app}\{#NAME_EXE_OUT}
OutputDir                 = {#OUTPUT_DIR}
Compression               = lzma
PrivilegesRequired        = admin
;ChangesEnvironment        = yes
SetupMutex                = ASC
AppMutex                  = TEAMLAB
DEPCompatible             = no
LanguageDetectionMethod   = none
;ShowUndisplayableLanguages = true
;UsePreviousLanguage=no

#ifdef SIGN
SignTool=byparam $p
#endif

[Languages]
#ifdef _ONLYOFFICE
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"
#else
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "en"; MessagesFile: "compiler:Default.isl"
#endif

[CustomMessages]
;======================================================================================================
en.Launch =Launch %1
ru.Launch =Запустить %1
;de.Launch =%1 starten
;fr.Launch =Lancer %1
;es.Launch =Ejecutar %1
;it.Launch =Eseguire %1
;======================================================================================================
en.CreateDesktopIcon =Create %1 &desktop icon
ru.CreateDesktopIcon =Создать иконку %1 на &рабочем столе
;de.CreateDesktopIcon =%1 &Desktop-Icon erstellen
;fr.CreateDesktopIcon =Crйer l'icфne du bureau pour %1
;es.CreateDesktopIcon =Crear %1 &icono en el escritorio
;it.CreateDesktopIcon =Creare un collegamento %1 sul &desktop
;======================================================================================================
en.InstallAdditionalComponents =Installing additional system components. Please wait...
ru.InstallAdditionalComponents =Установка дополнительных системных компонентов. Пожалуйста, подождите...
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
en.Uninstall =Uninstall
ru.Uninstall =Удаление
;de.Uninstall =Deinstallieren
;fr.Uninstall =Desinstaller
;es.Uninstall =Desinstalar
;it.Uninstall =Disinstalla
;======================================================================================================
en.WarningWrongArchitecture =You are trying to install the %1-bit application version over the %2-bit version installed. Please uninstall the previous version first or download the correct version for installation.
ru.WarningWrongArchitecture =Вы устанавливаете %1-битную версию приложения на уже установленную %2-битную. Пожалуйста, удалите предыдущую версию приложения или скачайте подходящую.
;de.WarningWrongArchitecture =Sie versuchen die %1-Bit-Version der Anwendung über die %2-Bit-Version, die schon installiert ist, zu installieren. Entfernen Sie bitte die Vorgängerversion zuerst oder laden Sie die richtige Version für die Installation herunter.
;fr.WarningWrongArchitecture =Vous essayez d'installer la version %1-bit sur la version %2-bit déjà installée. Veuillez désinstaller l'ancienne version d'abord ou télécharger la version correcte à installer.
;es.WarningWrongArchitecture =Usted está tratando de instalar la versión de la aplicación de %1 bits sobre la versión de %2 bits instalada. Por favor, desinstale la versión anterior primero o descargue la versión correcta para la instalación.
;it.Uninstall =Disinstalla
;======================================================================================================

[Files]
Source: {#BASE_DIR}\*; DestDir: {app}; Flags: ignoreversion recursesubdirs;
Source: {#BASE_DIR}\docbuilder.com.dll; DestDir: {app}; Flags: ignoreversion regserver

Source: {#BRANDING_DIR}\res\license.htm; DestDir: {app};
Source: {#BRANDING_DIR}\res\readme.txt; DestDir: {app}; Flags: isreadme;

[Icons]
Name: {group}\README;           Filename: {app}\readme.txt;   WorkingDir: {app}; 
Name: {group}\LICENSE;          Filename: {app}\license.htm;  WorkingDir: {app};
Name: {group}\Help;             Filename: {#sHelpURL};
Name: {group}\{cm:Uninstall};   Filename: {uninstallexe};     WorkingDir: {app};

[UninstallDelete]
Type: filesandordirs; Name: "{app}\sdkjs"

[Code]
var
  DownloadPage: TDownloadWizardPage;

function InitializeSetup(): Boolean;
begin
  Result := true;
end;

function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to {tmp}: %s', [FileName]));
  Result := true;
end;

procedure InitializeWizard;
begin
  DownloadPage := CreateDownloadPage(
                    SetupMessage(msgWizardPreparing),
                    SetupMessage(msgPreparingDesc),
                    @OnDownloadProgress);
end;

function checkVCRedist2022(): Boolean;
var
  UpgradeCode: String;
  Path: String;
begin
  Result := true;
  //x86
  UpgradeCode := '{5720EC03-F26F-40B7-980C-50B5D420B5DE}'; 
  Path := 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\' + UpgradeCode
  if Is64BitInstallMode then
  begin
    //x64
    UpgradeCode := '{A181A302-3F6D-4BAD-97A8-A426A6499D78}'; 
    Path := 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' + UpgradeCode  
  end;
  if RegKeyExists(HKLM, Path) then
  begin
    Result := false;
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  ResultCode: Integer;
begin
  Result := true;
  if WizardSilent() = false then
  begin
    case CurPageID of
      wpReady: 
      begin
        if checkVCRedist2022() then
        begin
          DownloadPage.Clear;
          DownloadPage.Add(
            'https://aka.ms/vs/17/release/vc_redist.{#ARCH}.exe',
            'vcredist.{#ARCH}.exe', '');
          DownloadPage.Show;
          DownloadPage.Download;

          Exec(
            '>',
            ExpandConstant('{tmp}') + '\vcredist.{#ARCH}.exe /passive /norestart',
            '',
            SW_SHOW,
            EwWaitUntilTerminated,
            ResultCode);

          DownloadPage.Hide;
        end;
      end;
    end;
  end;
end;
