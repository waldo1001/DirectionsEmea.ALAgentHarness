pageextension 50100 "DIR Customer Card" extends "Customer Card"
{
    layout
    {
        addlast(Shipping)
        {
            field("DIR Preferred Carrier"; Rec."DIR Preferred Carrier")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the carrier that is preferred for shipments to this customer. A sales order cannot be released when this field is empty.';
            }
        }
    }
}
