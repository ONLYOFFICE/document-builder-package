#include "isxdl\isxdl.iss"

[CustomMessages]
DependenciesDir=MyProgramDependencies

en.depdownload_msg=The following applications are required before setup can continue:%n%n%1%nDownload and install now?
; de.depdownload_msg=Die folgenden Programme werden ben�tigt bevor das Setup fortfahren kann:%n%n%1%nJetzt downloaden und installieren?
; fr.depdownload_msg=Les applications suivantes sont n�cessaires avant l'installation peut continuer:%n%n%1%nT�l�chargement et installer maintenant?
; it.depdownload_msg=Le seguenti applicazioni sono necessari per continuare l'installazione:%n%n%1%nScarica ed installare ora?
; nl.depdownload_msg=De volgende toepassingen zijn nodig v��r de installatie kunt doorgaan:%n%n%1%nDownload en installeer nu?
; pl.depdownload_msg=Poni�sze aplikacje s� wymagane przed instalacj� aby m�c kontynuowa�:%n%n%1%nCzy pobra� je i zainstalowa� teraz?

en.depdownload_memo_title=Download dependencies
; de.depdownload_memo_title=Abh�ngigkeiten downloaden
; fr.depdownload_memo_title=T�l�charger les d�pendances
; it.depdownload_memo_title=Scarica le dipendenze
; nl.depdownload_memo_title=Download afhankelijkheden
; pl.depdownload_memo_title=Pobierz zale�no�ci

en.depinstall_memo_title=Install dependencies
; de.depinstall_memo_title=Abh�ngigkeiten installieren
; fr.depinstall_memo_title=Installez les d�pendances
; it.depinstall_memo_title=installare le dipendenze
; nl.depinstall_memo_title=Installeer afhankelijkheden
; pl.depinstall_memo_title=Zainstaluj zale�no�ci

en.depinstall_title=Installing dependencies
; de.depinstall_title=Installiere Abh�ngigkeiten
; fr.depinstall_title=Installation des d�pendances
; it.depinstall_title=installare le dipendenze
; nl.depinstall_title=Installeer afhankelijkheden
; pl.depinstall_title=Instalowanie zale�no�ci

en.depinstall_description=Please wait while Setup installs dependencies on your computer.
; de.depinstall_description=Warten Sie bitte w�hrend Abh�ngigkeiten auf Ihrem Computer installiert wird.
; fr.depinstall_description=S'il vous pla�t patienter pendant que le programme d'installation installe les d�pendances sur votre ordinateur.
; it.depinstall_description=Per favore attendi che viene installato sul computer dipendenze.
; nl.depinstall_description=Een moment geduld aub Setup installeert afhankelijkheden op uw computer.
; pl.depinstall_description=Instalator instaluje zale�no�ci na komputerze, czekaj.

en.depinstall_status=Installing %1...
; de.depinstall_status=Installiere %1...
; fr.depinstall_status=Installation %1...
; it.depinstall_status=installazione %1...
; nl.depinstall_status=Installeren %1...
; pl.depinstall_status=Instalowanie %1....

en.depinstall_missing=%1 must be installed before setup can continue. Please install %1 and run Setup again.
; de.depinstall_missing=%1 muss installiert werden bevor das Setup fortfahren kann. Bitte installieren Sie %1 und starten Sie das Setup erneut.
; fr.depinstall_missing=%1 doit �tre install� avant l'installation peut continuer. S'il vous pla�t installer %1 et ex�cutez � nouveau le programme d'installation.
; it.depinstall_missing=%1 deve essere installato per continuare l'installazione. Si prega di installare %1 ed eseguire nuovamente l'installazione.
; nl.depinstall_missing=%1 moet worden ge�nstalleerd v��r de installatie kan worden voortgezet. Installeer %1 en voer Setup opnieuw uit.
; pl.depinstall_missing=%1 musi by� zainstalowany przed instalacj�, aby mog�a ona by� kontynuowana. Zainstaluj %1 i ponownie uruchom program instalacyjny.

