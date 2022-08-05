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

if [ -z $CARDS_APP_NAME ]
then
  export CARDS_APP_NAME="cards"
fi

nodejs /render_503_page.js

# Generate /etc/apache2/sites-enabled/000-default.conf based on specified environment variables
/render_apache_httpd_config.sh > /etc/apache2/sites-enabled/000-default.conf

# Copy the appropriate logo
cp /var/www/html/proxyerror/logos/${CARDS_APP_NAME}.png /var/www/html/proxyerror/logo.png

apachectl -D FOREGROUND
