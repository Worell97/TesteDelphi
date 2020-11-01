object fThreads: TfThreads
  Left = 0
  Top = 0
  Caption = 'fThreads'
  ClientHeight = 242
  ClientWidth = 472
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object EDNumeroThreads: TEdit
    Left = 8
    Top = 8
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '10'
  end
  object EDTempMax: TEdit
    Left = 8
    Top = 35
    Width = 121
    Height = 21
    TabOrder = 1
    Text = '1000'
  end
  object Button1: TButton
    Left = 8
    Top = 62
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 2
    OnClick = Button1Click
  end
  object ProgressBar1: TProgressBar
    Left = 0
    Top = 225
    Width = 472
    Height = 17
    Align = alBottom
    TabOrder = 3
  end
  object Memo1: TMemo
    Left = 8
    Top = 104
    Width = 456
    Height = 115
    Lines.Strings = (
      'Memo1')
    TabOrder = 4
  end
end
