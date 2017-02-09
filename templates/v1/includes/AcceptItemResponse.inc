<ResponseHeader>
    <FromAgencyId>
        <UniqueAgencyId>
            <Scheme>texasgroup.worldcat.org/ncip/v1_0/ncip2/alpine</Scheme>
            <Value>[% from_agency %]</Value>
        </UniqueAgencyId>
    </FromAgencyId>

    <ToAgencyId>
        <UniqueAgencyId>
            <Scheme>texasgroup.worldcat.org/ncip/v1_0/ncip2/alpine</Scheme>
            <Value>[% to_agency %]</Value>
        </UniqueAgencyId>
    </ToAgencyId>

</ResponseHeader>

<UniqueRequestId>
        <UniqueAgencyId>
            <Scheme>texasgroup.worldcat.org/ncip/v1_0/ncip2/alpine</Scheme>
            <Value>TXAPL</Value>
        </UniqueAgencyId>
        <RequestIdentifierValue>[% newbarcode | xml%]</RequestIdentifierValue>
</UniqueRequestId>
