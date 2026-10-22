tableextension 50101 "DIR Customer" extends Customer
{
    fields
    {
        field(50100; "DIR Preferred Carrier PTE"; Code[20])
        {
            Caption = 'Preferred Carrier';
            DataClassification = CustomerContent;
            TableRelation = "DIR Carrier";
        }
    }

    procedure CheckPreferredCarrierPTE()
    var
        DIRCustomerCheckCarrierMeth: Codeunit "DIR Customer CheckCarrier Meth";
    begin
        DIRCustomerCheckCarrierMeth.CheckPreferredCarrier(Rec);
    end;
}