en.depinstall_error=An error occured while installing the dependencies. Please restart the computer and run the setup again or install the following dependencies manually:%n
; de.depinstall_error=Ein Fehler ist w�hrend der Installation der Abgh�ngigkeiten aufgetreten. Bitte starten Sie den Computer neu und f�hren Sie das Setup erneut aus oder installieren Sie die folgenden Abh�ngigkeiten per Hand:%n
; fr.depinstall_error=Une erreur est survenue lors de l'installation des d�pendances . S'il vous pla�t red�marrer l'ordinateur et ex�cuter � nouveau le programme d'installation ou installer les d�pendances suivantes manuellement:%n
; it.depinstall_error=� verificato un errore durante l'installazione le dipendenze . Si prega di riavviare il computer ed eseguire nuovamente la configurazione o installare le seguenti dipendenze manualmente:%n
; nl.depinstall_error=Er is een fout opgetreden tijdens het installeren van de afhankelijkheden. Gelieve de computer opnieuw op en voer de installatie opnieuw uit of de volgende afhankelijkheden handmatig installeren:%n
; pl.depinstall_error=Wyst�pi� b��d podczas instalowania zale�no�ci. Uruchom ponownie komputer, a nast�pnie ponownie uruchom program instalacyjny lub r�cznie zainstaluj nast�puj�ce programy:%n

en.isxdl_langfile=
; de.isxdl_langfile=german.ini
; fr.isxdl_langfile=french3.ini
; it.isxdl_langfile=italian.ini
; nl.isxdl_langfile=dutch.ini
; pl.isxdl_langfile=polish.ini

; [Files]
; Source: "scripts\isxdl\german.ini"; Flags: dontcopy
; Source: "scripts\isxdl\french3.ini"; Flags: dontcopy
; Source: "scripts\isxdl\italian.ini"; Flags: dontcopy
; Source: "scripts\isxdl\dutch.ini"; Flags: dontcopy
; Source: "scripts\isxdl\polish.ini"; Flags: dontcopy

[Code]
type
	TProduct = record
		File: String;
		Title: String;
		Parameters: String;
		ForceSuccess : boolean;
		InstallClean : boolean;
		MustRebootAfter : boolean;
	end;

	InstallResult = (InstallSuccessful, InstallRebootRequired, InstallError);

var
	installMemo, downloadMemo, downloadMessage: string;
	products: array of TProduct;
	delayedReboot, isForcedX86: boolean;
	DependencyPage: TOutputProgressWizardPage;


procedure AddProduct(filename, parameters, title, size, url: string; forceSuccess, installClean, mustRebootAfter : boolean);
var
	path: string;
	i: Integer;
begin
	installMemo := installMemo + '%1' + title + #13;

	path := ExpandConstant('{src}{\}') + CustomMessage('DependenciesDir') + '\' + filename;
	if not FileExists(path) then begin
		path := ExpandConstant('{tmp}{\}') + filename;

		if not FileExists(path) then begin
			isxdl_AddFile(url, path);

			downloadMemo := downloadMemo + '%1' + title + #13;
			downloadMessage := downloadMessage + '	' + title + ' (' + size + ')' + #13;
		end;
	end;

	i := GetArrayLength(products);
	SetArrayLength(products, i + 1);
	products[i].File := path;
	products[i].Title := title;
	products[i].Parameters := parameters;
	products[i].ForceSuccess := forceSuccess;
	products[i].InstallClean := installClean;
	products[i].MustRebootAfter := mustRebootAfter;
end;

function SmartExec(product : TProduct; var resultcode : Integer): boolean;
begin
	if (LowerCase(Copy(product.File, Length(product.File) - 2, 3)) = 'exe') then begin
		Result := Exec(product.File, product.Parameters, '', SW_SHOWNORMAL, ewWaitUntilTerminated, resultcode);
	end else begin
		Result := ShellExec('', product.File, product.Parameters, '', SW_SHOWNORMAL, ewWaitUntilTerminated, resultcode);
	end;
end;

