tableextension 50100 "DIR Customer" extends Customer
{
    fields
    {
        field(50100; "DIR Preferred Carrier"; Code[20])
        {
            Caption = 'Preferred Carrier';
            DataClassification = CustomerContent;
            TableRelation = "DIR Carrier";
        }
    }
}
