FROM nikolaik/python-nodejs:python3.8-nodejs16-bullseye

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