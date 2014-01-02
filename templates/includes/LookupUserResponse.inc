<UserOptionalFields>
[% FOREACH element IN elements %]
  [% IF element.textContent == 'User Address Information' %]
    
  [% END %]
  [% IF element.textContent == 'Name Information' %]
    <NameInformation>
      <PersonalNameInformation>
        <StructuredPersonalUserName>
          <GivenName>[% user.userdata.firstname %]</GivenName>
          <Surname>[% user.userdata.surname %]</Surname>
        </StructuredPersonalUserName>
      </PersonalNameInformation>
    </NameInformation>
  [% END %]
[% END %]
</UserOptionalFields/>
