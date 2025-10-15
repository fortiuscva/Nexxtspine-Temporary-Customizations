report 52901 "NTS Delete Items"
{
    ApplicationArea = All;
    Caption = 'Delete Items';
    UsageCategory = ReportsAndAnalysis;
    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", SystemCreatedAt;

            trigger OnPreDataItem()
            var
                StartDateTime: DateTime;
                EndDateTime: DateTime;
            begin
                StartDateTime := CreateDateTime(Today, 000000T);
                EndDateTime := CreateDateTime(Today + 1, 000000T);

                SetRange(SystemCreatedAt, StartDateTime, EndDateTime - 1);

                ItemsCount := Item.Count;
            end;

            trigger OnAfterGetRecord()
            begin
                Delete(true);
            end;

            trigger OnPostDataItem()
            begin
                Message('Items deleted are %1', ItemsCount);
            end;
        }
    }

    var
        ItemsCount: Integer;
}
