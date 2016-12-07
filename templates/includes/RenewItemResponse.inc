<ItemId>
    <AgencyId>[% from_agency | trim%]</AgencyId>
    <ItemIdentifierType>Barcode Id</ItemIdentifierType>
    <ItemIdentifierValue>[% barcode | xml %]</ItemIdentifierValue>
</ItemId>
<UserId>
    <AgencyId>[% to_agency | trim %]</AgencyId>
    <UserIdentifierType>Barcode Id</UserIdentifierType>
    <UserIdentifierValue>[% userid | xml %]</UserIdentifierValue>
</UserId>
<DateDue>[% data.datedue %]</DateDue>
