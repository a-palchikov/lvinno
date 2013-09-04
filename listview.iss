
[Code]
type
  TWndProc = function(handle: Integer; msg: UINT; wParam, lParam: LongInt): LongInt;
  TCWPSTRUCT = record
    lParam, wParam: LongInt;
    msg: LongInt;
    hWnd: Integer;
  end; 
  TCWPSTRUCTProc = procedure(code: Integer; wParam: LongInt; lParam: TCWPSTRUCT); 
  TNMHDR = record
    hwndFrom: LongInt;
    idFrom: LongInt;
    code: LongInt;
  end;
  TNMLISTVIEW = record
    hdr: TNMHDR;
    iItem, iSubItem: Integer;
    uNewState, uOldState, uChanged: UINT;
    ptAction: TPoint;
    lParam: LongInt;
  end;
  TLVData = record
    handle: Integer;
    parHandle: Integer; {Parent window hwnd}
    oldWndProc: Integer;
  end;
  TWinListViewNotifyEvent = procedure(data: TLVData; lvn: TNMLISTVIEW);
  TWinListViewChangingEvent = function(data: TLVData; lvn: TNMLISTVIEW): Boolean;
  TLVBehavior = record
    OnClick: TWinListViewNotifyEvent;
    OnChanging: TWinListViewChangingEvent;
  end;
  TWinListView = record
    data: TLVData;
    behavior: TLVBehavior;
  end;

const
  WM_NOTIFY = $4e;
  WS_EX_CLIENTEDGE = $0200;
  TNMLISTVIEWSIZE = $2c;

{listview-related helpers}
type
  TInitCommonCtls = record
    dwSize, dwICC: Integer;
  end;
  TWinRect = record
    left, top, right, bottom: LongInt;
  end;
  TLVColumn = record
    mask: LongInt;
    fmt: Integer;
    cx: Integer;
    value: WideString;
    valueMax, iSubItem : Integer;
    iImage, iOrder: Integer;
  end;
  TLVItem = record
    mask: LongInt;
    iItem, iSubItem: Integer;
    state, stateMask: LongInt;
    value: WideString;
    {value: Integer;}
    valueMax: Integer;
    iImage: Integer;
    lParam: LongInt;
    iIndent: Integer;   {_if (_WIN32_IE >= 0x0300)}
    iGroupId: Integer;  {_if (_WIN32_WINNT >= 0x0501)}
    cColumns, puColumns: LongInt;
    {piColFmt, iGroup: LongInt;}  {_if (_WIN32_WINNT >= 0x0600)}
  end;

const
  {list view}
  ICC_LISTVIEW_CLASSES = $1;
  WC_LISTVIEW = 'SysListView32';
  LVM_FIRST = $1000;
  NM_FIRST = $0;
  LVM_SETBKCOLOR = (LVM_FIRST + 1);
  LVM_GETITEMCOUNT = (LVM_FIRST + 4);
  LVM_DELETEALLITEMS = (LVM_FIRST + 9);
  LVM_GETNEXTITEM = (LVM_FIRST + 12);

  LVSCW_AUTOSIZE = -1;
  LVSCW_AUTOSIZE_USEHEADER = -2;
  LVM_GETCOLUMNWIDTH = (LVM_FIRST + 29);
  LVM_SETCOLUMNWIDTH = (LVM_FIRST + 30);

  LVM_GETHEADER = (LVM_FIRST + 31);

  LVM_SETTEXTBKCOLOR = (LVM_FIRST + 38);
  LVM_SETITEMSTATE = (LVM_FIRST + 43);
  LVM_SETEXTENDEDLISTVIEWSTYLE = (LVM_FIRST + 54);
  LVM_SETITEM = (LVM_FIRST + 76);
  LVM_INSERTITEM = (LVM_FIRST + 77);
  LVM_INSERTCOLUMN = (LVM_FIRST + 97);
  LVM_GETITEMTEXT = (LVM_FIRST + 115);
  LVM_SETITEMTEXT = (LVM_FIRST + 116);
  LVM_SETOUTLINECOLOR = (LVM_FIRST + 177);
  LPSTR_TEXTCALLBACK = -1;  {((LPWSTR)-1L)}
  {listview: styles}
  LVS_REPORT = $1;
  LVS_EDITLABELS = $0200;
  LVS_SINGLESEL = $4;
  LVS_SHOWSELALWAYS = $8;
  LVS_EX_FULLROWSELECT = $20;
  LVS_EX_GRIDLINES = $1;
  LVS_EX_FLATSB = $100;
  LVS_EX_HEADERDRAGDROP = $10;
  LVS_EX_AUTOSIZECOLUMNS = $10000000;
  LVS_EX_LABELTIP = $4000;
  LVS_EX_BORDERSELECT = $8000;
  LVS_EX_COLUMNOVERFLOW = $80000000;
  {listview: columns}
  LVCFMT_LEFT = $0;
  LVCFMT_RIGHT = $1;
  LVCF_FMT = $1;
  LVCF_WIDTH = $2;
  LVCF_TEXT = $4;
  LVCF_SUBITEM = $8;
  {listview: items}
  LVIF_TEXT = $1;
  LVIF_IMAGE = $2;
  LVIF_STATE = $8;
  LVIS_FOCUSED = $1;
  LVIS_SELECTED = $2;
  LVNI_SELECTED = $2;
  {listview: notifications}
  LVN_FIRST = (0-100);
  LVN_ITEMCHANGING = (LVN_FIRST-0);
  LVN_ITEMCHANGED = (LVN_FIRST-1);
  LVN_DELETEALLITEMS = (LVN_FIRST-4);
  LVN_BEGINLABELEDIT = (LVN_FIRST-75);
  NM_CLICK = (NM_FIRST-2);
  {header}
  HDM_FIRST = $1200;
  HDM_GETITEMCOUNT = (HDM_FIRST + 0);
  {windows}
  WS_CHILD = $40000000;
  HC_ACTION = $0;
  GWL_WNDPROC = (-4);

