// Sample: two objects shown together for reading. In an app each is its own file.
// The tableextension exposes the entry point...
tableextension 50101 "DIR Customer" extends Customer
{
    procedure CheckPreferredCarrierPTE()
    var
        DIRCustomerCheckCarrierMeth: Codeunit "DIR Customer CheckCarrier Meth";
    begin
        DIRCustomerCheckCarrierMeth.CheckPreferredCarrier(Rec);
    end;
}

// ...and the Meth codeunit has exactly one public procedure.
codeunit 50102 "DIR Customer CheckCarrier Meth"
{
    procedure CheckPreferredCarrier(Customer: Record Customer)
    var
        IsHandled: Boolean;
    begin
        OnBeforeCheckPreferredCarrier(Customer, IsHandled);
        DoCheckPreferredCarrier(Customer, IsHandled);
        OnAfterCheckPreferredCarrier(Customer);
    end;

    local procedure DoCheckPreferredCarrier(Customer: Record Customer; IsHandled: Boolean)
    var
        NoPreferredCarrierErr: Label 'Customer %1 has no preferred carrier.', Comment = '%1 = Customer No.';
    begin
        if IsHandled then
            exit;
        if Customer."Preferred Carrier PTE" = '' then
            Error(NoPreferredCarrierErr, Customer."No.");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckPreferredCarrier(Customer: Record Customer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckPreferredCarrier(Customer: Record Customer)
    begin
    end;
}
