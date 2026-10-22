table 50100 "DIR Carrier"
{
    Caption = 'Carrier';
    DataClassification = CustomerContent;
    LookupPageId = "DIR Carriers";
    DrillDownPageId = "DIR Carriers";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
        }
        field(4; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description)
        {
        }
    }
}
