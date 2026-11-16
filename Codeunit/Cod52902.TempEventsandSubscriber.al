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

    var
        NexxtSingleInstance: Codeunit "NTS Temp Single Instance";
}
