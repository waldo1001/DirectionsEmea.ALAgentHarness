codeunit 80100 "DIR Preferred Carrier Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryUtility: Codeunit "Library - Utility";
        NoPreferredCarrierErr: Label 'Customer %1 has no preferred carrier. Set one on the customer card before you release the order.', Comment = '%1 = Customer No.';
        PreferredCarrierBlockedErr: Label 'Preferred carrier %1 of customer %2 is blocked.', Comment = '%1 = Carrier Code, %2 = Customer No.';

    [Test]
    procedure ReleaseOrderWithoutPreferredCarrierFails()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO] AC1 - an order of a customer without a preferred carrier can not be released
        // [GIVEN] A customer with an empty preferred carrier and a sales order with a line
        LibrarySales.CreateCustomer(Customer);
        CreateSalesDocument(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");

        // [WHEN] The order is released
        asserterror LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [THEN] The release fails with the no-carrier error and the order stays open
        // asserterror rolls back the test's own order too, so the status is read from the record
        Assert.ExpectedError(StrSubstNo(NoPreferredCarrierErr, Customer."No."));
        Assert.AreEqual(SalesHeader.Status::Open, SalesHeader.Status, 'The order must stay open.');
    end;

    [Test]
    procedure ReleaseOrderWithBlockedPreferredCarrierFails()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        CarrierCode: Code[20];
    begin
        // [SCENARIO] AC2 - an order of a customer whose preferred carrier is blocked can not be released
        // [GIVEN] A customer with a blocked preferred carrier and a sales order with a line
        CarrierCode := CreateCarrier(true);
        CreateCustomerWithCarrier(Customer, CarrierCode);
        CreateSalesDocument(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");

        // [WHEN] The order is released
        asserterror LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [THEN] The release fails with the blocked-carrier error and the order stays open
        // asserterror rolls back the test's own order too, so the status is read from the record
        Assert.ExpectedError(StrSubstNo(PreferredCarrierBlockedErr, CarrierCode, Customer."No."));
        Assert.AreEqual(SalesHeader.Status::Open, SalesHeader.Status, 'The order must stay open.');
    end;

    [Test]
    procedure ReleaseOrderWithPreferredCarrierSucceeds()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO] AC3 - an order of a customer with a usable preferred carrier is released
        // [GIVEN] A customer with a preferred carrier that is not blocked and a sales order with a line
        CreateCustomerWithCarrier(Customer, CreateCarrier(false));
        CreateSalesDocument(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");

        // [WHEN] The order is released
        LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [THEN] The order is released
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        Assert.AreEqual(SalesHeader.Status::Released, SalesHeader.Status, 'The order must be released.');
    end;

    [Test]
    procedure ReleaseQuoteWithoutPreferredCarrierSucceeds()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO] AC4 - a quote is not blocked by a missing preferred carrier
        // [GIVEN] A customer with an empty preferred carrier and a sales quote with a line
        LibrarySales.CreateCustomer(Customer);
        CreateSalesDocument(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");

        // [WHEN] The quote is released
        LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [THEN] The quote is released
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        Assert.AreEqual(SalesHeader.Status::Released, SalesHeader.Status, 'The quote must be released.');
    end;

    local procedure CreateCarrier(IsBlocked: Boolean): Code[20]
    var
        DIRCarrier: Record "DIR Carrier";
    begin
        DIRCarrier.Init();
        DIRCarrier."Code" := LibraryUtility.GenerateRandomCode(DIRCarrier.FieldNo("Code"), Database::"DIR Carrier");
        DIRCarrier.Blocked := IsBlocked;
        DIRCarrier.Insert();
        exit(DIRCarrier."Code");
    end;

    local procedure CreateCustomerWithCarrier(var Customer: Record Customer; CarrierCode: Code[20])
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("DIR Preferred Carrier PTE", CarrierCode);
        Customer.Modify(true);
    end;

    local procedure CreateSalesDocument(var SalesHeader: Record "Sales Header"; DocumentType: Enum "Sales Document Type"; CustomerNo: Code[20])
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItemNo(), 1);
    end;
}