function PendingReboot: boolean;
var	names: String;
begin
	if (RegQueryMultiStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager', 'PendingFileRenameOperations', names)) then begin
		Result := true;
	end else if ((RegQueryMultiStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager', 'SetupExecute', names)) and (names <> ''))  then begin
		Result := true;
	end else begin
		Result := false;
	end;
end;

function InstallProducts: InstallResult;
var
	resultCode, i, productCount, finishCount: Integer;
begin
	Result := InstallSuccessful;
	productCount := GetArrayLength(products);

	if productCount > 0 then begin
		DependencyPage := CreateOutputProgressPage(CustomMessage('depinstall_title'), CustomMessage('depinstall_description'));
		DependencyPage.Show;

		for i := 0 to productCount - 1 do begin
			if (products[i].InstallClean and (delayedReboot or PendingReboot())) then begin
				Result := InstallRebootRequired;
				break;
			end;

			DependencyPage.SetText(FmtMessage(CustomMessage('depinstall_status'), [products[i].Title]), '');
			DependencyPage.SetProgress(i, productCount);

			if SmartExec(products[i], resultCode) then begin
				//setup executed; resultCode contains the exit code
				if (products[i].MustRebootAfter) then begin
					//delay reboot after install if we installed the last dependency anyways
					if (i = productCount - 1) then begin
						delayedReboot := true;
					end else begin
						Result := InstallRebootRequired;
					end;
					break;
				end else if (resultCode = 0) or (products[i].ForceSuccess) then begin
					finishCount := finishCount + 1;
				end else if (resultCode = 3010) then begin
					//Windows Installer resultCode 3010: ERROR_SUCCESS_REBOOT_REQUIRED
					delayedReboot := true;
					finishCount := finishCount + 1;
				end else begin
					Result := InstallError;
					break;
				end;
			end else begin
				Result := InstallError;
				break;
			end;
		end;

		//only leave not installed products for error message
		for i := 0 to productCount - finishCount - 1 do begin
			products[i] := products[i+finishCount];
		end;
		SetArrayLength(products, productCount - finishCount);

		DependencyPage.Hide;
	end;
end;

function PrepareToInstall(var NeedsRestart: boolean): String;
var
	i: Integer;
	s: string;
begin
	delayedReboot := false;

	case InstallProducts() of
		InstallError: begin
			s := CustomMessage('depinstall_error');

			for i := 0 to GetArrayLength(products) - 1 do begin
				s := s + #13 + '	' + products[i].Title;
			end;

			Result := s;
			end;
		InstallRebootRequired: begin
			Result := products[0].Title;
			NeedsRestart := true;

			//write into the registry that the installer needs to be executed again after restart
			RegWriteStringValue(HKEY_CURRENT_USER, 'SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce', 'InstallBootstrap', ExpandConstant('{srcexe}'));
			end;
	end;
end;

function NeedRestart : boolean;
begin
	Result := delayedReboot;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
var
	s: string;
begin
	if downloadMemo <> '' then
		s := s + CustomMessage('depdownload_memo_title') + ':' + NewLine + FmtMessage(downloadMemo, [Space]) + NewLine;
	if installMemo <> '' then
		s := s + CustomMessage('depinstall_memo_title') + ':' + NewLine + FmtMessage(installMemo, [Space]) + NewLine;

	s := s + MemoDirInfo + NewLine + NewLine + MemoGroupInfo

	if MemoTasksInfo <> '' then
		s := s + NewLine + NewLine + MemoTasksInfo;

	Result := s
end;

function DownloadDependency(): boolean;
begin
	Result := true;

		if downloadMemo <> '' then begin
			//change isxdl language only if it is not english because isxdl default language is already english
			if (ActiveLanguage() <> 'en') then begin
				ExtractTemporaryFile(CustomMessage('isxdl_langfile'));
				isxdl_SetOption('language', ExpandConstant('{tmp}{\}') + CustomMessage('isxdl_langfile'));
			end;
			//isxdl_SetOption('title', FmtMessage(SetupMessage(msgSetupWindowTitle), [CustomMessage('appname')]));

			if SuppressibleMsgBox(FmtMessage(CustomMessage('depdownload_msg'), [downloadMessage]), mbConfirmation, MB_YESNO, IDYES) = IDNO then
				Result := false
			else if isxdl_DownloadFiles(StrToInt(ExpandConstant('{wizardhwnd}'))) = 0 then
				Result := false;
		end;
	end;

function IsX86: boolean;
begin
	Result := isForcedX86 or (ProcessorArchitecture = paX86) or (ProcessorArchitecture = paUnknown);
end;

function IsX64: boolean;
begin
	Result := (not isForcedX86) and Is64BitInstallMode and (ProcessorArchitecture = paX64);
end;

function IsIA64: boolean;
begin
	Result := (not isForcedX86) and Is64BitInstallMode and (ProcessorArchitecture = paIA64);
end;

function GetString(x86, x64, ia64: String): String;
begin
	if IsX64() and (x64 <> '') then begin
		Result := x64;
	end else if IsIA64() and (ia64 <> '') then begin
		Result := ia64;
	end else begin
		Result := x86;
	end;
end;

function GetArchitectureString(): String;
begin
	if IsX64() then begin
		Result := '_x64';
	end else if IsIA64() then begin
		Result := '_ia64';
	end else begin
		Result := '';
	end;
end;

procedure SetForceX86(value: boolean);
begin
	isForcedX86 := value;
end;

[Setup]
