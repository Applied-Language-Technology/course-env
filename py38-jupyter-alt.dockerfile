FROM jupyter/minimal-notebook

ENV TMC_DIR=/opt/tmc/
ENV TMC_CONFIG_DIR="${HOME}/tmc-config/tmc-tmc_cli_rust"
ENV WORK_DIR="${HOME}/work/"

USER root

# Set working directory to /opt/app
WORKDIR /opt/app

# Copy the requirements.txt file from pip to /opt/app
COPY requirements.txt /opt/app/requirements.txt

# Upgrade pip and setuptools; install libraries from requirements.txt;
# change permissions.
RUN pip install --upgrade pip \
	&& pip install --upgrade setuptools \
	&& pip install wheel \
	&& pip install -r requirements.txt \
	&& apt update \
	&& apt install python-pkg-resources \
    && chgrp -R root /home/$NB_USER \
	&& find /home/$NB_USER -type d -exec chmod g+rwx,o+rx {} \; \
	&& find /home/$NB_USER -type f -exec chmod g+rw {} \; \
	&& chgrp -R root /opt/conda \
	&& find /opt/conda -type d -exec chmod g+rwx,o+rx {} \; \
	&& find /opt/conda -type f -exec chmod g+rw {} \;

# Copy start script for Jupyter
COPY scripts/jupyter/autodownload_and_start.sh /usr/local/bin/autodownload_and_start.sh

# Install TMC-CLI to TMC_DIR and set starting directory for Jupyter
WORKDIR "${TMC_DIR}"

RUN apt-get install -y --no-install-recommends curl \
    && curl -0 https://raw.githubusercontent.com/rage/tmc-cli-rust/main/scripts/install.sh | bash -s x86_64 linux \
    # Set download location for exercises
    && mkdir -p "${TMC_CONFIG_DIR}" \
    && echo "projects-dir = '${WORK_DIR}'" > "${TMC_CONFIG_DIR}/config.toml" \
    && fix-permissions "${HOME}" \
    && fix-permissions "${TMC_DIR}" \
    && apt-get purge -y --auto-remove curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && sed -i "s/#c.NotebookApp.notebook_dir =.*/c.NotebookApp.notebook_dir = '\/home\/jovyan\/work\/'/g" /home/jovyan/.jupyter/jupyter_notebook_config.py \
    && fix-permissions /usr/local/bin/autodownload_and_start.sh

USER ${NB_UID}

WORKDIR "${WORK_DIR}"

# Run start script
CMD ["/usr/local/bin/autodownload_and_start.sh"]
