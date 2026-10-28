report 52905 "NTS Delete Item Journal Lines"
{
    ApplicationArea = All;
    Caption = 'Delete Item Journal Lines with Tracking';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;
    dataset
    {
        dataitem(ItemJnlLine; "Item Journal Line")
        {
            RequestFilterFields = "Journal Template Name", "Journal Batch Name";
            trigger OnAfterGetRecord()
            begin
                SingleInstanceCU.SetHideDeleteItemTrackingConfirm(true);

                ItemJnlLine.Delete(true);

                SingleInstanceCU.SetHideDeleteItemTrackingConfirm(false);
            end;
        }
    }
    var
        SingleInstanceCU: Codeunit "NTS Single Instance";
        ItemJnlLineReserve: Codeunit "Item Jnl. Line-Reserve";
}