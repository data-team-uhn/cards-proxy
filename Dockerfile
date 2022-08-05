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

FROM ubuntu:18.04

RUN apt-get update
RUN apt-get -y install \
	apache2 \
	nodejs \
	node-mustache

RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2enmod headers

COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY proxyerror /var/www/html/proxyerror
COPY render_503_page.js /render_503_page.js

COPY render_apache_httpd_config.sh /render_apache_httpd_config.sh
RUN chmod +x /render_apache_httpd_config.sh

COPY startup.sh /startup.sh
RUN chmod +x /startup.sh
CMD /startup.sh
