report 52904 "NTS Update Drawing Description"
{
    ApplicationArea = All;
    Caption = 'Update Drawing Description';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;
    dataset
    {
        dataitem(Item; Item)
        {
            trigger OnPreDataItem()
            begin
                SetFilter("IMP Drawing Number", '<>%1', '');
            end;

            trigger OnAfterGetRecord()
            begin
                if "IMP Drawing Number" <> '' then begin
                    Validate("IMP Drawing Number", "IMP Drawing Number");
                    UpdatedCount += 1;
                end;
                Modify(true);

            end;
        }
    }

    trigger OnPostReport()
    begin
        Message('%1 items have been refreshed successfully.', UpdatedCount);
    end;

    var
        UpdatedCount: Integer;

}
