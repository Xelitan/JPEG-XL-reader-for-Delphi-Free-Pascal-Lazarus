unit JxlImage;

//{$IFDEF FPC}{$MODE DELPHI}{$ENDIF} {$H+}

{$mode objfpc}{$H+}

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Description:	Reader for JPEG XL images                                     //
// Version:	0.1                                                           //
// Date:	02-MAR-2025                                                   //
// License:     MIT                                                           //
// Target:	Win64, Free Pascal, Delphi                                    //
// Copyright:	(c) 2025 Xelitan.com.                                         //
//		All rights reserved.                                          //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

interface

uses Classes, Graphics, SysUtils, Types, Dialogs;

const LIBJXL = 'libjxl.dll';

type
  JxlDecoderStatus = (
    JXL_DEC_SUCCESS = 0,
    JXL_DEC_ERROR = 1,
    JXL_DEC_NEED_MORE_INPUT = 2,
    JXL_DEC_NEED_PREVIEW_OUT_BUFFER = 3,
    JXL_DEC_NEED_DC_OUT_BUFFER = 4,
    JXL_DEC_NEED_IMAGE_OUT_BUFFER = 5,
    JXL_DEC_JPEG_NEED_MORE_OUTPUT = 6,
    JXL_DEC_BOX_NEED_MORE_OUTPUT = 7,
    JXL_DEC_BASIC_INFO = $40,
    JXL_DEC_COLOR_ENCODING = $100,
    JXL_DEC_PREVIEW_IMAGE = $200,
    JXL_DEC_FRAME = $400,
    JXL_DEC_FULL_IMAGE = $1000,
    JXL_DEC_JPEG_RECONSTRUCTION = $2000,
    JXL_DEC_BOX = $4000,
    JXL_DEC_FRAME_PROGRESSION = $8000,
    JXL_DEC_BOX_COMPLETE = $10000
  );

  JxlDataType = (
    JXL_TYPE_FLOAT = 0,
    JXL_TYPE_UINT8 = 2,
    JXL_TYPE_UINT16 = 3,
    JXL_TYPE_FLOAT16 = 5
  );

  JxlEndianness = (
    JXL_NATIVE_ENDIAN = 0,
    JXL_LITTLE_ENDIAN = 1,
    JXL_BIG_ENDIAN = 2
  );

  JxlPixelFormat = packed record
    num_channels: UInt32;
    data_type: JxlDataType;
    endianness: JxlEndianness;
    align: NativeUInt;
  end;
  PJxlPixelFormat = ^JxlPixelFormat;

type
  JXL_BOOL = LongBool;
  JxlOrientation = (
    JXL_ORIENT_IDENTITY = 1,
    JXL_ORIENT_FLIP_HORIZONTAL = 2,
    JXL_ORIENT_ROTATE_180 = 3,
    JXL_ORIENT_FLIP_VERTICAL = 4,
    JXL_ORIENT_TRANSPOSE = 5,
    JXL_ORIENT_ROTATE_90_CW = 6,
    JXL_ORIENT_ANTI_TRANSPOSE = 7,
    JXL_ORIENT_ROTATE_90_CCW = 8
  );

  JxlPreviewHeader = packed record
    xsize: LongWord;
    ysize: LongWord;
  end;

  JxlAnimationHeader = packed record
    tps_numerator: LongWord;
    tps_denominator: LongWord;
    num_loops: LongWord;
    have_timecodes: JXL_BOOL;
  end;

  JxlColorProfileTarget = (
    JXL_COLOR_PROFILE_TARGET_ORIGINAL = 0,
    JXL_COLOR_PROFILE_TARGET_DATA = 1
  );

  JxlBasicInfo = packed record
    have_container: JXL_BOOL;
    xsize: LongWord;
    ysize: LongWord;
    bits_per_sample: LongWord;
    exponent_bits_per_sample: LongWord;
    intensity_target: Single;
    min_nits: Single;
    relative_to_max_display: JXL_BOOL;
    linear_below: Single;
    uses_original_profile: JXL_BOOL;
    have_preview: JXL_BOOL;
    have_animation: JXL_BOOL;
    orientation: JxlOrientation;
    num_color_channels: LongWord;
    num_extra_channels: LongWord;
    alpha_bits: LongWord;
    alpha_exponent_bits: LongWord;
    alpha_premultiplied: JXL_BOOL;
    preview: JxlPreviewHeader;
    animation: JxlAnimationHeader;
    intrinsic_xsize: LongWord;
    intrinsic_ysize: LongWord;
    padding: array[0..99] of Byte;
  end;
  PJxlBasicInfo = ^JxlBasicInfo;

  PJxlDecoder = Pointer;

