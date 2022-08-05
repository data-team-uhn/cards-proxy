#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

CARDS_USES_HTTPS=false

cat << EOF
<VirtualHost *:80>
	Header unset WWW-Authenticate
EOF

if [ ! -z $HSTS_HEADER ]
then
	CARDS_USES_HTTPS=true
	cat << EOF
	Header always set Strict-Transport-Security "$HSTS_HEADER"
EOF
fi

if [[ $HTTPS_REDIRECT_REWRITE = true ]]
then
	CARDS_USES_HTTPS=true
	cat << EOF
	Header edit location ^http://(.*)$ https://\$1
EOF
fi

if [[ $SET_SECURE_COOKIES = true ]]
then
	CARDS_USES_HTTPS=true
	cat << EOF
	Header edit Set-Cookie ^(.*)$ \$1;Secure
EOF
fi

cat << EOF
	ProxyPreserveHost On

	DocumentRoot "/var/www/html"
EOF

if [[ $SAML != true ]]
then
	cat << EOF
	ProxyPass /proxyerror/ !
EOF
fi

cat << EOF
	ErrorDocument 503 /proxyerror/503.html

EOF

if [[ $SAML = true ]]
then
	cat << EOF
	<Location "/">
EOF

	if [[ $CARDS_USES_HTTPS = true ]]
	then
		cat << EOF
		Header edit Location \${SAML_IDP_DESTINATION}.* https://\${CARDS_HOST_AND_PORT}/login "expr=(%{REQUEST_STATUS} == 302) && (%{REQUEST_URI} != '/fetch_requires_saml_login.html') && (%{REQUEST_URI} != '/goto_saml_login')"
EOF
	else
		cat << EOF
		Header edit Location \${SAML_IDP_DESTINATION}.* http://\${CARDS_HOST_AND_PORT}/login "expr=(%{REQUEST_STATUS} == 302) && (%{REQUEST_URI} != '/fetch_requires_saml_login.html') && (%{REQUEST_URI} != '/goto_saml_login')"
EOF
	fi

	cat << EOF
		Header set Cache-Control no-store "expr=(%{REQUEST_URI} == '/fetch_requires_saml_login.html') || (%{REQUEST_URI} == '/goto_saml_login')"
EOF

	cat << EOF
		ProxyPass http://localhost:8080/
		ProxyPassReverse http://localhost:8080/
	</Location>

	<Location "/proxyerror">
		ProxyPass !
	</Location>

	<Location "/goto_saml_login">
		ProxyPass http://localhost:8080/
		ProxyPassReverse http://localhost:8080/
	</Location>

EOF

	if [ ! -z $NCR ]
	then
		cat << EOF
	<Location "/ncr/">
		ProxyPass $NCR
		ProxyPassReverse $NCR
	</Location>

EOF
	fi

	cat << EOF
	<Location "/system/sling/logout">
		Header set Set-Cookie "sling.formauth=; Path=/; Expires=Thu, 01-Jan-1970 00:00:00 GMT; Max-Age=0; HttpOnly" "expr=%{REQUEST_STATUS} == 302"
	</Location>

	<Location "/system/console/logout">
		Header set Set-Cookie "sling.formauth=; Path=/; Expires=Thu, 01-Jan-1970 00:00:00 GMT; Max-Age=0; HttpOnly" "expr=%{REQUEST_STATUS} == 302"
	</Location>
EOF
else
	if [ ! -z $NCR ]
	then
		cat << EOF
	ProxyPass /ncr/ $NCR
	ProxyPassReverse /ncr/ $NCR

EOF
	fi

	cat << EOF
	ProxyPass / http://localhost:8080/
	ProxyPassReverse / http://localhost:8080/
EOF
fi

cat << EOF

</VirtualHost>
EOF
