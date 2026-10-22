codeunit 80100 "DIR Preferred Carrier Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        NoPreferredCarrierErr: Label 'Customer %1 has no preferred carrier. Set one on the customer card before you release the order.', Comment = '%1 = Customer No.';
        PreferredCarrierBlockedErr: Label 'Preferred carrier %1 of customer %2 is blocked.', Comment = '%1 = Carrier Code, %2 = Customer No.';

    [Test]
    procedure ReleaseOrderWithoutPreferredCarrierFails()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO] AC1 - A Sales Order of a customer without a Preferred Carrier cannot be released
        // [GIVEN] A customer with an empty Preferred Carrier
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] A Sales Order with a line for that customer
        CreateSalesDocument(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // The failing release rolls back the uncommitted transaction; commit the order so its Status can be checked
        Commit();

        // [WHEN] The order is released
        asserterror LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [THEN] The release fails with NoPreferredCarrierErr and the order stays Open
        Assert.ExpectedError(StrSubstNo(NoPreferredCarrierErr, Customer."No."));
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        Assert.AreEqual(SalesHeader.Status::Open, SalesHeader.Status, 'Status of the sales order');
    end;

    [Test]
    procedure ReleaseOrderWithBlockedPreferredCarrierFails()
    var
        Customer: Record Customer;
        DIRCarrier: Record "DIR Carrier";
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO] AC2 - A Sales Order of a customer with a Blocked Preferred Carrier cannot be released
        // [GIVEN] A customer with a Blocked Preferred Carrier
        CreateCarrier(DIRCarrier, true);
        CreateCustomerWithCarrier(Customer, DIRCarrier.Code);
        // [GIVEN] A Sales Order with a line for that customer
        CreateSalesDocument(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // The failing release rolls back the uncommitted transaction; commit the order so its Status can be checked
        Commit();

        // [WHEN] The order is released
        asserterror LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [THEN] The release fails with PreferredCarrierBlockedErr and the order stays Open
        Assert.ExpectedError(StrSubstNo(PreferredCarrierBlockedErr, DIRCarrier.Code, Customer."No."));
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        Assert.AreEqual(SalesHeader.Status::Open, SalesHeader.Status, 'Status of the sales order');
    end;

    [Test]
    procedure ReleaseOrderWithPreferredCarrierSucceeds()
    var
        Customer: Record Customer;
        DIRCarrier: Record "DIR Carrier";
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO] AC3 - A Sales Order of a customer with a usable Preferred Carrier is released
        // [GIVEN] A customer with a Preferred Carrier that is not Blocked
        CreateCarrier(DIRCarrier, false);
        CreateCustomerWithCarrier(Customer, DIRCarrier.Code);
        // [GIVEN] A Sales Order with a line for that customer
        CreateSalesDocument(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");

        // [WHEN] The order is released
        LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [THEN] The order is Released
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        Assert.AreEqual(SalesHeader.Status::Released, SalesHeader.Status, 'Status of the sales order');
    end;

    [Test]
    procedure ReleaseQuoteWithoutPreferredCarrierSucceeds()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO] AC4 - A Sales Quote is released whatever the Preferred Carrier
        // [GIVEN] A customer with an empty Preferred Carrier
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] A Sales Quote with a line for that customer
        CreateSalesDocument(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");

        // [WHEN] The quote is released
        LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [THEN] The quote is Released
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        Assert.AreEqual(SalesHeader.Status::Released, SalesHeader.Status, 'Status of the sales quote');
    end;

    local procedure CreateCarrier(var DIRCarrier: Record "DIR Carrier"; IsBlocked: Boolean)
    begin
        DIRCarrier.Init();
        DIRCarrier.Code := LibraryUtility.GenerateRandomCode(DIRCarrier.FieldNo(Code), Database::"DIR Carrier");
        DIRCarrier.Blocked := IsBlocked;
        DIRCarrier.Insert(true);
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
        LibrarySales.CreateSalesDocumentWithItem(SalesHeader, SalesLine, DocumentType, CustomerNo, '', 1, '', WorkDate());
    end;
}
