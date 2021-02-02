Unit
  MainUnit;

Interface

Uses
  WinAPI.Windows, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Rtti, System.Variants, Bass, INIFiles,
  FMX.Platform, FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, FMX.Edit, FMX.TabControl,
  FMX.ListBox, FMX.Objects, FMX.Ani, FMX.ImgList, FMX.Menus, FMX.Layouts,
  System.ImageList, FMX.Controls.Presentation, FMX.SearchBox, FMX.Effects,
  FMX.ComboEdit, FMX.ComboTrackBar;

Type
  TMainForm = class(TForm)
    _AddFileDialog: TOpenDialog;
    _Timer_1: TTimer;
    _ImageList: TImageList;
    _ImageFile: TImage;
    _StyleBook1: TStyleBook;

    _PopupMenu: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem1_1: TMenuItem;

    RepeadBtn: TSpeedButton;
    BackBtn: TSpeedButton;
    PlayStopBtn: TSpeedButton;
    NextBtn: TSpeedButton;
    RandomBtn: TSpeedButton;

    OpenFileBtn: TSpeedButton;
    AddFolderBtn: TSpeedButton;
    DeleteFileBtn: TSpeedButton;

    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;

    TrackPositionTrackBar: TTrackBar;
    VolumeTrackBar: TTrackBar;

    TabControl_Main: TTabControl;
    CurrentTrackTab: TTabItem;
    PlayListTab: TTabItem;
    SettingsTab: TTabItem;

    PlayListBox: TListBox;

    CountLabel: TLabel;
    CurrentTrackLabel: TLabel;
    CurrentTime: TLabel;
    FullTime: TLabel;
    CurrentSound: TLabel;
    MaxSound: TLabel;

    CheckBox_PlayListSort: TCheckBox;
    CheckBox_SettingsSave: TCheckBox;
    Label_Settings_OpenTabs: TLabel;
    SearchBox_SearchPlay: TSearchBox;
    _Timer_2: TTimer;
    GlowEffect_1: TGlowEffect;
    GlowEffect_2: TGlowEffect;
    GlowEffect_3: TGlowEffect;
    GlowEffect_4: TGlowEffect;
    CheckBox_GlowEffect: TCheckBox;
    ScrollBox_Main: TScrollBox;
    GroupBox_Settings_Total: TGroupBox;
    GroupBox_Settings_Glow: TGroupBox;
    Label_Settings_Glow: TLabel;
    ComboTrackBar_Settings_Glow: TComboTrackBar;
    Label_Settings_GlowAnim: TLabel;
    ComboBox_Settings_GlowAnim: TComboBox;
    Label_Settings_GlowSoftn: TLabel;
    ComboTrackBar_Settings_GlowSoftn: TComboTrackBar;
    ComboBox_Settings_TabOpen: TComboBox;

    Procedure FormCreate(Sender: TObject);
    Procedure FormClose(Sender: TObject; var Action: TCloseAction);

    Procedure PlayListBoxDblClick(Sender: TObject);
    Procedure OpenFileBtnClick(Sender: TObject);
    Procedure AddFolderBtnClick(Sender: TObject);
    Procedure DeleteFileBtnClick(Sender: TObject);

    Procedure _Timer_1Timer(Sender: TObject);
    Procedure MenuItem1_1Click(Sender: TObject);

    Procedure RepeadBtnClick(Sender: TObject);
    Procedure BackBtnClick(Sender: TObject);
    Procedure PlayStopBtnClick(Sender: TObject);
    Procedure NextBtnClick(Sender: TObject);
    Procedure RandomBtnClick(Sender: TObject);

    Procedure TrackPositionTrackBarChange(Sender: TObject);
    Procedure VolumeTrackBarChange(Sender: TObject);

    Procedure CheckBox_PlayListSortChange(Sender: TObject);

    Procedure _Timer_2Timer(Sender: TObject);
    Procedure CheckBox_GlowEffectChange(Sender: TObject);
    Procedure ComboTrackBar_Settings_GlowChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ComboBox_Settings_GlowAnimChange(Sender: TObject);

  Private
    Procedure StartMusic(FileName: String);
    Procedure PlayMusic();
    Procedure PauseMusic();
    Procedure StopMusic();
    Procedure AnimationEnabled(Value: Boolean);

  Public
    LB: Array [0..10000] of TListBoxItem;

  end;

  TAddMusicThread = Class(TThread)
  Protected
    Procedure Execute(); OverRide;
  end;

