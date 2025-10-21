table 52900 "NTS Items Staging"
{
    Caption = 'Items Staging';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(3; Processed; Boolean)
        {
            Caption = 'Processed';
        }
        field(4; "Error Text"; Text[250])
        {
            Caption = 'Error Text';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    var
        ItemsStagingRecLcl: Record "NTS Items Staging";
    begin
        if ItemsStagingRecLcl.FindLast() then
            "Entry No." := ItemsStagingRecLcl."Entry No." + 1
        else
            "Entry No." := 1;
    end;
}