type
  JxlEncoderError = (
    JXL_ENC_ERR_OK = 0,
    JXL_ENC_ERR_GENERIC = 1,
    JXL_ENC_ERR_OOM = 2,
    JXL_ENC_ERR_JBRD = 3,
    JXL_ENC_ERR_BAD_INPUT = 4,
    JXL_ENC_ERR_NOT_SUPPORTED = $80,
    JXL_ENC_ERR_API_USAGE = $81
  );

  // JXL library functions
  function JxlDecoderCreate(memory_manager: Pointer): PJxlDecoder; cdecl; external 'libjxl.dll';
  function JxlDecoderSubscribeEvents(dec: PJxlDecoder; events: Integer): JxlDecoderStatus; cdecl; external 'libjxl.dll';
  function JxlDecoderProcessInput(dec: PJxlDecoder): JxlDecoderStatus; cdecl; external 'libjxl.dll';
  function JxlDecoderGetBasicInfo(dec: PJxlDecoder; info: Pointer): JxlDecoderStatus; cdecl; external 'libjxl.dll';
  function JxlDecoderSetInput(dec: PJxlDecoder; const data: PByte; size: NativeUInt): JxlDecoderStatus; cdecl; external 'libjxl.dll';
  procedure JxlDecoderCloseInput(dec: PJxlDecoder); cdecl; external 'libjxl.dll';
  function JxlDecoderGetICCProfileSize(dec: PJxlDecoder; target: JxlColorProfileTarget; size: PNativeUInt): JxlDecoderStatus; cdecl; external 'libjxl.dll';
  function JxlDecoderGetColorAsICCProfile(dec: PJxlDecoder; target: JxlColorProfileTarget; icc_profile: PByte; size: NativeUInt): JxlDecoderStatus; cdecl; external 'libjxl.dll';
  function JxlDecoderSetImageOutBuffer(dec: PJxlDecoder; format: PJxlPixelFormat; pixels: Pointer; size: NativeUInt): JxlDecoderStatus; cdecl; external 'libjxl.dll';
  function JxlDecoderImageOutBufferSize(dec: PJxlDecoder; format: PJxlPixelFormat; size: PNativeUInt): JxlDecoderStatus; cdecl; external 'libjxl.dll';


  { TJxlImage }
type
  TJxlImage = class(TGraphic)
  private
    IsJxl: Boolean;
    FBmp: TBitmap;
    FCompression: Integer;
    function DecodeFromStream(Str: TStream): Integer;
    procedure EncodeToStream(Str: TStream);
  protected
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); override;
  //    function GetEmpty: Boolean; virtual; abstract;
    function GetHeight: Integer; override;
    function GetTransparent: Boolean; override;
    function GetWidth: Integer; override;
    procedure SetHeight(Value: Integer); override;
    procedure SetTransparent(Value: Boolean); override;
    procedure SetWidth(Value: Integer);override;
  public
    procedure SetLossyCompression(Value: Cardinal);
    procedure SetLosslessCompression;
    procedure Assign(Source: TPersistent); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    constructor Create; override;
    destructor Destroy; override;
  end;

implementation

{ TJxlImage }

function TJxlImage.DecodeFromStream(Str: TStream): Integer;
var dec: PJxlDecoder;
    status: JxlDecoderStatus;
    info: JxlBasicInfo;
    format: JxlPixelFormat;
    buffer_size: NativeUInt;
    icc_size:  NativeUInt;
    ASize: NativeUInt;
    target: JxlColorProfileTarget;
    i: Integer;
    Data: TBytes;
    size: NativeUInt;
    jxl: PByte;
    AWidth, AHeight: NativeUInt;
    icc_profile: TBytes;
    x,y: Integer;
    P: PByteArray;
    Buff: TBytes;
