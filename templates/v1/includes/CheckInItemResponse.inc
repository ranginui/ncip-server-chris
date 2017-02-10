<ResponseHeader>
    <FromAgencyId>
        <UniqueAgencyId>
            <Scheme>texasgroup.worldcat.org/ncip/v1_0/ncip2/alpine</Scheme>
            <Value>[% from_agency | trim %]</Value>
        </UniqueAgencyId>
    </FromAgencyId>
    <ToAgencyId>
        <UniqueAgencyId>
            <Scheme>texasgroup.worldcat.org/ncip/v1_0/ncip2/alpine</Scheme>
            <Value>[% to_agency | trim %]</Value>
        </UniqueAgencyId>
    </ToAgencyId>
</ResponseHeader>
<UniqueItemId>
    <UniqueAgencyId>
        <Scheme>texasgroup.worldcat.org/ncip/v1_0/ncip2/alpine</Scheme>
        <Value>[% to_agency | trim %]</Value>
    </UniqueAgencyId>
    <ItemIdentifierValue>[% barcode | xml %]</ItemIdentifierValue>
</UniqueItemId>
