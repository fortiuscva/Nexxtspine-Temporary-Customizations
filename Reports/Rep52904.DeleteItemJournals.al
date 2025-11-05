report 52904 "NTS Delete Item Journals"
{
    ApplicationArea = All;
    Caption = 'Delete Item Journals With  Duplicate Serial Nos';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;
    dataset
    {
        dataitem(ItemJournalLine; "Item Journal Line")
        {
            RequestFilterFields = "Journal Template Name", "Journal Batch Name";

            trigger OnAfterGetRecord()
            var
                ForReservEntry: Record "Reservation Entry";
                ItemLedgerEntry: Record "Item Ledger Entry";
                ItemJournalLineRec: Record "Item Journal Line";
                LineNo: Integer;
                DuplicateFound: Boolean;
                ForReservEntry1: Record "Reservation Entry";
                CreateReservEntry: Codeunit "Create Reserv. Entry";
            begin
                LineNo := 10000;

                // Get tracking lines
                ForReservEntry.Reset();
                ForReservEntry.SetRange("Source Type", DATABASE::"Item Journal Line");
                ForReservEntry.SetRange("Source Subtype", 2);
                ForReservEntry.SetRange("Source ID", ItemJournalLine."Journal Template Name");
                ForReservEntry.SetRange("Source Batch Name", ItemJournalLine."Journal Batch Name");
                ForReservEntry.SetRange("Source Ref. No.", ItemJournalLine."Line No.");
                ForReservEntry.SetRange("Item No.", ItemJournalLine."Item No.");

                if ForReservEntry.FindFirst() then begin
                    if ForReservEntry."Serial No." <> '' then begin
                        ItemLedgerEntry.Reset();
                        ItemLedgerEntry.SetRange("Item No.", ItemJournalLine."Item No.");
                        ItemLedgerEntry.SetRange("Serial No.", ForReservEntry."Serial No.");
                        If ItemLedgerEntry.FindFirst() then begin
                            SerialNoGbl := ForReservEntry."Serial No.";

                            // Find next line no. in Serial No. Errors batch
                            ItemJournalLineRec.Reset();
                            ItemJournalLineRec.SetRange("Journal Template Name", ItemJournalLine."Journal Template Name");
                            ItemJournalLineRec.SetRange("Journal Batch Name", 'SERIALNOER');
                            if ItemJournalLineRec.FindLast() then
                                LineNo := ItemJournalLineRec."Line No." + 10000;

                            // Copy to Serial No. Errors batch
                            ItemJournalLineRec.Init();
                            ItemJournalLineRec.TransferFields(ItemJournalLine);
                            ItemJournalLineRec."Journal Batch Name" := 'SERIALNOER';
                            ItemJournalLineRec."Line No." := LineNo;
                            ItemJournalLineRec.Insert(true);



                            ItemJournalLineRec.SetReservationEntry(ForReservEntry1);
                            ForReservEntry1."Serial No." := SerialNoGbl;
                            CreateReservEntry.CreateReservEntryFor(DATABASE::"Item Journal Line", ItemJournalLineRec."Entry Type".AsInteger(), ItemJournalLineRec."Journal Template Name", ItemJournalLineRec."Journal Batch Name", 0, ItemJournalLineRec."Line No.", ItemJournalLineRec."Qty. per Unit of Measure", ItemJournalLineRec.Quantity, ItemJournalLineRec."Quantity (Base)", ForReservEntry1);
                            CreateReservEntry.CreateEntry(ItemJournalLineRec."Item No.", ItemJournalLineRec."Variant Code", ItemJournalLineRec."Location Code", ItemJournalLineRec.Description, 0D, ItemJournalLineRec."Posting Date", 0, ForReservEntry."Reservation Status"::Prospect);

                            // Delete from source batch without showing any confirmation
                            NTSSingleInstance.SetHideDeleteItemTrackingConfirm(true);
                            ItemJournalLine.Delete(true);
                            NTSSingleInstance.SetHideDeleteItemTrackingConfirm(false);
                        end;
                    end;
                end;
            end;
        }
    }
    var
        SerialNoGbl: Code[50];
        NTSSingleInstance: Codeunit "NTS Single Instance";
}