begin
  dec := JxlDecoderCreate(nil);

  if JxlDecoderSubscribeEvents(dec, Integer(JXL_DEC_BASIC_INFO) or
     Integer(JXL_DEC_COLOR_ENCODING) or Integer(JXL_DEC_FULL_IMAGE)) <> JXL_DEC_SUCCESS then Exit(1);

  SetLength(Buff, Str.Size);
  Str.Read(Buff[0], Str.Size);
  Size := Str.Size;

  format.num_channels := 4;
  format.data_type := JXL_TYPE_UINT8;
  format.endianness := JXL_NATIVE_ENDIAN;
  format.align := 0;

  jxl := @Buff[0];

  JxlDecoderSetInput(dec, jxl, size);
  JxlDecoderCloseInput(dec);

  while True do begin
    status := JxlDecoderProcessInput(dec);
    case status of
      JXL_DEC_ERROR: Exit(2);
      JXL_DEC_NEED_MORE_INPUT: Exit(3);
      JXL_DEC_BASIC_INFO:
        begin
          if JxlDecoderGetBasicInfo(dec, @info) <> JXL_DEC_SUCCESS then Exit(4);

          AWidth := info.xsize;
          AHeight := info.ysize;
        end;
      JXL_DEC_COLOR_ENCODING:
        begin
         target := JXL_COLOR_PROFILE_TARGET_DATA;
         if JxlDecoderGetICCProfileSize(dec, target, @icc_size) <> JXL_DEC_SUCCESS then Exit(5);

          SetLength(icc_profile, icc_size);
          if JxlDecoderGetColorAsICCProfile(dec, target, @icc_profile[0], icc_size) <> JXL_DEC_SUCCESS then Exit(6);
        end;
      JXL_DEC_NEED_IMAGE_OUT_BUFFER:
        begin
          if JxlDecoderImageOutBufferSize(dec, @format, @buffer_size) <> JXL_DEC_SUCCESS then Exit(7);

         if buffer_size <> AWidth * AHeight * format.num_channels then Exit(8);

          SetLength(Data, AWidth * AHeight * format.num_channels);
          ASize := Length(Data);
          if JxlDecoderSetImageOutBuffer(dec, @format, @Data[0], ASize) <> JXL_DEC_SUCCESS then Exit(9);
        end;
      JXL_DEC_FRAME: ;
      JXL_DEC_FULL_IMAGE: ;
      JXL_DEC_SUCCESS: begin Result := 0; break; end;
      else Exit(10);
    end;
  end;

  FBmp.SetSize(AWidth, AHeight);
  i := 0;

  for y:=0 to FBmp.Height-1 do begin
    P := FBmp.Scanline[y];

    for x:=0 to FBmp.Width-1 do begin
      P^[4*x+3] := Data[i+3];
      P^[4*x+2] := Data[i];
      P^[4*x+1] := Data[i+1];
      P^[4*x  ] := Data[i+2];

      Inc(i, 4);
    end;
  end;

end;

procedure TJxlImage.EncodeToStream(Str: TStream);
begin
  //TODO
end;

procedure TJxlImage.Draw(ACanvas: TCanvas; const Rect: TRect);
begin
  ACanvas.StretchDraw(Rect, FBmp);
end;

function TJxlImage.GetHeight: Integer;
begin
  Result := FBmp.Height;
end;

function TJxlImage.GetTransparent: Boolean;
begin
  Result := False;
end;

function TJxlImage.GetWidth: Integer;
begin
  Result := FBmp.Width;
end;

procedure TJxlImage.SetHeight(Value: Integer);
begin
  FBmp.Height := Value;
end;

procedure TJxlImage.SetTransparent(Value: Boolean);
begin
  //
end;

procedure TJxlImage.SetWidth(Value: Integer);
begin
  FBmp.Width := Value;
end;

procedure TJxlImage.SetLossyCompression(Value: Cardinal);
begin
  if Value > 100 then Value := 100;
  FCompression := Value;
end;

procedure TJxlImage.SetLosslessCompression;
begin
  FCompression := -1;
end;

procedure TJxlImage.Assign(Source: TPersistent);
var Src: TGraphic;
begin
  if source is tgraphic then begin
    Src := Source as TGraphic;
    FBmp.SetSize(Src.Width, Src.Height);
    FBmp.Canvas.Draw(0,0, Src);
  end;
end;

procedure TJxlImage.LoadFromStream(Stream: TStream);
var Ret: Integer;
    Str: String;
begin
  Ret := DecodeFromStream(Stream);
  Str := '';

  case Ret of
    //0: OK
    1: Str := 'JxlDecoderSubscribeEvents';
    2: Str := 'Decoder error';
    3: Str := 'Unexpected need for more input';
    4: Str := 'GetBasicInfo failed';
    5: Str := 'GetICCProfileSize failed';
    6: Str := 'GetColorAsICCProfile failed';
    7: Str := 'ImageOutBufferSize failed';
    8: Str := 'Invalid buffer size';
    9: Str := 'SetImageOutBuffer failed';
    10: Str := 'Unknown decoder status';
  end;
  if Str <> '' then raise Exception.Create(Str);
end;

procedure TJxlImage.SaveToStream(Stream: TStream);
begin
  EncodeToStream(Stream);
end;

constructor TJxlImage.Create;
begin
  inherited Create;

  FBmp := TBitmap.Create;
  FBmp.PixelFormat := pf32bit;
  FBmp.SetSize(1,1);
  IsJxl := True;
  FCompression := 90;
end;

destructor TJxlImage.Destroy;
begin
  FBmp.Free;
  inherited Destroy;
end;

initialization
  TPicture.RegisterFileFormat('jxl','JXL Image', TJxlImage);

finalization
  TPicture.UnregisterGraphicClass(TJxlImage);

end.
