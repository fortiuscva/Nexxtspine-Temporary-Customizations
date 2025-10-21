codeunit 52900 "NTS Handle Exceptions"
{


    Subtype = Normal;
    [TryFunction]

    procedure DeleteItems(ItemNo: Code[20])
    var
        ItemRec: Record Item;
    begin
        if ItemRec.Get(ItemNo) then begin
            ItemRec.Delete(true);
        end;

    end;

}
