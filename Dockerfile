FROM quay.io/jupyter/scipy-notebook:latest

RUN mkdir -p /home/jovyan/bd-a1/output/figures
WORKDIR /home/jovyan/bd-a1

COPY --chown=jovyan:users requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN python -m nltk.downloader -d /home/jovyan/nltk_data stopwords punkt punkt_tab wordnet

COPY --chown=jovyan:users data/ ./data/
COPY --chown=jovyan:users notebook/ ./notebook/
