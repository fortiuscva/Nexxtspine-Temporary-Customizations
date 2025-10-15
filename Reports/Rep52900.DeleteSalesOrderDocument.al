report 52900 "Delete Sales Order Document"
{
    ApplicationArea = All;
    Caption = 'Delete Sales Order Document';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;

    dataset
    {
        dataitem(SalesHeader; "Sales Header")
        {

            trigger OnPreDataItem()
            var
                SalesHeader: Record "Sales Header";
                StartDateTime: DateTime;
                EndDateTime: DateTime;
            begin
                StartDateTime := CreateDateTime(Today, 000000T);
                EndDateTime := CreateDateTime(Today + 1, 000000T);

                SetRange("Document Type", "Document Type"::Order);
                SetRange(SystemCreatedAt, StartDateTime, EndDateTime - 1);
            end;

            trigger OnAfterGetRecord()
            begin
                Delete(true);
            end;

            trigger OnPostDataItem()
            begin
                Message('Sales Orders deleted.');
            end;
        }
    }
}
