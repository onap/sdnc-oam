FROM ${python.base.image}

LABEL maintainer="SDN-C Team (sdnc@lists.openecomp.org)"

COPY *.md *.pem /etc/ssl/certs/

RUN apk add --no-cache bash curl iputils openssh-client \
    && update-ca-certificates

RUN addgroup -S ansible && adduser -S ansible -G ansible
COPY --chown=ansible:ansible ansible-server /opt/ansible-server
COPY --chown=ansible:ansible Playbooks /opt/ansible-server/Playbooks
COPY configuration/ansible.cfg /etc/ansible/ansible.cfg

RUN pip install --no-cache-dir -r /opt/ansible-server/requirements.txt \
    && chmod +x /opt/ansible-server/*.py /opt/ansible-server/*.sh \
    && touch /var/log/ansible-server.log \
    && chown -R ansible:ansible /var/log

USER ansible:ansible
EXPOSE 8000
WORKDIR /opt/ansible-server
