codeunit 50101 "DIR Release Sales Doc Subs"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", OnBeforeReleaseSalesDoc, '', false, false)]
    local procedure CheckPreferredCarrierOnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean)
    var
        Customer: Record Customer;
    begin
        if IsHandled then
            exit;
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;
        Customer.Get(SalesHeader."Sell-to Customer No.");
        Customer.CheckPreferredCarrierPTE();
    end;
}
