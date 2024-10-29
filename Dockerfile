FROM --platform=linux/amd64 alpine/helm:3.14.0
# Helm supported version along with K8 version: https://helm.sh/docs/topics/version_skew/

LABEL org.opencontainers.image.source https://github.com/apptweak/concourse-helm3-resource

# Versions for gcloud, kubectl, doctl, awscli
# K8 versions: https://kubernetes.io/releases/
ARG KUBERNETES_VERSION=1.30.2
ARG GCLOUD_VERSION=416.0.0
ARG DOCTL_VERSION=1.57.0
# https://pypi.org/project/awscli/
ARG AWSCLI_VERSION=1.31.10
ARG HELM_PLUGINS_TO_INSTALL="https://github.com/databus23/helm-diff"

#gcloud path
# ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

#install packages
RUN apk add --update --upgrade --no-cache \
        jq \
        bash \
        curl \
        git \
        gettext \
        libintl \
        python3 \
        py3-pip;

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

#install kubectl
RUN curl -sL -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubectl; \
    chmod +x /usr/local/bin/kubectl; \
#install awscli
    pip3 install --break-system-packages --no-cache-dir awscli==${AWSCLI_VERSION};

#install gcloud
# RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz \
#     -O /tmp/google-cloud-sdk.tar.gz | bash


# For use with gke-gcloud-auth-plugin below
# see https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
# for details
# ENV USE_GKE_GCLOUD_AUTH_PLUGIN=True

# RUN mkdir -p /usr/local/gcloud \
#     && tar -C /usr/local/gcloud -xvzf /tmp/google-cloud-sdk.tar.gz \
#     && /usr/local/gcloud/google-cloud-sdk/install.sh -q \
#     ## auth package is split out now, need explicit install
#     ## --quiet disables interactive prompts
#     && gcloud components install gke-gcloud-auth-plugin --quiet

#copy scripts
COPY assets /opt/resource

#install plugins
RUN for i in $(echo $HELM_PLUGINS_TO_INSTALL | xargs -n1); do helm plugin install "$i"; done

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
