codeunit 50104 "DIR Carrier Notifications"
{
    procedure NotifyCarrierAssigned(Customer: Record Customer)
    var
        Text001: Label 'Carrier %1 is now the preferred carrier of customer %2.'; // meaningless name, no Comment
    begin
        Message(Text001, Customer."Preferred Carrier PTE", Customer."No.");
    end;

    procedure ErrorNoPreferredCarrier(Customer: Record Customer)
    var
        CarrierMsg: Label 'Customer %1 has no preferred carrier.'; // a Msg passed to Error, no Comment
    begin
        Error(CarrierMsg, Customer."No.");
    end;
}
