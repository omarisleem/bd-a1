FROM quay.io/jupyter/scipy-notebook:latest

RUN mkdir -p /home/jovyan/bd-a1/output/figures
WORKDIR /home/jovyan/bd-a1

COPY --chown=jovyan:users requirements.txt .
RUN pip install -r requirements.txt

COPY --chown=jovyan:users data/ ./data/
COPY --chown=jovyan:users notebook/ ./notebook/