type
  TLVCache = Array of TWinListView;
var
  _LVControlCache: TLVCache;

function InitCommonCtls(var init: TInitCommonCtls): Boolean; external 'InitCommonControlsEx@comctl32.dll stdcall';
function GetClientRect(handle: Integer; var rect: TWinRect): Boolean; external 'GetClientRect@user32.dll stdcall';
function CreateWindow(exstyle: LongInt; clsName, wndName: String; style: LongInt; x, y, w, h: Integer; parHandle, menu, inst, params: Integer): Integer; external 'CreateWindowExW@user32.dll stdcall';
function MoveWindow(handle, x, y, w, h: Integer; bRepaint: Boolean): Boolean; external 'MoveWindow@user32.dll stdcall';
function ShowWindow(handle: Integer; cmdShow: Integer): Boolean; external 'ShowWindow@user32.dll stdcall';
function LVSendMessageColumn(handle: Integer; msg, wParam: Longint; var LParam: TLVColumn): Longint; external 'SendMessageW@user32.dll stdcall';
function LVSendMessageItem(handle: Integer; msg, wParam: Longint; var LParam: TLVItem): Longint; external 'SendMessageW@user32.dll stdcall';
function CallWindowProc(prevWndProc, handle: Integer; msg: UINT; wParam, LParam: LongInt): Longint; external 'CallWindowProcW@user32.dll stdcall';
function GetWindowLong(handle, index: LongInt): LongInt; external 'GetWindowLongW@user32.dll stdcall setuponly';
function SetWindowLong(handle, index, newvalue: LongInt): LongInt; external 'SetWindowLongW@user32.dll stdcall setuponly';
function WrapWndHookProc(callback: TCWPSTRUCTProc; paramsCount: Integer): LongInt; external 'wrapcallback@files:innocallback.dll'; 
function WrapWndProc(wndProc: TWndProc; numParams: Integer): LongWord; external 'wrapcallback@files:innocallback.dll stdcall';
procedure MapToNMLV(ptr, size: LongInt; var hdr: TNMLISTVIEW); external 'CopyPtrValue@files:listviewhelpers.dll stdcall loadwithalteredsearchpath';

function _ListView_FindCtrl(ctrlHandle: Integer): TWinListView;
var
  i: Integer;
begin
  for i :=0 to GetArrayLength(_LVControlCache)-1 do begin
    if _LVControlCache[i].data.handle = ctrlHandle then begin
      Result := _LVControlCache[i];
      Exit;
    end;
  end;
end;

function _ListView_FindCtrlByParent(parHandle: Integer): TWinListView;
var
  i: Integer;
begin
  for i :=0 to GetArrayLength(_LVControlCache)-1 do begin
    if _LVControlCache[i].data.parHandle = parHandle then begin
      Result := _LVControlCache[i];
      Exit;
    end;
  end;
end;

procedure _ListView_AddCtrl(lv: TWinListView);
var
  i: Integer;
begin
  i := GetArrayLength(_LVControlCache);
  SetArrayLength(_LVControlCache, GetArrayLength(_LVControlCache)+1);
  _LVControlCache[i] := lv;
