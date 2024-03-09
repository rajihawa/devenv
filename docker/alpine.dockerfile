# ----- SSH Image ----- #
FROM alpine:3.19 as ssh

# Create entry file
RUN mkdir -p /root/.ssh
COPY ssh.sh /root/entry.sh
RUN chmod +x /root/entry.sh

# Utils
RUN apk update
RUN apk add git openssh-client

# Solve issue with windows to linux sharing, should run `git config --global core.autocrlf true` on windows too
RUN git config --global core.autocrlf input

# Set the script as the entrypoint
ENTRYPOINT ["/root/entry.sh"]
# ----- SSH Image End ----- #

# ----- Git Cloner ----- #
FROM ssh AS cloner
 
# Docker
RUN apk add --update docker openrc
RUN rc-update add docker boot

# ENV REPO
# ENV DIR
CMD git clone $REPO $DIR
# ----- Git Cloner End ----- #

# ----- VSCode Image ----- #
FROM ssh AS vscode

RUN apk update
RUN apk add gcc musl-dev wget gzip unzip

# VS Code Commit
ARG COMMIT="019f4d1419fbc8219a181fab7892ebccf7ee29a2"
# VS Code CLI
RUN apk add curl tar
RUN curl -L https://vscode.download.prss.microsoft.com/dbazure/download/stable/${COMMIT}/vscode_cli_alpine_x64_cli.tar.gz | tar -xz -C /usr/local/bin
# VS Code Web
RUN mkdir -p /root/.vscode/cli/serve-web/${COMMIT} \
    && cd /root/.vscode/cli/serve-web/${COMMIT} \
    && curl -L https://vscode.download.prss.microsoft.com/dbazure/download/stable/${COMMIT}/vscode-server-linux-alpine-web.tar.gz --output ./vscode-server-linux-alpine-web.tar.gz \
    && tar xvf vscode-server-linux-alpine-web.tar.gz \
    && rm -rf vscode-server-linux-alpine-web.tar.gz \
    && cd vscode-server-linux-alpine-web \
    && find . -maxdepth 1 -exec mv {} .. \; \
    && cd .. && rm -rf vscode-server-linux-alpine-web

# VS Code extensions (install with `code-server --install-extension rust-lang.rust-analyzer`)
ENV PATH="/root/.vscode/cli/serve-web/${COMMIT}/bin:${PATH}"

ENV PORT 8000
ENV HOST 0.0.0.0

WORKDIR /app

# run code server
CMD code -a /app serve-web --without-connection-token --accept-server-license-terms --host $HOST --port $PORT
# ----- VSCode Image End ----- #
