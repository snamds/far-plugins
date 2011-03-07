{$I Defines.inc}

unit EdtFindCtrl;

{******************************************************************************}
{* (c) 2010 Max Rusov                                                         *}
{*                                                                            *}
{* Edtitor Find Shell                                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixWinUtils,

    PluginW,
    FarColorW,
    FarCtrl,
    FarMatch,
    FarMenu,
    FarColorDlg;


  type
    TMessages = (
      strLang,
      strTitle,
      strError,

      strMFind,
      strMFindAt,
      strMReplace,
      strMReplaceAt,
      strMFindNext,
      strMFindPrev,
      strMFindPickWord,
      strMRemoveHilight,
      strMOptions,

      strSearchFor,
      strReplaceWith,
      strInsRegexp,
      strCaseSens,
      strSubstring,
      strWholeWords,
      strRegExp,
      strReverse,
      strPromptOnReplace,
      strSearchBut,
      strEntireBut,
      strShowAllBut,
      strCountBut,
      strCancelBut,
      strOptionsBut,

      strOptions,
      strMSelectFound,
      strMCursorAtEnd,
      strMCenterAlways,
      strMLoopSearch,
      strMShowAllFound,
      strMPersistMatch,
      strMarkWholeTab,
      strMShowProgress,
      strMGroupUndo,
      strAutoXLATMask,
      strMColors,

      strMShowNumbers,
      strMShowMatches,
      strMTrimSpaces,
      strMAutoSync,
      strMShowHints,

      strMFoundColor,
      strMMatchColor,
      strMSearchResult,
      strMGrepNumColor,
      strMGrepFoundColor,
      strMRestoreDefaults,

      strFind,
      strReplace,
      strFindFor,
      strFoundCount,
      strFoundReplaced,
      strCountResult,
      strNotFound,
      strBadRegexp,

      strSearchResult,

      strConfirm,
      strReplaceWith1,
      strReplaceBut,
      strAllBut,
      strSkipBut,
      strCancelBut1,

      strContinueFromBegin,
      strContinueFromEnd,

      strInterrupt,
      strInterruptPrompt,
      strYes,
      strNo,

      strColorDialog,
      str_CD_Foreground,
      str_CD_Background,
      str_CD_Sample,
      str_CD_Set,
      str_CD_Cancel,

      strRegexpTitle,
      strRegaexpBase
    );


 {-----------------------------------------------------------------------------}

  const
    cDefaultLang   = 'English';
    cPlugRegFolder = 'EdtFind';

    cPluginGUID    = $444E4645;

    cFindHistory   = 'SearchText';
    cReplHistory   = 'ReplaceText';

    cFindDlgID    :TGUID = '{A0562FC4-25FA-48DC-BA5E-48EFA639865F}';
    cReplaceDlgID :TGUID = '{070544C7-E2F6-4E7B-B348-7583685B5647}';
    cGrepDlgID    :TGUID = '{39BE672E-9303-4F06-A38A-ECC35ABD98B6}';


  var
    optSelectFound    :Boolean = True;
    optCursorAtEnd    :Boolean = False;
    optCenterAlways   :Boolean = False;
    optLoopSearch     :Boolean = True;
    optShowAllFound   :Boolean = True;
    optPersistMatch   :Boolean = False;
    optMarkWholeTab   :Boolean = True;
    optShowProgress   :Boolean = True;
    optNoModalMess    :Boolean = False;
    optGroupUndo      :Boolean = True;

    optGrepShowLines  :Boolean = True;
    optGrepTrimSpaces :Boolean = True;
    oprGrepShowMatch  :Boolean = True;
    optGrepAutoSync   :Boolean = True;
    optGrepShowHints  :Boolean = True;
    optGrepMaximized  :Boolean = False;

    optXLatMask       :Boolean = True;   { �������������� XLAT �������������� ��� ������ }

    optCurFindColor   :Integer;
    optMatchColor     :Integer;

    optGrepNumColor   :Integer;
    optGrepFoundColor :Integer;


  type
    TFindOption = (
      foRegexp,
      foCaseSensitive,
      foWholeWords,
      foPromptOnReplace
//    foSelectedOnly
    );
    TFindOptions = set of TFindOption;

  var
    gStrFind :TString;
    gStrRepl :TString;
    gOptions :TFindOptions = [foPromptOnReplace];

    gReverse :Boolean;

    gLastIsReplace :Boolean;
    gLastReplEmpty :Boolean;  { �������, ����� ������ ������ ��������� ������ ������ ������ }

  var
    FRegRoot :TString;

  function GetMsg(AMess :TMessages) :PFarChar;
  function GetMsgStr(AMess :TMessages) :TString;
  procedure AppErrorID(AMess :TMessages);
  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);

  procedure HandleError(AError :Exception);

  procedure SetFindOptions(var AOptions :TFindOptions; AOption :TFindOption; AOn :Boolean);
  function RegexpQuote(const AExpr :TString) :TString;
  function CheckRegexp(const AStr :TString) :Boolean;
  procedure InsertText(const AStr :TString);

  procedure AddToHistory(const AHist, AStr :TString);
  function GetLastHistory(const AHist :TString) :TString;

  procedure SyncFindStr;

  procedure RestoreDefColor;
  procedure ColorMenu;

  procedure ReadSetup;
  procedure WriteSetup;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function GetMsg(AMess :TMessages) :PFarChar;
  begin
    Result := FarCtrl.GetMsg(Integer(AMess));
  end;

  function GetMsgStr(AMess :TMessages) :TString;
  begin
    Result := FarCtrl.GetMsgStr(Integer(AMess));
  end;

  procedure AppErrorID(AMess :TMessages);
  begin
    FarCtrl.AppErrorID(Integer(AMess));
  end;

  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);
  begin
    FarCtrl.AppErrorIdFmt(Integer(AMess), Args);
  end;


  procedure HandleError(AError :Exception);
  begin
    ShowMessage('EdtFind', AError.Message, FMSG_WARNING or FMSG_MB_OK);
  end;


  procedure SetFindOptions(var AOptions :TFindOptions; AOption :TFindOption; AOn :Boolean);
  begin
    if AOn then
      Include(AOptions, AOption)
    else
      Exclude(AOptions, AOption)
  end;


  function RegexpQuote(const AExpr :TString) :TString;
  begin
    if (AExpr <> '') and (AExpr[1] <> '/') then
      Result := '/' + AExpr + '/'
    else
      Result := AExpr;
  end;


  function CheckRegexp(const AStr :TString) :Boolean;
  var
    vRegExp :THandle;
    vStr :TString;
  begin
    if FARAPI.RegExpControl(0, RECTL_CREATE, @vRegExp) = 0 then
      Wrong;
    try
      vStr := RegexpQuote(AStr);
      Result := FARAPI.RegExpControl(vRegExp, RECTL_COMPILE, PTChar(vStr)) <> 0;
    finally
      FARAPI.RegExpControl(vRegExp, RECTL_FREE, nil);
    end;
  end;




  function MaskStr(const AStr :TString) :TString;
  var
    I :Integer;
    C :TChar;
  begin
    Result := '';
    for I := 1 to length(AStr) do begin
      C := AStr[I];
      if (Ord(C) < $20) or (C = '"') or (C = '\') then
//      Result := Result + '\' + Int2Str(Ord(c))
        Result := Result + '\x' + Format('%.2x', [Ord(c)])
      else
        Result := Result + C;
    end;
  end;


  procedure InsertText(const AStr :TString);
  var
    vStr :TString;
  begin
    vStr := 'print("' + MaskStr(AStr) + '")';
    FarPostMacro(vStr);
  end;


 {-----------------------------------------------------------------------------}

  procedure AddToHistory(const AHist, AStr :TString);
  var
    hDlg :THandle;
    vItems :array[0..0] of TFarDialogItem;
  begin
    vItems[0] := NewItemApi(DI_Edit, 0, 0, 5, -1, DIF_HISTORY, '', PTChar(AHist) );
    hDlg := FARAPI.DialogInit(hModule, -1, -1, 9, 2, nil, Pointer(@vItems), 1, 0, 0, nil, 0);
    try
      FARAPI.SendDlgMessage(hDlg, DM_ADDHISTORY, 0, TIntPtr(PTChar(AStr)));
    finally
      FARAPI.DialogFree(hDlg);
    end;
  end;
  

(*
  function DlgGetText(ADlg :THandle; AItemID :Integer) :TFarStr;
  var
    vLen :Integer;
    vData :TFarDialogItemData;
  begin
    Result := '';
    vLen := FARAPI.SendDlgMessage(ADlg, DM_GETTEXTLENGTH, AItemID, 0);
    if vLen > 0 then begin
      SetLength(Result, vLen);
      vData.PtrLength := vLen;
      vData.PtrData := PFarChar(Result);
      FARAPI.SendDlgMessage(ADlg, DM_GETTEXT, AItemID, TIntPtr(@vData));
    end;
  end;


  function GetLastHistory(const AHist :TString) :TString;
  var
    hDlg :THandle;
    vItems :array[0..0] of TFarDialogItem;
  begin
    vItems[0] := NewItemApi(DI_Edit, 0, 0, 5, -1, DIF_HISTORY or DIF_USELASTHISTORY, '', PTChar(AHist) );
    hDlg := FARAPI.DialogInit(hModule, -1, -1, 9, 2, nil, Pointer(@vItems), 1, 0, 0, nil, 0);
    try
      Result := DlgGetText(hDlg, 0);
    finally
      FARAPI.DialogFree(hDlg);
    end;
  end;
*)


  function GetLastHistory(const AHist :TString) :TString;
  var
    vPath, vStr :TString;
    vKey :HKEY;
  begin
    vPath := ExtractFilePath(FRegRoot) + 'SavedDialogHistory\' + AHist;
    if RegOpenRead(HKCU, vPath, vKey) then begin
      try
        vStr := RegQueryStr(vKey, 'Lines', '');
        Result := PTChar(vStr);
      finally
        RegCloseKey(vKey);
      end;
    end;
  end;


  procedure SyncFindStr;
  begin
    if gStrFind = '' then
      gStrFind := GetLastHistory(cFindHistory);
  end;


 {-----------------------------------------------------------------------------}

  procedure RestoreDefColor;
  begin
    optCurFindColor   := $2F;
    optMatchColor     := $F0;
    optGrepNumColor   := $08;
    optGrepFoundColor := $0A;
  end;


  procedure ColorMenu;
  var
    vMenu :TFarMenu;
    vBkColor :Integer;
  begin
    vBkColor := FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(COL_MENUTEXT));

    vMenu := TFarMenu.CreateEx(
      GetMsg(strOptions),
    [
      GetMsg(strMFoundColor),
      GetMsg(strMMatchColor),
      GetMsg(strMSearchResult),
      GetMsg(strMGrepNumColor),
      GetMsg(strMGrepFoundColor),
      '',
      GetMsg(strMRestoreDefaults)
    ]);
    try
      vMenu.Items[2].Flags := MIF_SEPARATOR;
      while True do begin
        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0: ColorDlg('', optCurFindColor);
          1: ColorDlg('', optMatchColor);
          2: {};
          3: ColorDlg('', optGrepNumColor, vBkColor);
          4: ColorDlg('', optGrepFoundColor, vBkColor);
          5: {};
          6: RestoreDefColor;
        end;

