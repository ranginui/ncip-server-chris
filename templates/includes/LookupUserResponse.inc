<UserId>
    <UserIdentifierValue>[% user.userdata.cardnumber | xml %]</UserIdentifierValue>
</UserId>

[%# <UserFiscalAccount></UserFiscalAccount>
LoanedItemsCount
LoanedItem
RequestedItemsCount
RequestedItem
-%]

<UserOptionalFields>
    [%- FOREACH element IN elements -%]
        [%- IF element.textContent == 'Name Information' -%]
            <NameInformation>
                <PersonalNameInformation>
                    <StructuredPersonalUserName>
                        <GivenName>[% user.userdata.firstname | xml %]</GivenName>
                        <Surname>[% user.userdata.surname | xml %]</Surname>
                    </StructuredPersonalUserName>
                </PersonalNameInformation>
            </NameInformation>
        [%- END -%]

        [%- IF element.textContent == 'User Address Information' -%]
            <UserAddressInformation>
                <UserAddressRoleType>Primary Address</UserAddressRoleType>
                <PhysicalAddress>
                    <StructuredAddress>
                        <Line1>[% user.userdata.streetnumber | xml %] [% user.userdata.address | xml %]</Line1>

                        [%- IF user.userdata.address2 -%]
                            <Line2>[% user.userdata.address2 | xml %]</Line2>
                        [%- END -%]

                        [%- IF user.userdata.city -%]
                            <Locality>[% user.userdata.city | xml %]</Locality>
                        [%- END -%]

                        [%- IF user.userdata.state -%]
                            <Region>[% user.userdata.state | xml %]</Region>
                        [%- END -%]

                        [%- IF user.userdata.zipcode -%]
                            <PostalCode>[% user.userdata.zipcode | xml %]</PostalCode>
                        [%- END -%]

                        [%- IF user.userdata.country -%]
                            <Country>[% user.userdata.country | xml %]</Country>
                        [%- END -%]
                    </StructuredAddress>
                    <PhysicalAddressType>Postal Address</PhysicalAddressType>
                </PhysicalAddress>
            </UserAddressInformation>

            [%- IF user.userdata.email -%]
                <UserAddressInformation>
                    <ElectronicAddress>
                        <ElectronicAddressType>mailto</ElectronicAddressType>
                        <ElectronicAddressData>[% user.userdata.email %]</ElectronicAddressData>
                    </ElectronicAddress>
                </UserAddressInformation>
            [%- END -%]

            [%- IF user.userdata.phone -%]
                <UserAddressInformation>
                    <ElectronicAddress>
                        <UserAddressRoleType>Home</UserAddressRoleType>
                        <ElectronicAddressType>tel</ElectronicAddressType>
                        <ElectronicAddressData>[% user.userdata.phone %]</ElectronicAddressData>
                    </ElectronicAddress>
                </UserAddressInformation>
            [%- END -%]

            [%- IF user.userdata.phonepro || user.userdata.mobile -%]
                <UserAddressInformation>
                    <ElectronicAddress>
                        <UserAddressRoleType>Mobile</UserAddressRoleType>
                        <ElectronicAddressType>tel</ElectronicAddressType>
                        <ElectronicAddressData>[% user.userdata.phonepro || user.userdata.mobile %]</ElectronicAddressData>
                    </ElectronicAddress>
                </UserAddressInformation>
            [%- END -%]
        [%- END -%]

        [%- IF element.textContent == 'User Privilege' -%]
            <UserPrivilege>
                <AgencyUserPrivilegeType>LIBRARY</AgencyUserPrivilegeType>
                <UserPrivilegeStatus>
                    <UserPrivilegeStatusType>[% user.userdata.branchcode %]</UserPrivilegeStatusType>
                </UserPrivilegeStatus>
            </UserPrivilege>

            <UserPrivilege>
                <AgencyUserPrivilegeType>PROFILE</AgencyUserPrivilegeType>
                <UserPrivilegeStatus>
                    <UserPrivilegeStatusType>[% user.userdata.categorycode %]</UserPrivilegeStatusType>
                </UserPrivilegeStatus>
            </UserPrivilege>

            <UserPrivilege>
                <AgencyUserPrivilegeType>STATUS</AgencyUserPrivilegeType>
                <UserPrivilegeStatus>
                    [%- FILTER collapse -%]
                        <UserPrivilegeStatusType>
                            [%- FILTER trim -%]
                                [%- IF user.userdata.restricted < 0 -%]
                                    Delinquent
                                [%- ELSIF user.userdata.restricted > 0 -%]
                                    Restricted
                                [%- ELSE -%]
                                    Ok
                                [%- END -%]
                            [%- END -%]
                        </UserPrivilegeStatusType>
                    [%- END -%]
                </UserPrivilegeStatus>
            </UserPrivilege>
        [%- END -%]
    [%- END -%]

    <UserId>
        <UserIdentifierType>Primary Key</UserIdentifierType>
        <UserIdentifierValue>[% user.userdata.borrowernumber %]</UserIdentifierValue>
    </UserId>
</UserOptionalFields>
