pageextension 50101 "DIR Customer Card" extends "Customer Card"
{
    actions
    {
        addlast(processing)
        {
            action(DIRCheckPreferredCarrier)
            {
                ApplicationArea = All;
                Caption = 'Check Preferred Carrier';
                ToolTip = 'Checks that the customer has a preferred carrier.';
                Image = CheckList;

                trigger OnAction()
                begin
                    Rec.CheckPreferredCarrierPTE();
                end;
            }
        }
    }
}