//      FARAPI.EditorControl(ECTL_REDRAW, nil);
        FARAPI.AdvControl(hModule, ACTL_REDRAWALL, nil);

        WriteSetup;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure ReadSetup;
  var
    vKey :HKEY;
  begin
    if not RegOpenRead(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey) then
      Exit;
    try
      SetFindOptions(gOptions, foCaseSensitive, RegQueryLog(vKey, 'CaseSensitive', foCaseSensitive in gOptions));
      SetFindOptions(gOptions, foWholeWords, RegQueryLog(vKey, 'WholeWords', foWholeWords in gOptions));
      SetFindOptions(gOptions, foRegexp, RegQueryLog(vKey, 'Regexp', foRegexp in gOptions));
      SetFindOptions(gOptions, foPromptOnReplace, RegQueryLog(vKey, 'PromptOnReplace', foPromptOnReplace in gOptions));

      optSelectFound := RegQueryLog(vKey, 'SelectFound', optSelectFound);
      optCursorAtEnd := RegQueryLog(vKey, 'CursorAtEnd', optCursorAtEnd);
      optCenterAlways := RegQueryLog(vKey, 'CenterAlways', optCenterAlways);
      optLoopSearch := RegQueryLog(vKey, 'LoopSearch', optLoopSearch);
      optShowAllFound := RegQueryLog(vKey, 'ShowAllFound', optShowAllFound);
      optPersistMatch := RegQueryLog(vKey, 'PersistentMatches', optPersistMatch);
      optMarkWholeTab := RegQueryLog(vKey, 'MarkWholeTab', optMarkWholeTab);
      optShowProgress := RegQueryLog(vKey, 'ShowProgress', optShowProgress);

      optGroupUndo := RegQueryLog(vKey, 'GroupUndo', optGroupUndo);

      optGrepShowLines := RegQueryLog(vKey, 'GrepShowLines', optGrepShowLines);
      optGrepTrimSpaces := RegQueryLog(vKey, 'GrepTrimSpaces', optGrepTrimSpaces);
      oprGrepShowMatch := RegQueryLog(vKey, 'GrepShowMatch', oprGrepShowMatch);
      optGrepAutoSync := RegQueryLog(vKey, 'GrepAutoSync', optGrepAutoSync);
      optGrepShowHints := RegQueryLog(vKey, 'GrepShowHints', optGrepShowHints);
      optGrepMaximized := RegQueryLog(vKey, 'GrepMaximized', optGrepMaximized);

      optXLatMask := RegQueryLog(vKey, 'XLatMask', optXLatMask);

      optCurFindColor := RegQueryInt(vKey, 'FindColor', optCurFindColor);
      optMatchColor := RegQueryInt(vKey, 'MatchColor', optMatchColor);
      optGrepNumColor := RegQueryInt(vKey, 'GrepNumColor', optGrepNumColor);
      optGrepFoundColor := RegQueryInt(vKey, 'GrepFoundColor', optGrepFoundColor);

    finally
      RegCloseKey(vKey);
    end;
  end;


  procedure WriteSetup;
  var
    vKey :HKEY;
  begin
    RegOpenWrite(HKCU, FRegRoot + '\' + cPlugRegFolder, vKey);
    try
      RegWriteLog(vKey, 'CaseSensitive', foCaseSensitive in gOptions);
      RegWriteLog(vKey, 'WholeWords', foWholeWords in gOptions);
      RegWriteLog(vKey, 'Regexp', foRegexp in gOptions);
      RegWriteLog(vKey, 'PromptOnReplace', foPromptOnReplace in gOptions);

      RegWriteLog(vKey, 'SelectFound', optSelectFound);
      RegWriteLog(vKey, 'CursorAtEnd', optCursorAtEnd);
      RegWriteLog(vKey, 'CenterAlways', optCenterAlways);
      RegWriteLog(vKey, 'LoopSearch', optLoopSearch);
      RegWriteLog(vKey, 'ShowAllFound', optShowAllFound);
      RegWriteLog(vKey, 'PersistentMatches', optPersistMatch);
      RegWriteLog(vKey, 'MarkWholeTab', optMarkWholeTab);
      RegWriteLog(vKey, 'ShowProgress', optShowProgress);

      RegWriteLog(vKey, 'GroupUndo', optGroupUndo);

      RegWriteLog(vKey, 'GrepShowLines', optGrepShowLines);
      RegWriteLog(vKey, 'GrepTrimSpaces', optGrepTrimSpaces);
      RegWriteLog(vKey, 'GrepShowMatch', oprGrepShowMatch);
      RegWriteLog(vKey, 'GrepAutoSync', optGrepAutoSync);
      RegWriteLog(vKey, 'GrepShowHints', optGrepShowHints);
      RegWriteLog(vKey, 'GrepMaximized', optGrepMaximized);

      RegWriteLog(vKey, 'XLatMask', optXLatMask);

      RegWriteInt(vKey, 'FindColor', optCurFindColor);
      RegWriteInt(vKey, 'MatchColor', optMatchColor);
      RegWriteInt(vKey, 'GrepNumColor', optGrepNumColor);
      RegWriteInt(vKey, 'GrepFoundColor', optGrepFoundColor);

    finally
      RegCloseKey(vKey);
    end;
  end;


initialization
  ColorDlgResBase := Byte(strColorDialog);
end.