var
  Stream: HSTREAM;
  BassInfo: BASS_CHANNELINFO;
  AddMusicThread: TAddMusicThread;
  SettingsIniFile: TIniFile;
  MainForm: TMainForm;
  TrackNumber: Integer;
  TrackPlays, RepeadState, RandomState, PauseTimer, InfoPanelVisible: Boolean;
  S, GhostPlayList: String;

Implementation

{$R *.fmx}

Uses
  FuncUnit, InfoUnit;

//============================================== [�������� ���������] ==============================================\\
// ������ ������
Procedure TMainForm.StartMusic(FileName: String);
var
  F: PChar;
begin
  if FileExists(FileName) then begin
    if Stream <> 0 then BASS_StreamFree(Stream);
    F := PChar(FileName);
    Stream := BASS_StreamCreateFile(False, F, 0, 0, 0 {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
    if Stream = 0 then begin
      MessageBox(0, PChar('�� ������� ������� �����!' + #13#10 + F), '������!', MB_OK + MB_ICONERROR);
      Exit;
    end;
    BASS_ChannelSetAttribute(Stream, BASS_ATTRIB_VOL, VolumeTrackBar.Value / 100);
    BASS_ChannelGetInfo(Stream, BassInfo);

    TrackPositionTrackBar.Value := 0;
    TrackPositionTrackBar.Min   := 0;
    TrackPositionTrackBar.Max   := BASS_ChannelGetLength(Stream, 0) - 1;

    BASS_ChannelPlay(Stream, False);
    PlayStopBtn.StyleLookup := 'PauseToolButton';
    TrackPlays := True;
  end else MessageBox(0, PChar('���� �� ���������! ��������� �������...' + #13#10 + FileName), PChar('������!'), MB_OK + MB_ICONERROR);
end;
// ������ ������

// ����
Procedure TMainForm.PlayMusic();
begin
  BASS_ChannelPlay(Stream, False);
  PlayStopBtn.StyleLookup := 'PauseToolButton';
  TrackPlays := True;
end;
// ����

// �����
Procedure TMainForm.PauseMusic();
begin
  BASS_ChannelPause(Stream);
  PlayStopBtn.StyleLookup := 'PlayToolButton';
  TrackPlays := False;
end;
// �����

// ����
Procedure TMainForm.StopMusic();
begin
  BASS_ChannelStop(Stream);
  PlayStopBtn.StyleLookup := 'PlayToolButton';
  TrackPlays := False;
end;
// ����

// ��������� ��������
Procedure TMainForm.AnimationEnabled(Value: Boolean);
begin
  GlowEffect_1.Enabled := Value;
  GlowEffect_2.Enabled := Value;
  GlowEffect_3.Enabled := Value;
  GlowEffect_4.Enabled := Value;
end;
// ��������� ��������

// ������
Procedure TMainForm._Timer_1Timer(Sender: TObject);
var
  TrackSec: Array [1..2] of Integer;
begin
  if (BASS_ChannelIsActive(Stream) = BASS_ACTIVE_PLAYING) and (not PauseTimer) then begin
    TrackPositionTrackBar.Tag := 1;
    TrackPositionTrackBar.Value := BASS_ChannelGetPosition(Stream, 0);
    TrackPositionTrackBar.Tag := 0;

    TrackSec[1] := StrToInt(FloatToStrF(BASS_ChannelBytes2Seconds(Stream, BASS_ChannelGetLength(Stream, 0)), ffNumber, 8, 0));
    TrackSec[2] := StrToInt(FloatToStrF(BASS_ChannelBytes2Seconds(Stream, BASS_ChannelGetPosition(Stream, 0)), ffNumber, 8, 0));

    FullTime.Text := SecToMin(IntToStr(TrackSec[1]));
    CurrentTime.Text := SecToMin(IntToStr(TrackSec[2]));

    CurrentTrackLabel.Text := ExtractFileName(BassInfo.FileName);

    RandomBtn.Enabled := TrackPlays;
    PlayStopBtn.Enabled := TrackPlays;
    TrackPositionTrackBar.Enabled := TrackPlays;

    if PlayListBox.Items.Count <> 0 then begin
      NextBtn.Enabled   := True;
      BackBtn.Enabled   := True;
      RandomBtn.Enabled := True;
    end else begin
      NextBtn.Enabled   := False;
      BackBtn.Enabled   := False;
      RandomBtn.Enabled := False;
    end;
  end;

  if (BASS_ChannelIsActive(Stream) = BASS_ACTIVE_STOPPED) and (not PauseTimer) then begin
    if (PlayListBox.Count > 1) then begin
      if not RepeadState and not RandomState then NextBtnClick(nil);
      if RepeadState and (TrackNumber <> -1) then StartMusic(MainForm.PlayListBox.ItemByIndex(TrackNumber).ItemData.Detail);
      if not RepeadState and RandomState then begin
        TrackNumber := Random(PlayListBox.Count);
        StartMusic(MainForm.PlayListBox.ItemByIndex(TrackNumber).ItemData.Detail);
        PlayListBox.ItemIndex := TrackNumber;
      end;
    end else if (PlayListBox.Count = 0) then begin
      if not RepeadState then begin
        StopMusic();
        TrackPlays := False;
        PlayStopBtn.Enabled := True;
      end else if (TrackNumber <> -1) then StartMusic(BassInfo.FileName);
    end;
  end;

  if PlayListBox.Count <> 0 then CountLabel.Text := '����: ' + IntToStr(TrackNumber + 1) + ' �� ' + IntToStr(PlayListBox.Count);

  if CheckBox_GlowEffect.IsChecked then AnimationEnabled(TrackPlays) else AnimationEnabled(False);
  MainForm.Updated;
end;

Procedure TMainForm._Timer_2Timer(Sender: TObject);
var
  Level: Cardinal;
  Level_LO: Word;
  Level_Ex: Extended;
begin
  if ComboBox_Settings_GlowAnim.ItemIndex = 1 then begin
    Level := BASS_ChannelGetLevel(Stream);
    Level_LO := LoWord(Level);
    Level_Ex := Level_LO * 100 / 62700 / 100;
    if Level_Ex > 0.7 then Level_Ex := 0.7;

    GlowEffect_1.Softness := Level_Ex;
    GlowEffect_2.Softness := Level_Ex;
    GlowEffect_3.Softness := Level_Ex;
    GlowEffect_4.Softness := Level_Ex;
  end else begin
    GlowEffect_1.Softness := ComboTrackBar_Settings_GlowSoftn.Value;
    GlowEffect_2.Softness := ComboTrackBar_Settings_GlowSoftn.Value;
    GlowEffect_3.Softness := ComboTrackBar_Settings_GlowSoftn.Value;
    GlowEffect_4.Softness := ComboTrackBar_Settings_GlowSoftn.Value;
  end;
end;
// ������

// Popup Menu
Procedure TMainForm.MenuItem1_1Click(Sender: TObject);
var
  Clipboard: IFMXClipboardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipBoardService, Clipboard) then
    Clipboard.SetClipboard(TValue.From(CurrentTrackLabel.Text));
end;
// Popup Menu
//============================================== [�������� ���������] ==============================================\\

//============================================== [������ � TrackBar'��] ==============================================\\
// ���������
Procedure TMainForm.TrackPositionTrackBarChange(Sender: TObject);
begin
  if TrackPositionTrackBar.Tag = 0 then begin
    PauseMusic();
    BASS_ChannelSetPosition(Stream, Round(TrackPositionTrackBar.Value), 0);
    PlayMusic();
  end;
end;
// ���������

// ���������
Procedure TMainForm.VolumeTrackBarChange(Sender: TObject);
begin
  BASS_ChannelSetAttribute(Stream, BASS_ATTRIB_VOL, VolumeTrackBar.Value / 100);
  CurrentSound.Text := IntToStr(Round(VolumeTrackBar.Value));
end;
// ���������
//============================================== [������ � TrackBar'��] ==============================================\\

//============================================== [������ � ����������] ==============================================\\
// ������� ���� �� �����
Procedure TMainForm.PlayListBoxDblClick(Sender: TObject);
begin
  if PlayListBox.Count <> 0 then begin
    StartMusic(PlayListBox.Selected.ItemData.Detail);
    TrackNumber := PlayListBox.ItemIndex;
  end;
end;
// ������� ���� �� �����

// �������� ����
Procedure TMainForm.OpenFileBtnClick(Sender: TObject);
begin
  if not _AddFileDialog.Execute then Exit;
  StartMusic(_AddFileDialog.FileName);
  TabControl_Main.Tabs[0].IsSelected := True;
end;
// �������� ����

// �����
Procedure TAddMusicThread.Execute();
begin
  PauseTimer := True;

  MainForm.PlayListBox.BeginUpdate;
  SearchInDir(S, True);
  MainForm.PlayListBox.EndUpdate;

  MainForm.PlayListBox.ItemIndex := 0;
  TrackNumber := 0;
  MainForm.StartMusic(MainForm.PlayListBox.ItemByIndex(TrackNumber).ItemData.Detail);

  PauseTimer := False;

  if Assigned(AddMusicThread) then FreeAndNil(AddMusicThread);
end;
// �����

// �������� �����
Procedure TMainForm.AddFolderBtnClick(Sender: TObject);
begin
  if not SelectDirectory('����� ��������...', '', S) then Exit;
  GhostPlayList := S;
  AddMusicThread := TAddMusicThread.Create(False);
end;
// �������� �����

// ������� �����
Procedure TMainForm.DeleteFileBtnClick(Sender: TObject);
begin
  if PlayListBox.Count <> 0 then PlayListBox.Clear;
  TrackNumber := 0;
  CountLabel.Text := '';
end;
// ������� �����
//============================================== [������ � ����������] ==============================================\\

//============================================== [�������� ������] ==============================================\\
// ������
Procedure TMainForm.RepeadBtnClick(Sender: TObject);
begin
  if RepeadState then begin
    RepeadState := False;
    RepeadBtn.ImageIndex := 0;
  end else begin
    RepeadBtn.ImageIndex := 1;
    RepeadState := True;
  end;
end;
// ������

//�����
Procedure TMainForm.BackBtnClick(Sender: TObject);
begin
  if not RandomState and not RepeadState then begin
    if TrackNumber <> 0 then Dec(TrackNumber) else TrackNumber := PlayListBox.Count - 1;
    StartMusic(MainForm.PlayListBox.ItemByIndex(TrackNumber).ItemData.Detail);
    PlayListBox.ItemIndex := TrackNumber;
  end else if RandomState and not RepeadState then begin
    TrackNumber := Random(PlayListBox.Count);
    StartMusic(MainForm.PlayListBox.ItemByIndex(TrackNumber).ItemData.Detail);
    PlayListBox.ItemIndex := TrackNumber;
  end else if RepeadState then begin
    StartMusic(MainForm.PlayListBox.ItemByIndex(TrackNumber).ItemData.Detail);
    PlayListBox.ItemIndex := TrackNumber;
  end;
end;
//�����

// �����\����
Procedure TMainForm.PlayStopBtnClick(Sender: TObject);
begin
  if BASS_ChannelIsActive(Stream) = BASS_ACTIVE_PLAYING then begin
    PauseMusic();
    PlayStopBtn.StyleLookup := 'PlayToolButton';
    TrackPlays := False;
  end else if BASS_ChannelIsActive(Stream) = BASS_ACTIVE_PAUSED then begin
    PlayMusic();
    PlayStopBtn.StyleLookup := 'PauseToolButton';
    TrackPlays := True;
  end else if BASS_ChannelIsActive(Stream) = BASS_ACTIVE_STOPPED then begin
    StartMusic(BassInfo.FileName);
    PlayStopBtn.StyleLookup := 'PauseToolButton';
    TrackPlays := True;
  end;
end;
// �����\����

// �����
Procedure TMainForm.NextBtnClick(Sender: TObject);
begin
  if not RandomState and not RepeadState then begin
    if TrackNumber <> PlayListBox.Items.Count - 1 then Inc(TrackNumber) else TrackNumber := 0;
    StartMusic(MainForm.PlayListBox.ItemByIndex(TrackNumber).ItemData.Detail);
    PlayListBox.ItemIndex := TrackNumber;
  end else if RandomState and not RepeadState then begin
    TrackNumber := Random(PlayListBox.Count);
    StartMusic(MainForm.PlayListBox.ItemByIndex(TrackNumber).ItemData.Detail);
    PlayListBox.ItemIndex := TrackNumber;
  end else if RepeadState then begin
    StartMusic(MainForm.PlayListBox.ItemByIndex(TrackNumber).ItemData.Detail);
    PlayListBox.ItemIndex := TrackNumber;
  end;
end;
// �����

// ������
Procedure TMainForm.RandomBtnClick(Sender: TObject);
begin
  if RandomState then begin
    RandomState := False;
    RandomBtn.ImageIndex := 3;
  end else begin
    RandomState := True;
    RandomBtn.ImageIndex := 2;
  end;
end;
// ������
//============================================== [�������� ������] ==============================================\\

//============================================== [���������] ==============================================\\

Procedure TMainForm.CheckBox_PlayListSortChange(Sender: TObject);
begin
  PlayListBox.Sorted := CheckBox_PlayListSort.IsChecked;
end;

Procedure TMainForm.ComboBox_Settings_GlowAnimChange(Sender: TObject);
begin
  if CheckBox_GlowEffect.IsChecked then begin
    if ComboBox_Settings_GlowAnim.ItemIndex = 0 then begin
      Label_Settings_GlowSoftn.Enabled := True;
      ComboTrackBar_Settings_GlowSoftn.Enabled := True;
    end else begin
      Label_Settings_GlowSoftn.Enabled := False;
      ComboTrackBar_Settings_GlowSoftn.Enabled := False;
    end;
  end;
end;

Procedure TMainForm.CheckBox_GlowEffectChange(Sender: TObject);
begin
  _Timer_2.Enabled := CheckBox_GlowEffect.IsChecked;

  ComboTrackBar_Settings_Glow.Enabled := CheckBox_GlowEffect.IsChecked;
  Label_Settings_Glow.Enabled := CheckBox_GlowEffect.IsChecked;

  ComboBox_Settings_GlowAnim.Enabled := CheckBox_GlowEffect.IsChecked;
  Label_Settings_GlowAnim.Enabled := CheckBox_GlowEffect.IsChecked;

  ComboTrackBar_Settings_GlowSoftn.Enabled := CheckBox_GlowEffect.IsChecked;
  Label_Settings_GlowSoftn.Enabled := CheckBox_GlowEffect.IsChecked;

  ComboBox_Settings_GlowAnimChange(nil);
end;

Procedure TMainForm.ComboTrackBar_Settings_GlowChange(Sender: TObject);
begin
  GlowEffect_1.Opacity := ComboTrackBar_Settings_Glow.Value;
  GlowEffect_2.Opacity := ComboTrackBar_Settings_Glow.Value;
  GlowEffect_3.Opacity := ComboTrackBar_Settings_Glow.Value;
  GlowEffect_4.Opacity := ComboTrackBar_Settings_Glow.Value;
end;

// �������� �����
Procedure TMainForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
// ������������� Bass.dll
  if not BASS_Init(-1, 44100, BASS_DEVICE_SPEAKERS, 0, nil) then begin
    if MessageBox(0, PChar('�� ������� ���������������� ���������� "BASS.dll"! ��������� �������� �� �����!' + #13#10 + '�������� ������ ���������?'), PChar('��������� ������!'), MB_YESNO + MB_ICONERROR) = IDYES then Application.Terminate;
  end;
// ������������� Bass.dll

// ������������� ����������
  NextBtn.Enabled               := False;
  BackBtn.Enabled               := False;
  PlayStopBtn.Enabled           := False;
  TrackPlays                    := False;
  RepeadState                   := False;
  PauseTimer                    := False;
  TrackPositionTrackBar.Enabled := False;

  TrackNumber := -1;
  GhostPlayList := '';

  AnimationEnabled(False);
  VolumeTrackBarChange(nil);

  CheckBox_GlowEffectChange(nil);
  ComboBox_Settings_GlowAnimChange(nil);
// ������������� ����������

// �������� �������� �� Ini �����
  GetSettingsToFile();
// �������� �������� �� Ini �����

  PlayListBox.Sorted := CheckBox_PlayListSort.IsChecked;
  _Timer_2.Enabled := CheckBox_GlowEffect.IsChecked;

// ���������� ������ � ��������
  if (ParamCount > 1) then begin
  // ���� ������ ������ 1
    PlayListBox.BeginUpdate;
    For i := 1 to ParamCount do begin
      LB[i] := TListBoxItem.Create(PlayListBox);
      With LB[i] do begin
        Parent := MainForm.PlayListBox;
        ItemData.Text := ExtractFileName(ParamStr(i));
        ItemData.Detail := ParamStr(i);
      end;
    end;
    PlayListBox.EndUpdate;

    PlayListBox.ItemIndex := 0;
    TrackNumber := 0;
    RadioBtnState(1);

    StartMusic(PlayListBox.ItemByIndex(TrackNumber).ItemData.Detail);
  end else if ParamCount = 1 then begin
  // ���� ���� 1
    RadioBtnState(0);
    StartMusic(ParamStr(1));
  end else begin
  // ���� ������ ���, �������� ������������ ����-����
    if (GhostPlayList <> '') and (MessageBox(0, PChar('�� ������ ������������ ���������� ����-����?' + #13#10 + '����: "' + GhostPlayList + '"'), PChar('�������������� ����-�����...'), MB_YESNO + MB_ICONQUESTION) = mrYes) then begin
      S := GhostPlayList;
      AddMusicThread := TAddMusicThread.Create(False);
    end else begin
      GhostPlayList := '';
    end;

    RadioBtnState(1);
  end;
// ���������� ������ � ��������

end;

Procedure TMainForm.FormShow(Sender: TObject);
begin
// ���������� ����������
  if InfoPanelVisible then InfoForm.ShowModal;
// ���������� ����������
end;

// �������� �����

// �������� �����
Procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  BASS_StreamFree(Stream);
  BASS_Free();

// ���������� �������� � Ini ����
  SaveSettingsToFile();
// ���������� �������� � Ini ����
end;
// �������� �����

//============================================== [���������] ==============================================\\

end.
