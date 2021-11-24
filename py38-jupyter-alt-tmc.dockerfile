FROM jupyter/minimal-notebook

# Set user
USER $NB_USER

# Set environments for TMC
ENV TMC_DIR=/opt/tmc/
ENV TMC_CONFIG_DIR="${HOME}/tmc-config/tmc-tmc_cli_rust"

# Copy the requirements.txt file from pip to /opt/app
COPY requirements.txt /opt/app/requirements.txt

# Set working directory to /opt/app
WORKDIR /opt/app

# Switch to root
USER root

# Upgrade pip and setuptools; install libraries from requirements.txt
RUN apt update \
	&& apt install python-pkg-resources \
	&& apt install g++ -y \
	&& pip install --upgrade pip setuptools wheel \
	&& pip install -r requirements.txt \ 
	&& chgrp -R root /home/$NB_USER \
	&& find /home/$NB_USER -type d -exec chmod g+rwx,o+rx {} \; \
	&& find /home/$NB_USER -type f -exec chmod g+rw {} \; \
	&& chgrp -R root /opt/conda \
	&& find /opt/conda -type d -exec chmod g+rwx,o+rx {} \; \
	&& find /opt/conda -type f -exec chmod g+rw {} \; \
	&& apt-get install -y --no-install-recommends curl \
    	&& curl -0 https://raw.githubusercontent.com/rage/tmc-cli-rust/main/scripts/install.sh | bash -s x86_64 linux \
    	# Set download location for exercises
    	&& mkdir -p "${TMC_DIR}" \
    	&& mkdir -p "${TMC_CONFIG_DIR}" \
    	&& echo "projects-dir = '${WORK_DIR}'" > "${TMC_CONFIG_DIR}/config.toml" \
    	&& fix-permissions "${HOME}" \
    	&& fix-permissions "${TMC_DIR}" \
    	&& apt-get purge -y --auto-remove curl \
    	&& apt-get clean

# Set home
ENV HOME /home/$NB_USER

# Copy start script for Jupyter
COPY scripts/jupyter/autodownload_and_start.sh /usr/local/bin/autodownload_and_start.sh

# Set starting directory for Jupyter
RUN mkdir -p /home/jovyan/work \
    && sed -i "s/#c.NotebookApp.notebook_dir =.*/c.NotebookApp.notebook_dir = '\/home\/jovyan\/work\/'/g" /home/jovyan/.jupyter/jupyter_notebook_config.py \
    && chmod a+x /usr/local/bin/autodownload_and_start.sh

# Change to non-root user
USER 1000

# Go back to student starting folder (e.g. the folder where you would also mount Rahti's persistant folder)
WORKDIR /home/$NB_USER/work

# Run start script
CMD ["/usr/local/bin/autodownload_and_start.sh"]
