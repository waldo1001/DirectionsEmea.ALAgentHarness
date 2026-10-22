page 50100 "DIR Carriers"
{
    Caption = 'Carriers';
    PageType = List;
    SourceTable = "DIR Carrier";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Carriers)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the code of the carrier.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the carrier.';
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ToolTip = 'Specifies the shipping agent that this carrier ships with.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies that the carrier can no longer be used.';
                }
            }
        }
    }
}
