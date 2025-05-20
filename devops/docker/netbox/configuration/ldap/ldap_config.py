
import ldap
from django_auth_ldap.config import LDAPSearch, NestedGroupOfNamesType, GroupOfNamesType

# Server URI
AUTH_LDAP_SERVER_URI = "ldaps://AD-DC-01.DOMAIN.COM"
AUTH_LDAP_CONNECTION_OPTIONS = {
    ldap.OPT_REFERRALS: 0
}
AUTH_LDAP_BASE_DN = 'DC=VM,DC=BE'
AUTH_LDAP_BIND_DN = "CN=netboxservice,OU=Users,OU=Netbox,OU=Applications,OU=VM,DC=DOMAIN,DC=COM"
AUTH_LDAP_BIND_PASSWORD = "SecretPassword"
LDAP_IGNORE_CERT_ERRORS = True

# Modify search to start at the base DN instead of ou=Users
#AUTH_LDAP_USER_SEARCH = LDAPSearch("dc=VM,dc=BE", ldap.SCOPE_SUBTREE, "(sAMAccountName=%(u>
AUTH_LDAP_USER_SEARCH = LDAPSearch(
    "dc=VM,dc=BE",
    ldap.SCOPE_SUBTREE,
    "(|(sAMAccountName=%(user)s)(mail=%(user)s))"
)


AUTH_LDAP_USER_ATTR_MAP = {
    "first_name": "givenName",
    "last_name": "sn",
    "email": "mail"
}

AUTH_LDAP_GROUP_SEARCH = LDAPSearch("dc=VM,dc=BE", ldap.SCOPE_SUBTREE,"(objectClass=group)")
AUTH_LDAP_GROUP_TYPE = GroupOfNamesType()
AUTH_LDAP_REQUIRE_GROUP = "CN=netbox_active,OU=Groups,OU=Netbox,OU=Applications,OU=DOMAIN,DC=COM>

#Mirror LDAP group
#AUTH_LDAP_MIRROR_GROUPS = True

#Define special user types using groups
AUTH_LDAP_USER_FLAGS_BY_GROUP = {
#       "is_active": "CN=netbox_active,OU=Groups,OU=Netbox,OU=Applications,OU=VM,DC=VM,DC=B>
        "is_staff": "CN=netbox_staff,OU=Groups,OU=Netbox,OU=Applications,OU=VM,DC=DOMAIN,DC=COM",
        "is_superuser": "CN=netbox_admin,OU=Groups,OU=Netbox,OU=Applications,OU=VM,DC=DOMAIN,COM>
}

AUTH_LDAP_FIND_GROUP_PERMS = True
AUTH_LDAP_CACHE_TIMEOUT = 3600
