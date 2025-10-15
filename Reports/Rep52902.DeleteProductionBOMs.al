report 52902 "NTS Delete Production BOMs"
{
    ApplicationArea = All;
    Caption = 'Delete Production BOMs';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;

    trigger OnPreReport()
    var
        RowNoVarLcl: Integer;
        ColNoVarLcl: Integer;
        MaxRowNoVarLcl: Integer;
        BOMNoVarLcl: Code[20];
        BOMCount: Integer;
    begin
        ReadExcelSheet();

        RowNoVarLcl := 0;
        ColNoVarLcl := 0;
        MaxRowNoVarLcl := 0;
        BOMCount := 0;

        TempExcelBufferRecGbl.Reset();
        if TempExcelBufferRecGbl.FindLast() then begin
            MaxRowNoVarLcl := TempExcelBufferRecGbl."Row No.";
        end;

        for RowNoVarLcl := 2 to MaxRowNoVarLcl do begin
            BOMNoVarLcl := GetValueAtCell(RowNoVarLcl, 1);
            Evaluate(Status, GetValueAtCell(RowNoVarLcl, 3));

            if BOMNoVarLcl <> '' then begin
                ProdBOMHeaderGbl.Get(BOMNoVarLcl);
                if (Status = Status::Closed) then begin
                    case ProdBOMHeaderGbl.Status of
                        ProdBOMHeaderGbl.Status::Closed:
                            begin
                                DeleteBOMs(ProdBOMHeaderGbl);
                                BOMCount += 1;
                            end;
                        ProdBOMHeaderGbl.Status::Certified:
                            begin
                                ProdBOMHeaderGbl.Status := ProdBOMHeaderGbl.Status::Closed;
                                ProdBOMHeaderGbl.Modify(true);
                                DeleteBOMs(ProdBOMHeaderGbl);
                                BOMCount += 1;
                            end;
                    end;

                end;
            end;
        end;
        Message('Production Boms deleted are %1', BOMCount);
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

    local procedure DeleteBOMs(var BOMHeader: Record "Production BOM Header")
    begin
        ProdBOMLineGbl.SetRange("Production BOM No.", BOMHeader."No.");
        ProdBOMLineGbl.DeleteAll(true);
        BOMHeader.Delete(true);
    end;

    var
        TempExcelBufferRecGbl: Record "Excel Buffer" temporary;
        ProdBOMHeaderGbl: Record "Production BOM Header";
        ProdBOMLineGbl: Record "Production BOM Line";
        Status: Enum "BOM Status";
        FileNameVarLcl: Text[100];
        SheetNameVarLcl: Text[100];
        UploadExcelMsg: Label 'Please Choose the Excel file.';
        NoFileFoundMsg: Label 'No Excel file found!';
}
