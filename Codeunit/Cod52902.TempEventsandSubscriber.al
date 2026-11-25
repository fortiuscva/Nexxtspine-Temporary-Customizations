codeunit 52902 "NTS Temp Events and Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reservation Management", OnBeforeDeleteItemTrackingConfirm, '', false, false)]
    local procedure "Reservation Management_OnBeforeDeleteItemTrackingConfirm"(var Sender: Codeunit "Reservation Management"; var CalcReservEntry2: Record "Reservation Entry"; var IsHandled: Boolean; var Result: Boolean)
    begin
        if NexxtSingleInstance.GetHideDeleteItemTrackingConfirm() then begin
            IsHandled := true;
            Result := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl. Line-Reserve", OnBeforeDeleteLine, '', false, false)]
    local procedure "Item Jnl. Line-Reserve_OnBeforeDeleteLine"(var ItemJournalLine: Record "Item Journal Line"; var DeleteItemTracking: Boolean)
    begin
        if NexxtSingleInstance.GetHideDeleteItemTrackingConfirm() then
            DeleteItemTracking := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnProcessBalanceOfLinesOnBeforeCheckLine', '', false, false)]
    local procedure SkipAccruedRevenueBalanceCheck(GenJournalLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
        if (GenJournalLine."Journal Template Name" = 'GENERAL') and
           (GenJournalLine."Journal Batch Name" = 'ACCRUEDREV')
        then
            IsHandled := true;
    end;

    var
        NexxtSingleInstance: Codeunit "NTS Temp Single Instance";
}
