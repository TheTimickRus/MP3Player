Unit FuncUnit;

Interface

Uses
  WinAPI.Windows, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, Masks, FMX.ListBox,
  MainUnit, INIFiles, tlhelp32;

Procedure SearchInDir(Dir: String; Subdir: Boolean);
Function SecToMin(S: String): String;
Function CheckParam(S: String): Boolean;
Procedure GetSettingsToFile();
Procedure SaveSettingsToFile();
Procedure RadioBtnState(i: Integer);
Function IsRunning(sName: String): Boolean;

Implementation

Procedure SearchInDir(Dir: String; SubDir: Boolean);
var
  R, I: Integer;
  F: TSearchRec;
begin
  if Dir = '' then Exit;
  if Dir[Length(Dir)] <> '\' then Dir := Dir + '\';
  ChDir(Dir);

  R := FindFirst('*.*', FaAnyFile, F);
  i := 0;

  While R = 0 do begin
    if ((F.Attr and FaDirectory) <> FaDirectory) and (MatchesMask(F.Name, '*.mp3') or MatchesMask(F.Name, '*.ogg') or MatchesMask(F.Name, '*.wav')) then
      if (F.Name <> '.') and (F.Name <> '..') then begin
        MainForm.LB[i] := TListBoxItem.Create(MainForm.PlayListBox);
        With MainForm.LB[i] do begin
          Parent := MainForm.PlayListBox;
          ItemData.Text   := F.Name;
          ItemData.Detail := ExpandFileName(F.Name);
        end;
        I := I + 1;
      end;
    if (((F.Attr and FaDirectory) = FaDirectory) and SubDir) and ((F.Name <> '.') and (F.Name <> '..')) then begin
        SearchInDir(ExpandFileName(F.Name), SubDir);
        ChDir(Dir);
    end;
    R := FindNext(F);
  end;
  
  FindClose(F);
end;

Function SecToMin(S: String): String;
var
  S1, S2, S3: String;
begin
  S1 := FloatToStr(StrToFloat(S) / 60);
  S1 := FloatToStr(Trunc(StrToFloat(S1)));
  S3 := FloatToStr(StrToFloat(S) / 3600);
  S3 := FloatToStr(Trunc(StrToFloat(S3)));
  S1 := IntToStr(StrToInt(S1) - StrToInt(S3) * 60);
  S2 := IntToStr(StrToInt(S) - StrToInt(S3) * 3600);
  S2 := IntToStr(StrToInt(S2) - StrToInt(S1) * 60);

  if StrToInt(S3) < 10 then S3 := '0' + S3;
  if StrToInt(S2) < 10 then S2 := '0' + S2;

  if StrToInt(S3) <> 0 then Result := S3 + ':' + S1 + ':' + S2 else Result := S1 + ':' + S2
end;

Procedure RadioBtnState(i: Integer);
begin
  if MainForm.ComboBox_Settings_TabOpen.ItemIndex = 0 then MainForm.TabControl_Main.Tabs[0].IsSelected := True;
  if MainForm.ComboBox_Settings_TabOpen.ItemIndex = 1 then MainForm.TabControl_Main.Tabs[1].IsSelected := True;
  if MainForm.ComboBox_Settings_TabOpen.ItemIndex = 2 then MainForm.TabControl_Main.Tabs[i].IsSelected := True;
end;

Function CheckParam(S: String): Boolean;
begin
  if S = '1' then Result := True else Result := False;
end;

