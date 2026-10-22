codeunit 80104 "DIR Preferred Carrier Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryUtility: Codeunit "Library - Utility";
        NoPreferredCarrierErr: Label 'You cannot release sales order %1 because customer %2 has no preferred carrier.', Comment = '%1 = sales order No.; %2 = Sell-to Customer No.';
        PreferredCarrierBlockedErr: Label 'You cannot release sales order %1 because preferred carrier %2 of customer %3 is blocked.', Comment = '%1 = sales order No.; %2 = carrier Code; %3 = Sell-to Customer No.';
        NotInRelatedTableTxt: Label 'cannot be found in the related table', Locked = true;
        StatusMustBeOpenTxt: Label 'The sales document must stay Open.', Locked = true;
        StatusMustBeReleasedTxt: Label 'The sales document must be Released.', Locked = true;

    [Test]
    procedure PreferredCarrierMustExist()
    var
        Customer: Record Customer;
    begin
        // [SCENARIO AC1] A non-existing carrier code is refused and not stored
        // [GIVEN] A customer
        LibrarySales.CreateCustomer(Customer);

        // [WHEN] Validate "DIR Preferred Carrier" with a code that does not exist in "DIR Carrier"
        asserterror Customer.Validate("DIR Preferred Carrier", 'NO-SUCH-CARRIER');

        // [THEN] An error is raised and the field is empty
        Assert.ExpectedError(NotInRelatedTableTxt);
        Customer.Get(Customer."No.");
        Assert.AreEqual('', Customer."DIR Preferred Carrier", 'The preferred carrier must not be stored.');
    end;

    [Test]
    procedure CustomerCardShowsPreferredCarrier()
    var
        Customer: Record Customer;
        Carrier: Record "DIR Carrier";
        CustomerCard: TestPage "Customer Card";
    begin
        // [SCENARIO AC2] The Preferred Carrier field on the Customer Card stores the carrier
        // [GIVEN] A carrier and the Customer Card open on a customer
        LibrarySales.CreateCustomer(Customer);
        CreateCarrier(Carrier, '', false);
        CustomerCard.OpenEdit();
        CustomerCard.GoToRecord(Customer);

        // [WHEN] The Preferred Carrier field is set
        CustomerCard."DIR Preferred Carrier".SetValue(Carrier.Code);
        CustomerCard.Close();

        // [THEN] The customer record holds the carrier
        Customer.Get(Customer."No.");
        Assert.AreEqual(Carrier.Code, Customer."DIR Preferred Carrier", 'The customer must hold the carrier.');
    end;

    [Test]
    procedure ReleaseOrderWithoutPreferredCarrierFails()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO AC3] A sales order for a customer without preferred carrier cannot be released
        // [GIVEN] An open sales order for a customer without preferred carrier
        LibrarySales.CreateCustomer(Customer);
        CreateOrderWithLine(SalesHeader, Customer."No.");

        // [WHEN] The order is released
        asserterror ReleaseOrder(SalesHeader);

        // [THEN] NoPreferredCarrierErr is raised and the order stays Open
        Assert.ExpectedError(StrSubstNo(NoPreferredCarrierErr, SalesHeader."No.", Customer."No."));
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        Assert.AreEqual(SalesHeader.Status::Open, SalesHeader.Status, StatusMustBeOpenTxt);
    end;

    [Test]
    procedure ReleaseOrderWithBlockedCarrierFails()
    var
        Customer: Record Customer;
        Carrier: Record "DIR Carrier";
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO AC4] A sales order for a customer with a blocked preferred carrier cannot be released
        // [GIVEN] An open sales order for a customer whose preferred carrier is blocked
        CreateCustomerWithCarrier(Customer, Carrier, true);
        CreateOrderWithLine(SalesHeader, Customer."No.");

        // [WHEN] The order is released
        asserterror ReleaseOrder(SalesHeader);

        // [THEN] PreferredCarrierBlockedErr is raised and the order stays Open
        Assert.ExpectedError(StrSubstNo(PreferredCarrierBlockedErr, SalesHeader."No.", Carrier.Code, Customer."No."));
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        Assert.AreEqual(SalesHeader.Status::Open, SalesHeader.Status, StatusMustBeOpenTxt);
    end;

    [Test]
    procedure ReleaseOrderWithPreferredCarrierSucceeds()
    var
        Customer: Record Customer;
        Carrier: Record "DIR Carrier";
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO AC5] A sales order for a customer with a usable preferred carrier is released
        // [GIVEN] An open sales order for a customer whose preferred carrier is not blocked
        CreateCustomerWithCarrier(Customer, Carrier, false);
        CreateOrderWithLine(SalesHeader, Customer."No.");

        // [WHEN] The order is released
        ReleaseOrder(SalesHeader);

        // [THEN] The Status is Released
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        Assert.AreEqual(SalesHeader.Status::Released, SalesHeader.Status, StatusMustBeReleasedTxt);
    end;

    [Test]
    procedure ReleaseOrderChecksSellToCustomerOnly()
    var
        SellToCustomer: Record Customer;
        BillToCustomer: Record Customer;
        Carrier: Record "DIR Carrier";
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO AC6] Only the sell-to customer is checked, the bill-to customer is ignored
        // [GIVEN] An open sales order: the sell-to customer has a carrier, the bill-to customer has none
        CreateCustomerWithCarrier(SellToCustomer, Carrier, false);
        LibrarySales.CreateCustomer(BillToCustomer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, SellToCustomer."No.");
        SalesHeader.Validate("Bill-to Customer No.", BillToCustomer."No.");
        SalesHeader.Modify(true);
        AddItemLine(SalesHeader);

        // [WHEN] The order is released
        ReleaseOrder(SalesHeader);

        // [THEN] The Status is Released
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        Assert.AreEqual(SalesHeader.Status::Released, SalesHeader.Status, StatusMustBeReleasedTxt);
    end;

    [Test]
    procedure ReleaseInvoiceWithoutPreferredCarrierSucceeds()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO AC7] Other sales documents than orders are not checked
        // [GIVEN] An open sales invoice for a customer without preferred carrier
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        AddItemLine(SalesHeader);

        // [WHEN] The invoice is released
        ReleaseOrder(SalesHeader);

        // [THEN] The Status is Released
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        Assert.AreEqual(SalesHeader.Status::Released, SalesHeader.Status, StatusMustBeReleasedTxt);
    end;

    [Test]
    procedure PreferredCarrierFillsShippingAgentCode()
    var
        Customer: Record Customer;
        Carrier: Record "DIR Carrier";
        ShippingAgent: Record "Shipping Agent";
    begin
        // [SCENARIO AC8] Validating the carrier fills the customer's Shipping Agent Code
        // [GIVEN] A carrier with a Shipping Agent Code
        LibrarySales.CreateCustomer(Customer);
        CreateShippingAgent(ShippingAgent);
        CreateCarrier(Carrier, ShippingAgent.Code, false);

        // [WHEN] It is validated as the customer's "DIR Preferred Carrier"
        Customer.Validate("DIR Preferred Carrier", Carrier.Code);

        // [THEN] The customer's Shipping Agent Code equals the carrier's
        Assert.AreEqual(ShippingAgent.Code, Customer."Shipping Agent Code", 'The Shipping Agent Code must be copied.');
    end;

    [Test]
    procedure EmptyCarrierShippingAgentKeepsCustomerValue()
    var
        Customer: Record Customer;
        Carrier: Record "DIR Carrier";
        ShippingAgent: Record "Shipping Agent";
    begin
        // [SCENARIO AC9] A carrier without Shipping Agent Code does not wipe the customer's value
        // [GIVEN] A customer with a Shipping Agent Code and a carrier without one
        LibrarySales.CreateCustomer(Customer);
        CreateShippingAgent(ShippingAgent);
        Customer.Validate("Shipping Agent Code", ShippingAgent.Code);
        CreateCarrier(Carrier, '', false);

        // [WHEN] The carrier is validated as the customer's "DIR Preferred Carrier"
        Customer.Validate("DIR Preferred Carrier", Carrier.Code);

        // [THEN] The customer's Shipping Agent Code is unchanged
        Assert.AreEqual(ShippingAgent.Code, Customer."Shipping Agent Code", 'The Shipping Agent Code must be unchanged.');
    end;

    local procedure CreateShippingAgent(var ShippingAgent: Record "Shipping Agent")
    begin
        ShippingAgent.Init();
        ShippingAgent.Code := LibraryUtility.GenerateRandomCode(ShippingAgent.FieldNo(Code), Database::"Shipping Agent");
        ShippingAgent.Insert();
    end;

    local procedure CreateCarrier(var Carrier: Record "DIR Carrier"; ShippingAgentCode: Code[10]; IsBlocked: Boolean)
    begin
        Carrier.Init();
        Carrier.Code := LibraryUtility.GenerateRandomCode(Carrier.FieldNo(Code), Database::"DIR Carrier");
        Carrier."Shipping Agent Code" := ShippingAgentCode;
        Carrier.Blocked := IsBlocked;
        Carrier.Insert();
    end;

    local procedure CreateCustomerWithCarrier(var Customer: Record Customer; var Carrier: Record "DIR Carrier"; IsBlocked: Boolean)
    begin
        LibrarySales.CreateCustomer(Customer);
        CreateCarrier(Carrier, '', IsBlocked);
        Customer.Validate("DIR Preferred Carrier", Carrier.Code);
        Customer.Modify(true);
    end;

    local procedure CreateOrderWithLine(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20])
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CustomerNo);
        AddItemLine(SalesHeader);
    end;

    local procedure AddItemLine(SalesHeader: Record "Sales Header")
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
    begin
        // The release codeunit refuses a document without lines
        LibraryInventory.CreateItem(Item);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 1);
    end;

    local procedure ReleaseOrder(var SalesHeader: Record "Sales Header")
    var
        ReleaseSalesDocument: Codeunit "Release Sales Document";
    begin
        ReleaseSalesDocument.PerformManualRelease(SalesHeader);
    end;
}
