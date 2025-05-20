FROM python:3.10-buster
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    sshpass
RUN echo 'SSHD: ALL' >> /etc/hosts.allow

RUN echo "alias ansible-update='git push origin HEAD:main'" >> /etc/bash.bashrc
RUN echo "alias ansible-submodules='/workspaces/ansible/scripts/ansible-submodules.sh'" >> /etc/bash.bashrc
RUN echo "alias ansible-create-submodule='/workspaces/ansiblescripts/ansible-add-submodule.sh'" >> /etc/bash.bashrc
RUN echo "alias ansible-module='/workspaces/ansible/scripts/ansible-role.sh'" >> /etc/bash.bashrc
RUN echo "alias ansible-testing='/workspaces/ansible/scripts/testing.sh'" >> /etc/bash.bashrc
RUN echo "alias apply-vault='/workspaces/ansible/scripts/apply-vault.sh'" >> /etc/bash.bashrc
RUN echo "export ANSIBLE_CONFIG=/workspaces/ansible/ansible.cfg" >> /etc/bash.bashrc

# Copy the private key into the image
COPY ../ssh_private /workspaces/ansible/ssh_private
# Set permissions for the private key
RUN chmod 600 /workspaces/ansible/ssh_private
# Combine the commands to set up ssh-agent and add the key
RUN echo "eval \$(ssh-agent -s)" >> /etc/bash.bashrc && \
    echo "ssh-add /workspaces/ansible/ssh_private" >> /etc/bash.bashrc


# Docker specs to use with molecule
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    less \
    software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get clean && \    
    rm -rf /var/lib/apt/lists/*

# Kerberos requirements
RUN apt-get update && \ 
    apt-get install gcc -y \
    python3-dev \
    libkrb5-dev \
    gss-ntlmssp
RUN git config --global user.email "alain.seys@vanmarcke.be"
RUN git config --global user.name "Alain Seys"
COPY requirements.txt .
RUN pip install -r requirements.txt
# Change Back to correct workdir
WORKDIR /ansible


