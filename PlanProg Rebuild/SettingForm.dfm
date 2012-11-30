object SetForm: TSetForm
  Left = 607
  Top = 229
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'SetForm'
  ClientHeight = 201
  ClientWidth = 478
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbDateRefresh: TLabel
    Left = 176
    Top = 8
    Width = 117
    Height = 13
    Caption = #1054#1073#1085#1086#1074#1083#1077#1085#1080#1077' '#1076#1072#1090#1099' ('#1089#1077#1082')'
  end
  object lbScreenRefresh: TLabel
    Left = 176
    Top = 48
    Width = 99
    Height = 13
    Caption = #1057#1084#1077#1085#1072' '#1101#1082#1088#1072#1085#1072' ('#1089#1077#1082')'
  end
  object lbWMSRefresh: TLabel
    Left = 176
    Top = 88
    Width = 101
    Height = 13
    Caption = #1057#1080#1085#1093#1088'. '#1089' WMS ('#1084#1080#1085')'
  end
  object Label1: TLabel
    Left = 16
    Top = 97
    Width = 38
    Height = 13
    Caption = #1055#1072#1088#1086#1083#1100
  end
  object leAdress: TLabeledEdit
    Left = 32
    Top = 16
    Width = 121
    Height = 21
    EditLabel.Width = 88
    EditLabel.Height = 13
    EditLabel.Caption = 'IP '#1072#1076#1088#1077#1089' '#1089#1077#1088#1074#1077#1088#1072
    TabOrder = 0
  end
  object leLogin: TLabeledEdit
    Left = 32
    Top = 64
    Width = 121
    Height = 21
    EditLabel.Width = 91
    EditLabel.Height = 13
    EditLabel.Caption = #1051#1086#1075#1080#1085' '#1085#1072' '#1089#1077#1088#1074#1077#1088#1077
    TabOrder = 1
  end
  object btOK: TButton
    Left = 112
    Top = 136
    Width = 75
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    TabOrder = 2
    OnClick = btOKClick
  end
  object btCancel: TButton
    Left = 200
    Top = 136
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 3
    OnClick = btCancelClick
  end
  object seDateRefresh: TSpinEdit
    Left = 176
    Top = 24
    Width = 121
    Height = 22
    MaxLength = 5
    MaxValue = 10000
    MinValue = 1
    TabOrder = 4
    Value = 1
  end
  object seScreenRefresh: TSpinEdit
    Left = 176
    Top = 64
    Width = 121
    Height = 22
    MaxLength = 5
    MaxValue = 10000
    MinValue = 1
    TabOrder = 5
    Value = 1
  end
  object seWMSRefresh: TSpinEdit
    Left = 176
    Top = 104
    Width = 121
    Height = 22
    MaxLength = 3
    MaxValue = 120
    MinValue = 1
    TabOrder = 6
    Value = 1
  end
  object cbWMSSync: TCheckBox
    Left = 312
    Top = 24
    Width = 161
    Height = 17
    Caption = #1057#1080#1085#1093#1088#1086#1085#1080#1079#1080#1088#1086#1074#1072#1090#1100' '#1089' WMS'
    TabOrder = 7
    OnClick = cbWMSSyncClick
  end
  object cbGraph: TCheckBox
    Left = 320
    Top = 56
    Width = 129
    Height = 17
    Caption = #1042#1099#1074#1086#1076#1080#1090#1100' '#1075#1088#1072#1092#1080#1082#1080
    TabOrder = 8
    OnClick = cbGraphClick
  end
  object GroupBox1: TGroupBox
    Left = 320
    Top = 80
    Width = 137
    Height = 89
    Caption = #1043#1088#1072#1092#1080#1082#1080
    TabOrder = 9
    object cbByDay: TCheckBox
      Left = 8
      Top = 16
      Width = 121
      Height = 17
      Caption = #1055#1086' '#1076#1085#1103#1084' (14 '#1076#1085')'
      TabOrder = 0
    end
    object cbByYear: TCheckBox
      Left = 8
      Top = 64
      Width = 121
      Height = 17
      Caption = #1055#1086' '#1075#1086#1076#1072#1084' (12 '#1084#1077#1089')'
      TabOrder = 1
    end
    object cbByMonth: TCheckBox
      Left = 8
      Top = 40
      Width = 121
      Height = 17
      Caption = #1055#1086' '#1084#1077#1089#1103#1094#1072#1084' (8 '#1085#1077#1076')'
      TabOrder = 2
    end
  end
  object lePass: TMaskEdit
    Left = 16
    Top = 148
    Width = 121
    Height = 21
    PasswordChar = '*'
    TabOrder = 10
    Text = 'lePass'
  end
end
