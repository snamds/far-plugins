{------------------------------------------------------------------------------}

{$Define Unicode}              { �� ��������� ���������� Unicode ������ }

{$ifdef Debug}
  { ������� }
  {$Define bDebug}       
  {$Define bTrace}
  {$Define bAsserts}
  {$Define bMemCheck}
{$else}
  { ������ }
  {$Define bRelease}
  {$Define bOptimization}
{$endif bRelease}

{$ifdef bTrace}
 {$Define bTraceError}
 {$Define bStackFrames}
{$endif bTrace}

{$Define bDebugInfo}
{$Define bWindows}

{$ifdef ANSI}
  {$Undef Unicode}
{$endif ANSI}

{$ifdef Unicode}
  {$Define bUnicode}           { ������������ ������� - � unicode }
  {$Define bUnicodeFar}        { Far 2 API }
{$endif Unicode}

{------------------------------------------------------------------------------}

{$ifdef FPC}
  {Free Pascal}

  {$Define bFreePascal}
  {$Define bInline}
  {-$Define bUnicodeStr}        { �������������� ��� UnicodeString }

  {$ifdef CPUX86_64}
   {$Define b64}
  {$endif CPUX86_64}

  {$ifdef Ver2_3}
   {$Define bFPC23}
  {$endif Ver2_3}

  {$ifdef Ver2_4}
   {$Define bFPC23}
   {$Define bFPC24}
  {$endif Ver2_4}

{$else}
  {Delphi}

  {$Define bDelphi}

  {$ifdef Ver120}
   {$Define bDelphi4}
  {$endif Ver120}

  {$ifdef Ver130}
   {$Define bDelphi4}
   {$Define bDelphi5}
  {$endif Ver130}

  {$ifdef Ver140}
   {$Define bDelphi4}
   {$Define bDelphi5}
   {$Define bDelphi6}
  {$endif Ver140}

  {$ifdef Ver150}
   {$Define bDelphi4}
   {$Define bDelphi5}
   {$Define bDelphi6}
   {$Define bDelphi7}
  {$endif Ver150}

  {$ifdef Ver170}
   {$Define bDelphi4}
   {$Define bDelphi5}
   {$Define bDelphi6}
   {$Define bDelphi7}
   {$Define bDelphi8}
   {$Define bDelphi9}
  {$endif Ver150}

  {$ifdef Ver180}
   {$Define bDelphi4}
   {$Define bDelphi5}
   {$Define bDelphi6}
   {$Define bDelphi7}
   {$Define bDelphi8}
   {$Define bDelphi9}
   {$Define bDelphi10}  { D2006 }
  {$endif Ver180}

  {$ifdef Ver200}
   {$Define bDelphi4}
   {$Define bDelphi5}
   {$Define bDelphi6}
   {$Define bDelphi7}
   {$Define bDelphi8}
   {$Define bDelphi9}
   {$Define bDelphi10}
   {$Define bDelphi11}
   {$Define bDelphi12}  { D2009 }
  {$endif}

  {$ifdef Ver210}
   {$Define bDelphi4}
   {$Define bDelphi5}
   {$Define bDelphi6}
   {$Define bDelphi7}
   {$Define bDelphi8}
   {$Define bDelphi9}
   {$Define bDelphi10}
   {$Define bDelphi11}
   {$Define bDelphi12}
   {$Define bDelphi13}  { D2010 }
  {$endif}

  {$ifdef Ver220}       
   {$Define bDelphi4}
   {$Define bDelphi5}
   {$Define bDelphi6}
   {$Define bDelphi7}
   {$Define bDelphi8}
   {$Define bDelphi9}
   {$Define bDelphi10}
   {$Define bDelphi11}
   {$Define bDelphi12}
   {$Define bDelphi13}
   {$Define bDelphi14}  { Delphi XE }
  {$endif}

  {$ifdef Ver230}
   {$Define bDelphi4}
   {$Define bDelphi5}
   {$Define bDelphi6}
   {$Define bDelphi7}
   {$Define bDelphi8}
   {$Define bDelphi9}
   {$Define bDelphi10}
   {$Define bDelphi11}
   {$Define bDelphi12}
   {$Define bDelphi13}
   {$Define bDelphi14} 
   {$Define bDelphi15}  { Delphi XE2 (Pulsar) - ������ ������ � 64-� ��������� ������������ }
  {$endif}

  {$ifdef Ver240}
   {$Define bDelphi4}
   {$Define bDelphi5}
   {$Define bDelphi6}
   {$Define bDelphi7}
   {$Define bDelphi8}
   {$Define bDelphi9}
   {$Define bDelphi10}
   {$Define bDelphi11}
   {$Define bDelphi12}
   {$Define bDelphi13}
   {$Define bDelphi14}  
   {$Define bDelphi15}  
   {$Define bDelphi16}  { Delphi XE3 }
  {$endif}

  {$ifdef Win32}
  {$endif}

  {$ifdef Win64}
   {$Define b64}
  {$endif}

  {$ifdef bDelphi12}
   {$Define bInline}
   {$Define bUnicodeStr}  { �������������� ��� UnicodeString }
   {$Define bUnicodeRTL}

   {$Undef bMemCheck}     { ���� �� �������������� }
  {$endif}

  {$ifdef b64}
   {$Define bDelphi64}
   {$Define bStackX64}    { ����� ������ �����, ��� ������������� RBP }
  {$else}
   {$Define bOldLocalCall}
  {$endif b64}

