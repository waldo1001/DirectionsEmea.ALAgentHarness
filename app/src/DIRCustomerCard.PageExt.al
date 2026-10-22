pageextension 50104 "DIR Customer Card" extends "Customer Card"
{
    layout
    {
        addlast(Shipping)
        {
            field("DIR Preferred Carrier"; Rec."DIR Preferred Carrier")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the carrier that ships orders to this customer. A sales order can only be released when its sell-to customer has a preferred carrier that is not blocked.';
            }
        }
    }
}
