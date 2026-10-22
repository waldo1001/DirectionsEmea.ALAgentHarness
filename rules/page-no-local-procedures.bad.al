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
                    CheckPreferredCarrier(); // logic reachable only through the page
                end;
            }
        }
    }

    local procedure CheckPreferredCarrier() // no local procedures on pages
    var
        NoPreferredCarrierErr: Label 'Customer %1 has no preferred carrier.', Comment = '%1 = Customer No.';
    begin
        if Rec."Preferred Carrier PTE" = '' then
            Error(NoPreferredCarrierErr, Rec."No.");
    end;
}
