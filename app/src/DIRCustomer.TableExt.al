tableextension 50104 "DIR Customer" extends Customer
{
    fields
    {
        field(50104; "DIR Preferred Carrier"; Code[20])
        {
            Caption = 'Preferred Carrier';
            DataClassification = CustomerContent;
            TableRelation = "DIR Carrier";

            trigger OnValidate()
            var
                PreferredCarrierMgt: Codeunit "DIR Preferred Carrier Mgt.";
            begin
                PreferredCarrierMgt.FillShippingAgentCode(Rec);
            end;
        }
    }
}
