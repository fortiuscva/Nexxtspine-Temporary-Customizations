report 52903 "NTS Delete Items Staging"
{
    ApplicationArea = All;
    Caption = 'Delete Items Staging';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;
    dataset
    {
        dataitem(NTSItemStaging; "NTS Items Staging")
        {
            RequestFilterFields = "Item No.";
            trigger OnAfterGetRecord()
            var
                ItemRec: record Item
            ;
            begin
                if not (ItemRec.Get(NTSItemStaging."Item No.")) then begin
                    ErrorTxtGbl := GetLastErrorText();
                    NTSItemStaging."Processed" := false;
                    NTSItemStaging."Error Text" := ErrorTxtGbl;
                end else begin
                    ItemRec.Delete(true);
                    NTSItemStaging."Processed" := true;
                    NTSItemStaging."Error Text" := '';
                    ItemsCount += 1;
                end;
                NTSItemStaging.Modify(true);
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
