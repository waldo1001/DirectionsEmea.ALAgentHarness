// File: app/src/DIRCustomer.TableExt.al - one object, the file is named after it.
tableextension 50101 "DIR Customer" extends Customer
{
    fields
    {
        field(50100; "Preferred Carrier PTE"; Code[20])
        {
            Caption = 'Preferred Carrier';
            DataClassification = CustomerContent;
            TableRelation = "DIR Carrier";
        }
    }
}
