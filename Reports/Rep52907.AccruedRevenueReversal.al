report 52907 "NTS Accrued Revenue Reversal"
{
    Caption = 'Accrued Revenue Reversal';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(GLEntry; "G/L Entry")
        {
            DataItemTableView = sorting("Posting Date");
            RequestFilterFields = "G/L Account No.", "Posting Date";

            trigger OnPreDataItem()
            begin
                if GetFilter("G/L Account No.") = '' then
                    Error('G/L Account No. must be specified.');

                if GetFilter("Posting Date") = '' then
                    Error('Posting Date filter must be specified.');

                if not GenJnlBatch.Get(JournalTemplateName, JournalBatchName) then
                    Error(
                        'Journal Batch %1 does not exist in Template %2.',
                        JournalBatchName, JournalTemplateName);

                GenJnlLine.LockTable();
                GenJnlLine.Reset();
                GenJnlLine.SetRange("Journal Template Name", JournalTemplateName);
                GenJnlLine.SetRange("Journal Batch Name", JournalBatchName);

                if GenJnlLine.FindLast() then
                    LineNo := GenJnlLine."Line No.";
            end;

            trigger OnAfterGetRecord()
            var
                EntryMonth: Date;
            begin
                EntryMonth := DMY2Date(
                    1,
                    Date2DMY("Posting Date", 2),
                    Date2DMY("Posting Date", 3));

                if CurrentMonth = 0D then
                    CurrentMonth := EntryMonth;

                if EntryMonth <> CurrentMonth then begin
                    CreateJournalLine();

                    CurrentMonth := EntryMonth;
                    Clear(MonthAmount);
                end;

                MonthAmount += Amount;
            end;

            trigger OnPostDataItem()
            begin
                CreateJournalLine();

                if CreatedLineCount = 0 then
                    Error('No non-zero monthly balances found.');

                Message(
                    '%1 reversal journal lines generated in batch %2.',
                    CreatedLineCount, JournalBatchName);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Reversal Options';

                    field(DocumentNo; DocumentNo)
                    {
                        Caption = 'Document No.';
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        JournalTemplateName := 'GENERAL';
        JournalBatchName := 'ACCRUEDREV';

        if DocumentNo = '' then
            DocumentNo := 'ACCRREV';
    end;

    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";

        JournalTemplateName: Code[10];
        JournalBatchName: Code[10];
        DocumentNo: Code[20];

        CurrentMonth: Date;
        MonthAmount: Decimal;
        LineNo: Integer;
        CreatedLineCount: Integer;

    local procedure CreateJournalLine()
    var
        PostingDate: Date;
    begin
        if (CurrentMonth = 0D) or (MonthAmount = 0) then
            exit;

        PostingDate := CalcDate('<CM>', CurrentMonth);

        CheckDuplicateJournalLine(PostingDate);

        LineNo += 10000;

        GenJnlLine.Init();
        GenJnlLine.Validate(
            "Journal Template Name", JournalTemplateName);
        GenJnlLine.Validate("Journal Batch Name", JournalBatchName);

        GenJnlLine."Line No." := LineNo;

        GenJnlLine.Validate("Posting Date", PostingDate);
        GenJnlLine.Validate("Document No.", DocumentNo);
        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");

        GenJnlLine.Validate("Account No.", GLEntry."G/L Account No.");
        GenJnlLine.Validate(Description, 'Accrued Revenue Reversal');
        GenJnlLine.Validate(Amount, -MonthAmount);

        GenJnlLine.Insert(true);
        CreatedLineCount += 1;
    end;

    local procedure CheckDuplicateJournalLine(PostingDate: Date)
    begin
        GenJnlLine.Reset();
        GenJnlLine.SetRange(
            "Journal Template Name", JournalTemplateName);
        GenJnlLine.SetRange(
            "Journal Batch Name", JournalBatchName);
        GenJnlLine.SetRange("Posting Date", PostingDate);
        GenJnlLine.SetRange("Document No.", DocumentNo);
        GenJnlLine.SetRange("Account Type", GenJnlLine."Account Type"::"G/L Account");
        GenJnlLine.SetRange("Account No.", GLEntry."G/L Account No.");

        if GenJnlLine.FindFirst() then
            Error(
                'A reversal journal already exists for Account %1 and Posting Date %2.',
                GLEntry."G/L Account No.", PostingDate);
    end;
}
