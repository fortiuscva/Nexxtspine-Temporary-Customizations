codeunit 52901 "NTS Event Management"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reservation Management", OnBeforeCheckQuantityIsCompletelyReleased, '', false, false)]
    local procedure "Reservation Management_OnBeforeCheckQuantityIsCompletelyReleased"(ItemTrackingHandling: Option; QtyToRelease: Decimal; DeleteAll: Boolean; CurrentItemTrackingSetup: Record "Item Tracking Setup" temporary; ReservEntry: Record "Reservation Entry"; var IsHandled: Boolean)
    begin
        if NTSSingleInstance.GetHideDeleteItemTrackingConfirm() then
            IsHandled := true;
    end;

    var
        NTSSingleInstance: Codeunit "NTS Single Instance";
}
