FROM jupyter/minimal-notebook

# Set user
USER $NB_USER

# Copy the requirements.txt file from pip to /opt/app
COPY requirements.txt /opt/app/requirements.txt

# Set working directory to /opt/app
WORKDIR /opt/app

# Switch to root access
USER root

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
