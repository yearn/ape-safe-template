FROM nikolaik/python-nodejs:python3.8-nodejs16-bullseye

# Install the security-fixed Node release without changing the Python toolchain.
ARG NODE_VERSION=22.23.5
RUN set -eux; \
    case "$(uname -m)" in \
      x86_64) node_arch=x64; node_sha=cdeb8670a0c81f51b4dc4ac61919f9b1ad917b304bf8221eb939570663d240f8 ;; \
      aarch64) node_arch=arm64; node_sha=2babb9eb5264860d540849f4b064a6fbdebcdc323657d9d382ce23d313fd5e09 ;; \
      *) echo "Unsupported architecture" >&2; exit 1 ;; \
    esac; \
    curl -fsSLo /tmp/node.tar.xz "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${node_arch}.tar.xz"; \
    echo "${node_sha}  /tmp/node.tar.xz" | sha256sum -c -; \
    tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 --no-same-owner; \
    rm /tmp/node.tar.xz; \
    test "$(node --version)" = "v${NODE_VERSION}"


RUN apt-get update \
    && apt-get install -y --no-install-recommends sudo \
    && echo pn ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/pn \
    && chmod 0440 /etc/sudoers.d/pn \
    && chown -R 1000:1000 /home/pn/

USER pn

COPY requirements.txt /requirements.txt
COPY download_compilers.py /download_compilers.py
COPY network-config.yaml /home/pn/network-config.yaml

ENV VIRTUAL_ENV=/home/pn/.local/pipx/venvs
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN sudo npm install -g ganache-cli@beta && \
pip install --force --no-cache-dir --upgrade pip setuptools && \
pip install --no-cache-dir pipx && \
python -m pipx ensurepath --force && \
/home/pn/.local/bin/pipx install eth-brownie==1.17 && \
python3 -m venv $VIRTUAL_ENV

RUN pip install --no-cache-dir -r requirements.txt && \
 brownie && rm ~/.brownie/deployments.db && \
 cp /home/pn/network-config.yaml ~/.brownie/ && \
 rm -rf ~/.local/lib && \
 rm -rf ~/.cache && \
 npm cache clean --force && \
 sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

ARG download_compilers
RUN echo $download_compilers
RUN if [ "$download_compilers" = "true" ]; then python download_compilers.py; else echo "skipping compiler download"; fi