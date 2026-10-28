report 52906 "NTS Delete Reservation Entries"
{
    Caption = 'Delete Reservation Entries';
    ProcessingOnly = true;
    UsageCategory = None;
    dataset
    {
        dataitem(ReservationEntry; "Reservation Entry")
        {
            DataItemTableView = sorting("Entry No.", Positive);
            RequestFilterFields = "Entry No.", "Source ID", "Source Type", "Source Subtype", "Source Ref. No.", "Source Prod. Order Line", "Source Batch Name";

            trigger OnPreDataItem()
            begin
                if GetFilters = '' then
                    Error('You must select atleast one filter');
            end;

            trigger OnAfterGetRecord()
            begin
                delete(true);
            end;
        }
    }
}
