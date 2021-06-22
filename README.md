# course-env
Docker and configuration files for the course environment.

## TMC-demo

Build (for example) with:
```
$ docker build -f ./py38-jupyter-alt.dockerfile -t alp-course-env .
```

Run (fox example) with:
```
$ docker run -p 8888:8888 alp-course-env
```

JupyterLab will hosted at http://localhost:8888/lab
