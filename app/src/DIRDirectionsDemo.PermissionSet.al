permissionset 50100 "DIR Directions Demo"
{
    Caption = 'Directions Demo';
    Assignable = true;
    Permissions =
        tabledata "DIR Carrier" = RIMD,
        table "DIR Carrier" = X,
        page "DIR Carriers" = X,
        codeunit "DIR Customer CheckCarrier Meth" = X,
        codeunit "DIR Release Sales Doc Subs" = X;
}
