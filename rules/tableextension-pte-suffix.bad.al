tableextension 50101 "DIR Customer" extends Customer
{
    fields
    {
        field(50100; "Preferred Carrier"; Code[20]) // no suffix
        {
            Caption = 'Preferred Carrier';
            DataClassification = CustomerContent;
            TableRelation = "DIR Carrier";
        }
        field(50101; "PTE Carrier Note"; Text[100]) // prefix, not suffix
        {
            Caption = 'Carrier Note';
            DataClassification = CustomerContent;
        }
    }

    procedure CheckPreferredCarrierPte() // wrong case
    begin
    end;
}
