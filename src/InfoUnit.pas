Unit InfoUnit;

Interface

Uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  MainUnit, FMX.StdCtrls, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo;

Type
  TInfoForm = Class(TForm)
    Line_1: TLine;
    CloseBtnInf: TButton;
    InfoMemo: TMemo;
    InfoLabel: TLabel;

    Procedure CloseBtnInfClick(Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }
  end;

var
  InfoForm: TInfoForm;

Implementation

{$R *.fmx}

Procedure TInfoForm.CloseBtnInfClick(Sender: TObject);
begin
  InfoForm.Close;
end;

end.
