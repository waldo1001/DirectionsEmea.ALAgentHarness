codeunit 50104 "DIR Carrier Notifications"
{
    procedure NotifyCarrierAssigned(Customer: Record Customer)
    var
        CarrierAssignedMsg: Label 'Carrier %1 is now the preferred carrier of customer %2.', Comment = '%1 = Carrier Code, %2 = Customer No.';
    begin
        Message(CarrierAssignedMsg, Customer."Preferred Carrier PTE", Customer."No.");
    end;

    procedure ConfirmReleaseWithoutCarrier(SalesHeader: Record "Sales Header"): Boolean
    var
        ReleaseWithoutCarrierQst: Label 'Sales order %1 has no carrier. Release it anyway?', Comment = '%1 = Sales Order No.';
    begin
        exit(Confirm(ReleaseWithoutCarrierQst, false, SalesHeader."No."));
    end;

    procedure ErrorNoPreferredCarrier(Customer: Record Customer)
    var
        NoPreferredCarrierErr: Label 'Customer %1 has no preferred carrier.', Comment = '%1 = Customer No.';
    begin
        Error(NoPreferredCarrierErr, Customer."No.");
    end;
}
