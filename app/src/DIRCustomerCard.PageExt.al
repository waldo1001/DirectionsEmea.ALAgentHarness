pageextension 50100 "DIR Customer Card" extends "Customer Card"
{
    layout
    {
        addlast(Shipping)
        {
            field("DIR Preferred Carrier PTE"; Rec."DIR Preferred Carrier PTE")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the carrier that ships this customer''s orders.';
            }
        }
    }
}
