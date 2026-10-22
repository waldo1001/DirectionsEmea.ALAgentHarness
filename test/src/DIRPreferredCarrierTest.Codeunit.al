codeunit 80100 "DIR Preferred Carrier Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit "Library Assert";

    [Test]
    procedure ReleaseSalesOrderWithoutPreferredCarrierFails()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        // [GIVEN] A customer without a preferred carrier and a sales order for that customer
        LibrarySales.CreateCustomer(Customer);
        CreateSalesDocument(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");

        // [WHEN] The sales order is released
        asserterror LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [THEN] The release is blocked and the order stays open
        Assert.ExpectedError(Customer.FieldCaption("DIR Preferred Carrier"));
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        SalesHeader.TestField(Status, SalesHeader.Status::Open);
    end;

    [Test]
    procedure ReleaseSalesOrderWithPreferredCarrierSucceeds()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        // [GIVEN] A customer with a preferred carrier and a sales order for that customer
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("DIR Preferred Carrier", CreateCarrier());
        Customer.Modify(true);
        CreateSalesDocument(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");

        // [WHEN] The sales order is released
        LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [THEN] The order is released
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        SalesHeader.TestField(Status, SalesHeader.Status::Released);
    end;

    [Test]
    procedure ReleaseSalesQuoteWithoutPreferredCarrierSucceeds()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        // [GIVEN] A customer without a preferred carrier and a sales quote for that customer
        LibrarySales.CreateCustomer(Customer);
        CreateSalesDocument(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");

        // [WHEN] The sales quote is released
        LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [THEN] The check only applies to sales orders, so the quote is released
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        SalesHeader.TestField(Status, SalesHeader.Status::Released);
    end;

    local procedure CreateSalesDocument(var SalesHeader: Record "Sales Header"; DocumentType: Enum "Sales Document Type"; CustomerNo: Code[20])
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
    begin
        LibraryInventory.CreateItem(Item);
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 1);
    end;

    local procedure CreateCarrier(): Code[20]
    var
        Carrier: Record "DIR Carrier";
    begin
        Carrier.Init();
        Carrier."Code" := LibraryUtility.GenerateRandomCode(Carrier.FieldNo("Code"), Database::"DIR Carrier");
        Carrier.Description := Carrier."Code";
        Carrier.Insert(true);
        exit(Carrier."Code");
    end;
}