{$endif FPC}


{-$ifndef bUnicodeStr}
 {$Define bWideStr}       { �������������� ��� WideString }
{-$endif bUnicodeStr}


{------------------------------------------------------------------------------}

{$I DefApp.inc}

{------------------------------------------------------------------------------}

{ ����� �������������... }
{$BoolEval Off}
{$IOChecks Off}
{$LongStrings On}
{$MinEnumSize 1}

{ ����� ����������... }
{$ExtendedSyntax On}
{$TypedAddress On}
{$WriteableConst Off}

{ ������ ��� �������� �����... }
{$OpenStrings On}
{$VarStringChecks On}

{$ifdef bDelphi12}
 {$StringChecks Off}
{$endif bDelphi12}

{$ifdef bDelphi16}
 {$StrongLinkTypes Off} 
{$endif bDelphi16}

{$ifdef bFreePascal}
  {Free Pascal}
  {$Align On}
  {$SmartLink On}
  {$AsmMode Intel}
  {$packset 1}
{$else}
//{$ifdef bDelphiXE2}
// {$Align 8}
//{$else}
   {$Align On}
//{$endif bDelphiXE2}
  {$SafeDivide Off}
{$endif bFreePascal}

{------------------------------------------------------------------------------}

{$ifdef bDebug}
 {$RangeChecks On}
 {$OverflowChecks On}
{$else}
 {$RangeChecks Off}
 {$OverflowChecks Off}
{$endif bDebug}

{$ifdef bOptimization}
 {$Stackframes Off}
 {$Optimization On}
{$else}
 {$Stackframes On}
 {$Optimization Off}
{$endif bOptimization}

{$ifdef bStackFrames}
 {$Stackframes On}
{$endif bStackFrames}

{$ifdef bAsserts}
 {$Assertions On}
{$else}
 {$Assertions Off}
{$endif bAsserts}


{$ifdef bFreePascal}
  {Free Pascal}
{$else}

  {$ifdef bDebugInfo}
   {$DebugInfo On}
   {$LocalSymbols On}
   {$ReferenceInfo On}
  {$else}
   {$DebugInfo Off}
  {$endif bDebugInfo}

  {$ifdef bDelphi6}
   {$WARN SYMBOL_PLATFORM OFF}
   {$WARN SYMBOL_DEPRECATED OFF}
  {$endif bDelphi6}

  {$ifdef bDelphi15}
// {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
  {$endif bDelphi15}

{$endif bFreePascal}

{------------------------------------------------------------------------------}

