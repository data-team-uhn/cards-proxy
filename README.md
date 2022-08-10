# cards-proxy

An Apache HTTPd based Docker container to perform CARDS HTTP header
modification and routing in a Kubernetes environment

### Using in Kubernetes

1. Build a _self-contained_ `cards/cards:latest` Docker container image
and import this image into your Kubernetes environment.

2. Build this `cards/proxy` Docker container image with
`docker build -t cards/proxy .` and import that image into your
Kubernetes environment.

3. Deploy one of the _Kubernetes Deployment YAML_ files with
`kubectl create -f DEPLOYMENT_FILE.yml` replacing `DEPLOYMENT_FILE.yml`
with `cards_oak_filesystem_proxy.yml` if SAML _is not_ used or
`cards_oak_filesystem_proxy_saml.yml` if SAML _is_ used. The latter will
expect a SAML IdP (such as Keycloak) to be configured and available at
`http://localhost:8484/`. Additionally, a valid `samlKeystore.p12` will
need to be generated and copied into the running CARDS container under
`/opt/cards/`. To enable SAML authentication, the
`Utilities/Administration/SAML/add_saml_sp_config.py` script can be
used.

4. Access CARDS by using `kubectl port-forward` to access port 80 on the
pod.

### Using in Docker Compose

1. Build a _self-contained_ `cards/cards:latest` Docker container image.

2. Build this `cards/proxy` Docker container image with
`docker build -t cards/proxy .`.

3. Start a Docker Compose environment with
`docker-compose -f COMPOSE_FILE.yml up -d` replacing `COMPOSE_FILE.yml`
with `cards_oak_filesystem_proxy.yml` if SAML _is not_ used or
`cards_oak_filesystem_proxy_saml.yml` if SAML _is_ used. The latter will
start a `quay.io/keycloak/keycloak:15.0.2` container on port _8484_. To
use that _Keycloak_ container, it must be configured and then a
`samlKeystore.p12` file must be generated and copied into the running
CARDS container under `/opt/cards/`. To enable SAML authentication, the
`Utilities/Administration/SAML/add_saml_sp_config.py` script can be
used.

4. CARDS will be available at `http://localhost:8080`.
