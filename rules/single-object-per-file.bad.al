// File: app/src/PreferredCarrier.al - three objects in one file.
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

pageextension 50101 "DIR Customer Card" extends "Customer Card"
{
    layout
    {
        addlast(Shipping)
        {
            field("DIR Preferred Carrier PTE"; Rec."Preferred Carrier PTE")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the carrier that ships this customer''s orders.';
            }
        }
    }
}

codeunit 50102 "DIR Customer CheckCarrier Meth"
{
    procedure CheckPreferredCarrier(Customer: Record Customer)
    begin
    end;
}
