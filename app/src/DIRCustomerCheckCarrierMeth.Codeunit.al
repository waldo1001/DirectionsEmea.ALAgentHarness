codeunit 50100 "DIR Customer CheckCarrier Meth"
{
    procedure CheckPreferredCarrier(var Customer: Record Customer)
    var
        IsHandled: Boolean;
    begin
        OnBeforeCheckPreferredCarrier(Customer, IsHandled);
        DoCheckPreferredCarrier(Customer, IsHandled);
        OnAfterCheckPreferredCarrier(Customer);
    end;

    local procedure DoCheckPreferredCarrier(var Customer: Record Customer; IsHandled: Boolean)
    var
        DIRCarrier: Record "DIR Carrier";
        NoPreferredCarrierErr: Label 'Customer %1 has no preferred carrier. Set one on the customer card before you release the order.', Comment = '%1 = Customer No.';
        PreferredCarrierBlockedErr: Label 'Preferred carrier %1 of customer %2 is blocked.', Comment = '%1 = Carrier Code, %2 = Customer No.';
    begin
        if IsHandled then
            exit;
        if Customer."DIR Preferred Carrier PTE" = '' then
            Error(NoPreferredCarrierErr, Customer."No.");
        DIRCarrier.Get(Customer."DIR Preferred Carrier PTE");
        if DIRCarrier.Blocked then
            Error(PreferredCarrierBlockedErr, DIRCarrier."Code", Customer."No.");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckPreferredCarrier(var Customer: Record Customer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckPreferredCarrier(var Customer: Record Customer)
    begin
    end;
}