Procedure GetSettingsToFile();
begin
  if FileExists(ExtractFileDir(ParamStr(0)) + '\Settings.ini') then begin
    SettingsIniFile := TIniFile.Create(ExtractFileDir(ParamStr(0)) + '\Settings.ini');

  // Форма Информации
    InfoPanelVisible := CheckParam(SettingsIniFile.ReadString('MainSettings', 'ShowInfoPanel', ''));

  //Сохранение настроек
    MainForm.CheckBox_SettingsSave.IsChecked := CheckParam(SettingsIniFile.ReadString('MainSettings', 'SettSaveValue', ''));

  //Сортировка Треков
    MainForm.CheckBox_PlayListSort.IsChecked := CheckParam(SettingsIniFile.ReadString('MainSettings', 'SortValue', ''));

  //Последний плейлист
    if DirectoryExists(SettingsIniFile.ReadString('MainSettings', 'PlayListPatchValue', '')) then GhostPlayList := SettingsIniFile.ReadString('MainSettings', 'PlayListPatchValue', '');

  //Вариант открытия вкладок
    MainForm.ComboBox_Settings_TabOpen.ItemIndex := StrToInt(SettingsIniFile.ReadString('MainSettings', 'OpenTabsValue', ''));

  //Значение громкости
    MainForm.VolumeTrackBar.Value := StrToFloat(SettingsIniFile.ReadString('MainSettings', 'VolumeValue', ''));

  //Glow Эффект
    MainForm.CheckBox_GlowEffect.IsChecked := CheckParam(SettingsIniFile.ReadString('MainSettings', 'GlowEff_Value', ''));
  //Glow Эффект - Тип Анимации
    MainForm.ComboBox_Settings_GlowAnim.ItemIndex := StrToInt(SettingsIniFile.ReadString('MainSettings', 'GlowEff_AnimType', ''));
  //Glow Эффект - Непрозрачность
    MainForm.ComboTrackBar_Settings_Glow.Value := StrToFloat(SettingsIniFile.ReadString('MainSettings', 'GlowEff_Opac', ''));
  //Glow Эффект - Размер
    MainForm.ComboTrackBar_Settings_GlowSoftn.Value := StrToFloat(SettingsIniFile.ReadString('MainSettings', 'GlowEff_Seftn', ''));

    SettingsIniFile.Free;
  end;
end;

Procedure SaveSettingsToFile();
begin
  if (FileExists(ExtractFileDir(ParamStr(0)) + '\Settings.ini')) and (MainForm.CheckBox_SettingsSave.IsChecked) then begin
    SettingsIniFile := TIniFile.Create(ExtractFileDir(ParamStr(0)) + '\Settings.ini');

  // Форма Информации
    SettingsIniFile.WriteString('MainSettings', 'ShowInfoPanel', '0');

  //Сохранение настроек
    if MainForm.CheckBox_SettingsSave.IsChecked then SettingsIniFile.WriteString('MainSettings', 'SettSaveValue', '1') else SettingsIniFile.WriteString('MainSettings', 'SettSaveValue', '0');

  //Сортировка Треков
    if MainForm.CheckBox_PlayListSort.IsChecked then SettingsIniFile.WriteString('MainSettings', 'SortValue', '1') else SettingsIniFile.WriteString('MainSettings', 'SortValue', '0');

  //Последний плейлист
    SettingsIniFile.WriteString('MainSettings', 'PlayListPatchValue', GhostPlayList);

  //Вариант открытия вкладок
    SettingsIniFile.WriteString('MainSettings', 'OpenTabsValue', IntToStr(MainForm.ComboBox_Settings_TabOpen.ItemIndex));

  //Значение громкости
    SettingsIniFile.WriteString('MainSettings', 'VolumeValue', FloatToStr(MainForm.VolumeTrackBar.Value));

  //Glow Эффект
    if MainForm.CheckBox_GlowEffect.IsChecked then SettingsIniFile.WriteString('MainSettings', 'GlowEff_Value', '1') else SettingsIniFile.WriteString('MainSettings', 'GlowEff_Value', '0');
  //Glow Эффект - Тип Анимации
    SettingsIniFile.WriteString('MainSettings', 'GlowEff_AnimType', IntToStr(MainForm.ComboBox_Settings_GlowAnim.ItemIndex));
  //Glow Эффект - Непрозрачность
    SettingsIniFile.WriteString('MainSettings', 'GlowEff_Opac', FloatToStr(MainForm.ComboTrackBar_Settings_Glow.Value));
  //Glow Эффект - Размер
    SettingsIniFile.WriteString('MainSettings', 'GlowEff_Seftn', FloatToStr(MainForm.ComboTrackBar_Settings_GlowSoftn.Value));

    SettingsIniFile.Free;
  end;
end;

Function IsRunning(sName: String): Boolean;
var
  han: THandle;
  ProcStruct: PROCESSENTRY32;
  sID: String;
begin
  Result := False;

  han := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
  if han = 0 then Exit;

  ProcStruct.dwSize := SizeOf(PROCESSENTRY32);
  if Process32First(han, ProcStruct) then begin
    Repeat
      sID := ExtractFileName(ProcStruct.szExeFile);
      if UpperCase(Copy(sId, 1, Length(sName))) = UpperCase(sName) then begin
        Result := True;
        Break;
      end;
    Until Not Process32Next(han, ProcStruct);
  end;
  CloseHandle(han);
end;

end.
