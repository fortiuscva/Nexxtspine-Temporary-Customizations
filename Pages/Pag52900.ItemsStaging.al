page 52900 "NTS Items Staging"
{
    ApplicationArea = All;
    Caption = 'Items Staging';
    PageType = List;
    SourceTable = "NTS Items Staging";
    UsageCategory = Lists;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                }
                field(Processed; Rec.Processed)
                {
                    ToolTip = 'Specifies the value of the Processed field.', Comment = '%';
                }
                field("Error Text"; Rec."Error Text")
                {
                    ToolTip = 'Specifies the value of the Error Text field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(processing)
        {

            action("Import Items")
            {
                ApplicationArea = All;
                Caption = 'Import Items';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                begin
                    ReadExcelSheet();
                    ImportItems();
                end;
            }
            action(DeleteItems)
            {
                Caption = 'Delete Items';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Process;
                ToolTip = 'This action will delete the Items';
                RunObject = report "NTS Delete Items Staging";
            }
            action(UnflagProcessedFlag)
            {
                Caption = 'Unflag Processed Lines';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Process;
                ToolTip = 'This action will unflag processed flag value on Staging Items';
                trigger OnAction()

                begin
                    if not Confirm(UnProcessedConfirmFlagMsg, false) then
                        Error(ProcessInterruptedMsg);

                    ItemsStagingRecGbl.RESET;
                    ItemsStagingRecGbl.ModifyAll(Processed, false);
                    ItemsStagingRecGbl.ModifyAll("Error Text", '');
                end;

            }

        }
    }
    procedure ImportItems()
    var
        ItemsStagingRecLcl: Record "NTS Items Staging";
        RowNoVarLcl: Integer;
        ColNoVarLcl: Integer;
        MaxRowNoVarLcl: Integer;
    begin

        RowNoVarLcl := 0;
        ColNoVarLcl := 0;
        MaxRowNoVarLcl := 0;

        TempExcelBufferRecGbl.Reset();
        if TempExcelBufferRecGbl.FindLast() then begin
            MaxRowNoVarLcl := TempExcelBufferRecGbl."Row No.";
        end;
        for RowNoVarLcl := 2 to MaxRowNoVarLcl do begin

            ItemsStagingRecLcl.Init();
            ItemsStagingRecLcl.Validate("Item No.", GetValueAtCell(RowNoVarLcl, 1));
            ItemsStagingRecLcl.Insert(true);
            Commit();
        end;
        Message(ExcelImportSucess);
    end;


    local procedure ReadExcelSheet()
    var
        FileMgtCULcl: Codeunit "File Management";
        IStreamVarLcl: InStream;
        FromFileVarLcl: Text[100];
    begin
        UploadIntoStream(UploadExcelMsg, '', '', FromFileVarLcl, IStreamVarLcl);
        if FromFileVarLcl <> '' then begin
            FileNameVarLcl := FileMgtCULcl.GetFileName(FromFileVarLcl);
            SheetNameVarLcl := TempExcelBufferRecGbl.SelectSheetsNameStream(IStreamVarLcl);
        end else
            Error(NoFileFoundMsg);
        TempExcelBufferRecGbl.Reset();
        TempExcelBufferRecGbl.DeleteAll();
        TempExcelBufferRecGbl.OpenBookStream(IStreamVarLcl, SheetNameVarLcl);
        TempExcelBufferRecGbl.ReadSheet();
    end;

    local procedure GetValueAtCell(RowNoVarLcl: Integer; ColNoVarLcl: Integer): Text
    begin

        TempExcelBufferRecGbl.Reset();
        If TempExcelBufferRecGbl.Get(RowNoVarLcl, ColNoVarLcl) then
            exit(TempExcelBufferRecGbl."Cell Value as Text")
        else
            exit('');
    end;

    var
        UnProcessedConfirmFlagMsg: Label 'Do you want to unflag all processed lines?';
        ProcessInterruptedMsg: Label 'Processed Interrupted to respect the Warning';

        TempExcelBufferRecGbl: Record "Excel Buffer" temporary;
        ItemsStagingRecGbl: Record "NTS Items Staging";
        FileNameVarLcl: Text[100];
        SheetNameVarLcl: Text[100];
        UploadExcelMsg: Label 'Please Choose the Excel file.';
        NoFileFoundMsg: Label 'No Excel file found!';
        ExcelImportSucess: Label 'Excel is successfully imported.';

}