end;

procedure _ListView_RemoveCtrl(ctrlHandle: Integer);
var
  i: Integer;
begin
  for i :=0 to GetArrayLength(_LVControlCache)-1 do begin
    if _LVControlCache[i].data.handle = ctrlHandle then begin
      _LVControlCache[i].data.handle := 0;
      _LVControlCache[i].data.parHandle := 0;
      Exit;
    end;
  end;
end;

function _ListView_WndProc(handle: Integer; msg: UINT; wParam, lParam: LongInt): LongInt;
var
  lvn: TNMLISTVIEW;
  lv: TWinListView;
  allowChange: Boolean;
begin
  lv := _ListView_FindCtrlByParent(handle);
  if lv.data.handle = 0 then begin
    Log(Format('ListView_WndProc: unable to match control by parent hWnd=%X', [handle]));
    Exit;
    Result := 0;
  end;
  if msg = WM_NOTIFY then begin
    MapToNMLV(lParam, TNMLISTVIEWSIZE, lvn);
    if lvn.hdr.code = LVN_ITEMCHANGING then begin
      allowChange := True;
      if lv.behavior.OnChanging <> nil then begin
        allowChange := lv.behavior.OnChanging(lv.data, lvn);
      end;
      Result := Integer(not allowChange);
      Exit;
    end
    else if (lvn.hdr.code = LVN_ITEMCHANGED) and (lv.behavior.OnClick <> nil) then
      lv.behavior.OnClick(lv.data, lvn)
    else if (lvn.hdr.code = LVN_BEGINLABELEDIT) then begin
      Result := 1;  {Readonly labels}
      Exit;
    end;
  end;
  Result := CallWindowProc(lv.data.oldWndProc, handle, msg, wParam, lParam);
end;

function WinRect(l, t, w, h: Integer): TWinRect;
begin
  Result.left := l;
  Result.top := t;
  Result.right := l + w;
  Result.bottom := t + h;
end;

procedure ListView_Init;
var
  init: TInitCommonCtls;
begin
  init.dwSize := 8;
  init.dwICC := ICC_LISTVIEW_CLASSES;
  InitCommonCtls(init);
end;

function ListView_BeginCreate(parHandle: Integer; rc: TWinRect): TWinListView;
var
  r: Integer;
begin
  Result.data.parHandle := parHandle;
  Result.data.handle := CreateWindow(0, WC_LISTVIEW, '',
    WS_CHILD or LVS_REPORT or LVS_EDITLABELS or LVS_SINGLESEL or LVS_SHOWSELALWAYS,
    rc.left, rc.top, rc.right-rc.left, rc.bottom-rc.top, parHandle, 0, 0, 0);
  {Log(Format('ListView_Create: ctrl hWnd=%X', [Result.data.handle]));}
  SendMessage(Result.data.handle, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, WS_EX_CLIENTEDGE or LVS_EX_FULLROWSELECT or
              LVS_EX_FLATSB or LVS_EX_GRIDLINES or LVS_EX_AUTOSIZECOLUMNS or LVS_EX_LABELTIP or
              LVS_EX_BORDERSELECT or LVS_EX_COLUMNOVERFLOW);
  r := SendMessage(Result.data.handle, LVM_SETOUTLINECOLOR, 0, $0);
  Result.data.oldWndProc := SetWindowLong(parHandle, GWL_WNDPROC, WrapWndProc(@_ListView_WndProc, 4));
end;

procedure ListView_FinalizeCreate(lv: TWinListView);
begin
  _ListView_AddCtrl(lv);
end;

procedure ListView_Free(lv: TWinListView);
begin
  SetWindowLong(lv.data.handle, GWL_WNDPROC, lv.data.oldWndProc);
  lv.data.oldWndProc := 0;
  _ListView_RemoveCtrl(lv.data.handle);
end;

procedure ListView_AddColumn(lv: TWinListView; col, width: Integer; caption: String);
var
  colData: TLVColumn;
  r: Longint;
begin
  with colData do begin
    {format, width, text and subitem members of the structure are valid}
    mask := LVCF_FMT or LVCF_WIDTH or LVCF_TEXT or LVCF_SUBITEM;
    iSubItem := col;
    value := caption;
    cx := ScaleX(width);  {column width}
    fmt := LVCFMT_LEFT;
  end;
  r := LVSendMessageColumn(lv.data.handle, LVM_INSERTCOLUMN, col, colData);
  if r = -1 then
    Log('ListView_InsertColumn failed.');
end;

