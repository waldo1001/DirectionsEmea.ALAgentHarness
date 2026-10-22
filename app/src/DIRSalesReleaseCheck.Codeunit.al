codeunit 50100 "DIR Sales Release Check"
{
    Access = Internal;

    var
        NoPreferredCarrierErr: Label 'You cannot release %1 %2 because customer %3 has no %4.', Comment = '%1 = Document Type, %2 = Document No., %3 = Customer No., %4 = Preferred Carrier field caption';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", OnBeforeReleaseSalesDoc, '', false, false)]
    local procedure CheckPreferredCarrierOnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header")
    begin
        CheckPreferredCarrier(SalesHeader);
    end;

    local procedure CheckPreferredCarrier(SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;
        if SalesHeader.Status = SalesHeader.Status::Released then
            exit;

        Customer.SetLoadFields("DIR Preferred Carrier");
        Customer.Get(SalesHeader."Sell-to Customer No.");
        if Customer."DIR Preferred Carrier" = '' then
            Error(NoPreferredCarrierErr, SalesHeader."Document Type", SalesHeader."No.", Customer."No.", Customer.FieldCaption("DIR Preferred Carrier"));
    end;
}
