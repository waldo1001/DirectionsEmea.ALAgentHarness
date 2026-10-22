codeunit 50107 "DIR Preferred Carrier Mgt."
{
    var
        NoPreferredCarrierErr: Label 'You cannot release sales order %1 because customer %2 has no preferred carrier.', Comment = '%1 = sales order No.; %2 = Sell-to Customer No.';
        PreferredCarrierBlockedErr: Label 'You cannot release sales order %1 because preferred carrier %2 of customer %3 is blocked.', Comment = '%1 = sales order No.; %2 = carrier Code; %3 = Sell-to Customer No.';

    /// <summary>
    /// Copies the Shipping Agent Code of the customer's preferred carrier to the customer.
    /// An empty value never overwrites what the customer already has.
    /// </summary>
    procedure FillShippingAgentCode(var Customer: Record Customer)
    var
        Carrier: Record "DIR Carrier";
    begin
        if Customer."DIR Preferred Carrier" = '' then
            exit;
        if not Carrier.Get(Customer."DIR Preferred Carrier") then
            exit;
        if Carrier."Shipping Agent Code" = '' then
            exit;

        Customer.Validate("Shipping Agent Code", Carrier."Shipping Agent Code");
    end;

    /// <summary>
    /// Raises an error when the sell-to customer of a sales order has no usable preferred carrier.
    /// Other document types are not checked.
    /// </summary>
    procedure CheckPreferredCarrier(SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        Carrier: Record "DIR Carrier";
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;
        // A missing customer is reported by the standard release checks.
        if not Customer.Get(SalesHeader."Sell-to Customer No.") then
            exit;

        if Customer."DIR Preferred Carrier" = '' then
            Error(NoPreferredCarrierErr, SalesHeader."No.", Customer."No.");
        if not Carrier.Get(Customer."DIR Preferred Carrier") then
            Error(NoPreferredCarrierErr, SalesHeader."No.", Customer."No.");
        if Carrier.Blocked then
            Error(PreferredCarrierBlockedErr, SalesHeader."No.", Carrier.Code, Customer."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", OnBeforeReleaseSalesDoc, '', false, false)]
    local procedure CheckPreferredCarrierOnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean; var SkipCheckReleaseRestrictions: Boolean; SkipWhseRequestOperations: Boolean)
    begin
        CheckPreferredCarrier(SalesHeader);
    end;
}
