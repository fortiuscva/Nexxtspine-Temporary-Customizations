report 52903 "NTS Delete Items Staging"
{
    Caption = 'Delete Items Staging';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;
    dataset
    {
        dataitem(NTSItemStaging; "NTS Items Staging")
        {
            RequestFilterFields = "Item No.";
            DataItemTableView = sorting("Entry No.") where(Processed = const(false));
            trigger OnAfterGetRecord()
            var
                ItemRec: record Item;
                HandleExceptionsCU: Codeunit "NTS Handle Exceptions";
            begin
                if not HandleExceptionsCU.DeleteItems(NTSItemStaging."Item No.") then begin
                    ErrorTxtGbl := GetLastErrorText();
                    NTSItemStaging."Processed" := false;
                    NTSItemStaging."Error Text" := ErrorTxtGbl;
                end else begin
                    NTSItemStaging."Processed" := true;
                    NTSItemStaging."Error Text" := '';
                    ItemsCount += 1;
                end;
                NTSItemStaging.Modify(true);
                Commit();
            end;

            trigger OnPostDataItem()
            begin
                Message('Items deleted are %1', ItemsCount);
            end;
        }
    }
    var
        ErrorTxtGbl: Text;
        ItemsCount: Integer;
}