procedure ListView_AddItem(lv: TWinListView; item: Integer; caption: String);
var
  itemData: TLVItem;
  r: Longint;
begin
  with itemData do begin
    {text, image, state members of the structure are valid}
    mask := LVIF_TEXT or LVIF_IMAGE or LVIF_STATE;
    iSubItem := 0;
    {value := -1;} {Sends an LVN_GETDISPINFO message}
    value := caption;
    iItem := item;
    iImage := item;
    state := 0;
    stateMask := 0;
  end;
  r := LVSendMessageItem(lv.data.handle, LVM_INSERTITEM, 0, itemData);
  if r = -1 then
    Log('ListView_InsertItem failed.');
end;

procedure ListView_AddSubitem(lv: TWinListView; item, subitem: Integer; caption: String);
var
  itemData: TLVItem;
  r: Longint;
begin
  with itemData do begin
    {text, image, state members of the structure are valid}
    mask := LVIF_TEXT;
    iSubItem := subitem;
    value := caption;
  end;
  r := LVSendMessageItem(lv.data.handle, LVM_SETITEMTEXT, item, itemData);
  if r = -1 then
    Log('ListView_SetItemText failed.');
end;

function ListView_GetItemCount(lv: TWinListView): Integer;
begin
  Result := SendMessage(lv.data.handle, LVM_GETITEMCOUNT, 0, 0);
end;

function ListView_GetItemText(lv: TWinListView; item, subitem: Integer): String;
var
  itemData: TLVItem;
  r: Integer;
  buf: String;
begin
  buf := StringOfChar(#0, MAXPATH);
  with itemData do begin
    {text member(s) of the structure are valid}
    mask := LVIF_TEXT;
    iSubItem := subitem;
    value := PAnsiChar(buf);
    valueMax := MAXPATH;
  end;
  r := LVSendMessageItem(lv.data.handle, LVM_GETITEMTEXT, item, itemData);
  if r = -1 then
    Log('ListView_GetItem failed.')
  else
    Result := Copy(itemData.value, 0, r);
end;

function ListView_GetSelectedItem(lv: TWinListView): Integer;
begin
  Result := SendMessage(lv.data.handle, LVM_GETNEXTITEM, -1, LVNI_SELECTED);
end;

procedure ListView_SelectItem(lv: TWinListView; item: Integer);
var
  itemData: TLVItem;
  r: Longint;
begin
  with itemData do begin
    state := LVIS_FOCUSED or LVIS_SELECTED;
    mask := $0F;
  end;
  r := LVSendMessageItem(lv.data.handle, LVM_SETITEMSTATE, item, itemData);
  if r = -1 then
    Log('ListView_SetItemText failed.');
end;

procedure ListView_SetBkColor(lv: TWinListView; color: Integer);
begin
  SendMessage(lv.data.handle, LVM_SETBKCOLOR, 0, color);
end;

procedure ListView_SetTextBkColor(lv: TWinListView; color: Integer);
begin
  SendMessage(lv.data.handle, LVM_SETTEXTBKCOLOR, 0, color);
end;

procedure ListView_DeleteAllItems(lv: TWinListView);
var
  r: Longint;
begin
  r := SendMessage(lv.data.handle, LVM_DELETEALLITEMS, 0, 0);
  if r = -1 then
    Log('ListView_DeleteAllItems failed.');
end;

function ListView_GetColumnCount(lv: TWinListView): Integer;
var
  hH: Integer;
begin
  hH := SendMessage(lv.data.handle, LVM_GETHEADER, 0, 0);
  Result := SendMessage(hH, HDM_GETITEMCOUNT, 0, 0);
end;

procedure ListView_AutoSize(lv: TWinListView);
var
  r, hW, cW, lvW, i, numCols: Integer;
begin
  {numCols := ListView_GetColumnCount(lv);
   for i := 0 to numCols-1 do begin}
  i := 0; {only resize the first column}
    SendMessage(lv.data.handle, LVM_SETCOLUMNWIDTH, i, LVSCW_AUTOSIZE_USEHEADER);
    hW := hW + SendMessage(lv.data.handle, LVM_GETCOLUMNWIDTH, i, 0);
    SendMessage(lv.data.handle, LVM_SETCOLUMNWIDTH, i, LVSCW_AUTOSIZE);
    cW := cW + SendMessage(lv.data.handle, LVM_GETCOLUMNWIDTH, i, 0);
  {end;}
  if hW > cW then begin
    SendMessage(lv.data.handle, LVM_SETCOLUMNWIDTH, i, hW);
    lvW := lvW + hW;
  end
  else
    lvW := lvW + cW;
end;
