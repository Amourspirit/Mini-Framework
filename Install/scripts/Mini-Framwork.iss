﻿; Script generated by the Inno Setup Script Wizard.
; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!
#define use_autohotkey

#define MyAppName "Mini-Framework"
#define MyAppVersion "0.4"
#define MyAppMajor "0"
#define MyAppMinor "4"
#define MyAppBuild "0"
#define MyAppRevision "2"
#define MyAppPublisher "Paul Moss"
#define MyAppURL "https://github.com/Amourspirit/Mini-Framework"
#define BaseFw "\Mini_Framwork\0.4"
#define BaseAhk "\AutoHotkey\Lib"
; define MainIncFile "inc_mf_0_3.ahk"
#define Ahk_folder "{reg:HKLM\Software\AutoHotkey,InstallDir|{userdocs}\AutoHotkey}"
#define LibFolder "{reg:HKLM\Software\AutoHotkey,InstallDir|{userdocs}\AutoHotkey}\Lib"
#define HelpFileName "Mini-Framework.chm"
; {userdocs} & {commondocs}
; The path to the My Documents folder.

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
; version 0.3 AppId={{6FA515F8-A656-467A-A8C1-7BA015060B7C}
AppId={{9501359B-5CBB-46AE-BFC3-F83C574ED641}
AppName={#MyAppName}
AppVersion={#MyAppMajor}.{#MyAppMinor}.{#MyAppBuild}.{#MyAppRevision}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}\{#MyAppMajor}.{#MyAppMinor}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
LicenseFile=..\License.txt
OutputDir={#SourcePath}\bin
OutputBaseFilename=MfSetup
Compression=lzma
SolidCompression=yes
SourceDir=..\..\Framework
VersionInfoProductTextVersion={#MyAppMajor}.{#MyAppMinor}.{#MyAppBuild}.{#MyAppRevision}

PrivilegesRequired=admin
ArchitecturesAllowed=x86 x64 ia64
ArchitecturesInstallIn64BitMode=x64 ia64

;Downloading and installing dependencies will only work if the memo/ready page is enabled (default behaviour)
DisableReadyPage=no
DisableReadyMemo=no
AppCopyright=Copyright (c) 2015-2017 Paul Moss
ShowLanguageDialog=no
LanguageDetectionMethod=none
UninstallDisplayName=Mini-Framework for AutoHotkey, version {#MyAppVersion}
VersionInfoTextVersion={#MyAppMajor}.{#MyAppMinor}.{#MyAppBuild}.{#MyAppRevision}
VersionInfoDescription=Mini-Framework for AutoHotkey
VersionInfoCopyright=2015-2017 Paul Moss
VersionInfoProductName=Mini-Framework
VersionInfoProductVersion={#MyAppMajor}.{#MyAppMinor}.{#MyAppBuild}.{#MyAppRevision}
VersionInfoVersion={#MyAppMajor}.{#MyAppMinor}.{#MyAppBuild}.{#MyAppRevision}

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "de"; MessagesFile: "compiler:Languages\German.isl"

[Registry]
Root: HKLM; Subkey: "Software\{#MyAppName}";
Root: HKLM; Subkey: "Software\{#MyAppName}\{#MyAppVersion}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\{#MyAppName}\{#MyAppVersion}"; ValueType: string; ValueName: "InstallDir"; ValueData: "{#LibFolder}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\{#MyAppName}\{#MyAppVersion}"; ValueType: string; ValueName: "ProgramDir"; ValueData: "{pf}\{#MyAppName}\{#MyAppVersion}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\{#MyAppName}\{#MyAppVersion}"; ValueType: string; ValueName: "HelpFile"; ValueData: "{pf}\{#MyAppName}\{#MyAppVersion}\{#HelpFileName}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\{#MyAppName}\{#MyAppVersion}"; ValueType: string; ValueName: "MainIncFile"; ValueData: "{#LibFolder}\inc_mf_{#MyAppMajor}_{#MyAppMinor}.ahk"; Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\{#MyAppName}\{#MyAppVersion}"; ValueType: string; ValueName: "ResDir"; ValueData: "{#LibFolder}{#BaseFw}\System\Resource"; Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\{#MyAppName}\{#MyAppVersion}"; ValueType: string; ValueName: "Version"; ValueData: {code:VersionFull}; Flags: uninsdeletekey

[Files]
;Source: "D:\Users\Paul\Documents\AutoHotkey\Scripts\Framework\Mini_Framework\Project\master\License.txt"; DestDir: "{#LibFolder}\{#BaseFw}"; Flags: ignoreversion
Source: "..\License.txt"; DestDir: "{pf}\{#MyAppName}\{#MyAppVersion}"; Flags: ignoreversion 
Source: "..\Documentation\{#HelpFileName}"; DestDir: "{pf}\{#MyAppName}\{#MyAppVersion}"; Flags: ignoreversion 
Source: "inc_mf_{#MyAppMajor}_{#MyAppMinor}.ahk"; DestDir: "{#LibFolder}"; Flags: ignoreversion 
Source: "inc_mf_System_IO_{#MyAppMajor}_{#MyAppMinor}.ahk"; DestDir: "{#LibFolder}"; Flags: ignoreversion 
Source: "src\System\MfArgumentException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfArgumentNullException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfArgumentOutOfRangeException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfArithmeticException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfOutOfMemoryException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfDivideByZeroException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfAttribute.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfBidiCategory.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfByte.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfBool.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfChar.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfCharUnicodeInfo.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfCollection.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfCollectionBase.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfDateTime.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfDictionary.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfDictionarybase.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfDictionaryEntry.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfDigitShapes.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfEnum.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfEnumerableBase.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfCast.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfConvert.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfByteConverter.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfNibConverter.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfBinaryConverter.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfMath.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfNumber.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfMemoryString.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfBigMathInt.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfBigInt.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfEnvironment.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfEqualityComparerBase.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfEqualsOptions.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfSetFormatNumberType.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfMidpointRounding.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfFlagsAttribute.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfFloat.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfFormatException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfFormatProvider.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfFrameWorkOptions.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfTypeCode.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\Mfunc.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfGenericList.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfListVar.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfIntList.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfByteList.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfNibbleList.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfBinaryList.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfCharList.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfIndexOutOfRangeException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfInfo.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfInt16.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfInteger.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfInt64.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfInvalidCastException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfInvalidOperationException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfList.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfListBase.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfMemberAccessException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfMissingFieldException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfMissingMemberException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfMissingMethodException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfNameObjectCollectionBase.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfNonMfObjectException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfNotImplementedException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfNotSupportedException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfNull.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfNullReferenceException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfNumberFormatInfo.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfNumberFormatInfoBase.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfNumberStyles.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfObject.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfOrdinalComparer.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfOverflowException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfParams.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfPrimitive.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfPrimitives.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfQueue.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfResourceManager.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfResourceSingletonBase.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfSingletonBase.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfStack.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfHashTable.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfString.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfStringComparison.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfStringSplitOptions.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfSystemException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfTimeSpan.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfUint16.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfUInt32.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfUInt64.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfSByte.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfType.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfUnicodeCategory.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfValueType.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfVersion.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System"; Flags: ignoreversion
Source: "src\System\MfUnicode\libmySQL.dll"; DestDir: "{#LibFolder}\{#BaseFw}\System\\MfUnicode\"; Flags: ignoreversion
Source: "src\System\MfUnicode\MfDataBaseFactory.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System\\MfUnicode\"; Flags: ignoreversion
Source: "src\System\MfUnicode\MfDbUcdAbstract.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System\\MfUnicode\"; Flags: ignoreversion
Source: "src\System\MfUnicode\MfRecordSetSqlLite.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System\\MfUnicode\"; Flags: ignoreversion
Source: "src\System\MfUnicode\MfSQLite_L.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System\\MfUnicode\"; Flags: ignoreversion
Source: "src\System\MfUnicode\MfUcdDb.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System\\MfUnicode\"; Flags: ignoreversion
Source: "src\System\MfUnicode\UCDSqlite.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System\\MfUnicode\"; Flags: ignoreversion
Source: "src\System\Resource\MfResource_Core_en-US.dll"; DestDir: "{#LibFolder}\{#BaseFw}\System\Resource"; Flags: ignoreversion
Source: "src\System\Resource\sqlite3.def"; DestDir: "{#LibFolder}\{#BaseFw}\System\Resource"; Flags: ignoreversion
Source: "src\System\Resource\sqlite3.dll"; DestDir: "{#LibFolder}\{#BaseFw}\System\Resource"; Flags: ignoreversion
Source: "src\System\Resource\ucd.db"; DestDir: "{#LibFolder}\{#BaseFw}\System\Resource"; Flags: ignoreversion
Source: "src\System\Resource\x64\libmySQL.dll"; DestDir: "{#LibFolder}\{#BaseFw}\System\Resource\x64"; Flags: ignoreversion
Source: "src\System\Resource\x64\sqlite3.dll"; DestDir: "{#LibFolder}\{#BaseFw}\System\Resource\x64"; Flags: ignoreversion
; Source: "src\System\Resource\Resources\Strings.ini"; DestDir: "{#LibFolder}\{#BaseFw}\System\Resource\Resources\"; Flags: ignoreversion
Source: "src\System\IO\MfDirectoryNotFoundException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System\IO"; Flags: ignoreversion
Source: "src\System\IO\MfDriveNotFoundException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System\IO"; Flags: ignoreversion
Source: "src\System\IO\MfFileNotFoundException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System\IO"; Flags: ignoreversion
Source: "src\System\IO\MfIOException.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System\IO"; Flags: ignoreversion
Source: "src\System\Text\MfText.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System\Text"; Flags: ignoreversion
Source: "src\System\Text\MfStringBuilder.ahk"; DestDir: "{#LibFolder}\{#BaseFw}\System\Text"; Flags: ignoreversion


[Icons]
Name: "{group}\{#MyAppVersion}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\{#MyAppVersion}\License"; Filename: "{app}\License.txt"
Name: "{group}\{#MyAppVersion}\Help"; Filename: "{app}\Mini-Framework.chm"

[Code]
// shared code for installing the products
#include "scripts\products.iss"
// helper functions
#include "scripts\products\stringversion.iss"
#include "scripts\products\winversion.iss"
#include "scripts\products\fileversion.iss"

#ifdef use_autohotkey
#include "scripts\products\autohotkey.iss"
#endif


function InitializeSetup(): boolean;
begin
	// initialize windows version
	initwinversion();
#ifdef use_autohotkey
   autohotkey('1.1.23')
#endif
  Result := true;
end;

function VersionFull(Param: String): String;
begin
  Result := '{#MyAppMajor}'+'.'+'{#MyAppMinor}'+'.'+'{#MyAppBuild}'+'.'+'{#MyAppRevision}';
end;
