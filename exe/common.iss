#ifndef sBrandingFolder
  #define sBrandingFolder   '..\branding'
#endif

#define sBrandingFile str(sBrandingFolder + "\exe\branding.iss")
#if FileExists(sBrandingFile)
  #include str(sBrandingFile)
#endif

#ifndef sCompanyName
  #define sCompanyName      'ONLYOFFICE'
#endif

#ifndef sIntCompanyName
  #define sIntCompanyName   str(sCompanyName)
#endif

#ifndef sProductName
  #define sProductName      'DocumentBuilder'
#endif

#ifndef sIntProductName
  #define sIntProductName   str(sProductName)
#endif

#ifndef sPackageName
  #define sPackageName      str(LowerCase(sCompanyName) + "-" + LowerCase(sProductName))
#endif

#ifndef sPublisherName
  #define sPublisherName    'Ascensio System SIA'
#endif

#ifndef sPublisherUrl
  #define sPublisherUrl     'https://www.onlyoffice.com/'
#endif

#ifndef sSupportURL
  #define sSupportURL       str(sPublisherUrl + "support.aspx")
#endif

#ifndef URL_HELP
  #define URL_HELP          'http://helpcenter.onlyoffice.com/developers/document-builder/index.aspx'
#endif

#ifndef sAppCopyright
  #define sAppCopyright     str("Copyright (C) " + GetDateTimeString('yyyy',,) + " " + sPublisherName)
#endif

#ifndef sWinArch
  #define sWinArch          'x64'
#endif

#if str(sWinArch) == 'x64'
  #define sPlatform         'win_64'
#elif str(sWinArch) == 'x86'
  #define sPlatform         'win_32'
#endif

#ifndef sAppName
  #define sAppName          str(sCompanyName + " " + sProductName)
#endif

#ifndef sAppPath
  #define sAppPath          str(sIntCompanyName + "\" + sIntProductName)
#endif

#define NAME_EXE_OUT        'docbuilder.exe'

#ifndef sAppVerShort
  #define sAppVerShort      '0.0.0'
#endif

#ifndef sAppBuildNumber
  #define sAppBuildNumber   '0'
#endif

#ifndef sAppVersion
  #define sAppVersion       str(sAppVerShort + '.' + sAppBuildNumber)
#endif

[Setup]
AppName                   ={#sAppName}
AppVerName                ={#sAppName} {#sAppVerShort}
AppVersion                ={#sAppVersion}
VersionInfoVersion        ={#sAppVersion}
OutputBaseFileName        ={#sPackageName}-{#sAppVersion}-{#sWinArch}

AppPublisher              ={#sPublisherName}
AppPublisherURL           ={#sPublisherURL}
AppSupportURL             ={#sSupportURL}
AppCopyright              ={#sAppCopyright}

ArchitecturesAllowed      ={#sWinArch}
#if str(sWinArch) == 'x64'
  ArchitecturesInstallIn64BitMode=x64
#endif

DefaultGroupName          ={#sAppPath}
WizardImageFile           ={#sBrandingFolder}\exe\res\dialogpicture.bmp
WizardSmallImageFile      ={#sBrandingFolder}\exe\res\dialogicon.bmp
LicenseFile               = .\LICENSE.rtf

UsePreviousAppDir         = no
DirExistsWarning          = no
DefaultDirName            =C:\{#sAppPath}
DisableProgramGroupPage   = yes
DisableWelcomePage        = no
AllowNoIcons              = yes
UninstallDisplayIcon      = {app}\{#NAME_EXE_OUT}
OutputDir                 = .\
Compression               = lzma
PrivilegesRequired        = admin
;ChangesEnvironment        = yes
SetupMutex                = ASC
MinVersion                =0,5.0.2195
AppMutex                  = TEAMLAB
DEPCompatible             = no

#ifdef ENABLE_SIGNING
SignTool=byparam $p
#endif

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"

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

[Files]
Source: ..\..\build_tools\out\{#sPlatform}\{#sAppPath}\*;    DestDir: {app}; Flags: ignoreversion recursesubdirs;
Source: ..\..\build_tools\out\{#sPlatform}\{#sAppPath}\docbuilder.com.dll;    DestDir: {app}; Flags: ignoreversion regserver

Source: {#sBrandingFolder}\exe\res\license.htm;               DestDir: {app};
Source: {#sBrandingFolder}\exe\res\readme.txt;                DestDir: {app}; Flags: isreadme;

[Icons]
Name: {group}\README;           Filename: {app}\readme.txt;   WorkingDir: {app}; 
Name: {group}\LICENSE;          Filename: {app}\license.htm;  WorkingDir: {app};
Name: {group}\Samples;          Filename: {app}\samples.bat;  WorkingDir: {app};
Name: {group}\Help;             Filename: {#URL_HELP};
Name: {group}\{cm:Uninstall};   Filename: {uninstallexe};     WorkingDir: {app};

[Run]
Filename: {app}\samples.bat;   Description: {cm:RunSamples}; WorkingDir: {app}; Flags: postinstall nowait;

; shared code for installing the products
#include "scripts\products.iss"
; helper functions
#include "scripts\products\stringversion.iss"
#include "scripts\products\winversion.iss"
#include "scripts\products\fileversion.iss"

#include "scripts\products\msiproduct.iss"
#include "scripts\products\vcredist2010sp1.iss"
#include "scripts\products\vcredist2013.iss"

[Code]
function InitializeSetup(): Boolean;
begin
  // initialize windows version
  initwinversion();
  
  vcredist2010();
  vcredist2013();

  Result := true;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := true;
  if WizardSilent() = false then
  begin
    case CurPageID of
      wpReady: Result := DownloadDependency();
    end;
  end;
end;
