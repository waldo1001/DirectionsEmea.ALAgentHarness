// Sample: two objects shown together for reading. In an app each is its own file.
// Two public procedures: both become API, both get called from everywhere.
codeunit 50102 "DIR Customer CheckCarrier Meth"
{
    procedure CheckPreferredCarrier(Customer: Record Customer)
    begin
        if not HasPreferredCarrier(Customer) then
            Error(NoPreferredCarrierErr, Customer."No.");
    end;

    procedure HasPreferredCarrier(Customer: Record Customer): Boolean // must be local
    begin
        exit(Customer."Preferred Carrier PTE" <> '');
    end;

    var
        NoPreferredCarrierErr: Label 'Customer %1 has no preferred carrier.', Comment = '%1 = Customer No.';
}

// An event subscriber calling the Meth codeunit directly instead of the table procedure.
codeunit 50103 "DIR Sales Release Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", OnBeforeReleaseSalesDoc, '', false, false)]
    local procedure CheckCarrierOnBeforeRelease(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        DIRCustomerCheckCarrierMeth: Codeunit "DIR Customer CheckCarrier Meth"; // not from here
    begin
        Customer.Get(SalesHeader."Sell-to Customer No.");
        DIRCustomerCheckCarrierMeth.CheckPreferredCarrier(Customer);
    end;
}
