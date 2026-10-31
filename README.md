# CSCI461 Assignment 1 – Dockerized Data, Text Analysis and Machine Learning

Nile University | CSCI461 Introduction to Big Data | Fall 2026

A fully Dockerized analysis of the **IMDb Dataset of 50K Movie Reviews**: data cleaning, text analysis, a supervised sentiment classifier (TF-IDF + Naive Bayes / Logistic Regression) and K-Means clustering. Everything runs inside a custom JupyterLab image, and all results are saved to the host through a bind mount.

## Team

| Name | Student ID |
|------|------------|
| Omar Salama Isleem | 231000674 |
| Nadeem Diaa Shokry | 231000857 |

## Dataset

- **Name:** IMDb Dataset of 50K Movie Reviews (dataset option 6)
- **Source:** https://www.kaggle.com/datasets/lakshmi25npathi/imdb-dataset-of-50k-movie-reviews
- **Content:** 50,000 movie reviews, each labelled `positive` or `negative` (25,000 each). Columns: `review` (text), `sentiment` (label).
- **File location in the project:** `data/dataset.csv`

If `data/dataset.csv` is missing from your copy, download the CSV from the Kaggle link above and save it as `data/dataset.csv` before building the image.

## Project structure

```
bd-a1/
├── data
│   └── dataset.csv
├── Dockerfile
├── notebook
│   └── analysis.ipynb
├── output
│   ├── cleaned_data.csv
│   ├── cluster_summary.txt
│   ├── figures
│   │   ├── confusion_matrix.png
│   │   ├── correlation_heatmap.png
│   │   ├── group_comparison.png
│   │   ├── top20_no_stopwords.png
│   │   └── top20_with_stopwords.png
│   └── model_metrics.txt
├── README.md
├── requirements.txt
└── screenshots
    ├── 01_docker_build.png
    ├── 02_docker_images.png
    ├── 03_docker_ps.png
    ├── 04_docker_logs.png
    ├── 05_jupyterlab.png
    ├── 06_docker_hub.png
    ├── 07_pull_and_run.png
    └── 08_pull_and_run.png
```

## 1. Build the image

Run all commands from inside the `bd-a1/` folder (the one containing the `Dockerfile`).

```bash
docker build -t omarisleem/bd-a1:latest .
```

What the Dockerfile does:

1. Starts from `quay.io/jupyter/scipy-notebook:latest`.
2. Creates the folder `/home/jovyan/bd-a1/output/figures` and sets the working directory (`WORKDIR /home/jovyan/bd-a1`).
3. Installs the extra packages listed in `requirements.txt` (`nltk`, `wordcloud`).
4. Downloads the NLTK data (stopwords) into the image, so the notebook works without internet access at run time.
5. Copies `data/` and `notebook/` into the image.

## 2. Run the container (JupyterLab with a bind mount)

```bash
mkdir -p output/figures

docker run -d --name bd-a1 -p 8888:8888 \
  -v "$(pwd)/output:/home/jovyan/bd-a1/output" \
  omarisleem/bd-a1:latest
```

Then get the login URL (it contains a one-time token):

```bash
docker logs bd-a1
```

### Image vs. container

- An **image** is a read-only template. It holds the base system, the installed packages, and our files (built from the Dockerfile). It does nothing by itself, and one image can be used many times.
- A **container** is a running (or stopped) instance of an image. It adds a thin writable layer on top. Containers are disposable: when you remove one with `docker rm`, anything written only inside it is lost.

### Port mapping: `-p 8888:8888` means `HOST_PORT:CONTAINER_PORT`

JupyterLab listens on port 8888 **inside** the container. The container has its own network, so that port is not reachable from your machine by default. `-p 8888:8888` publishes it: traffic sent to port 8888 on the **host** is forwarded to port 8888 in the **container**. The left number is the host port and the right number is the container port. If the host port is already in use, change only the left number, e.g. `-p 8889:8888`, and open `http://localhost:8889`.

### Persistent output: bind mount

```
-v "$(pwd)/output:/home/jovyan/bd-a1/output"
```

This is a **bind mount**: the host folder `bd-a1/output/` and the container folder `/home/jovyan/bd-a1/output` are the same folder. Anything the notebook writes to `output/` (cleaned CSV, metrics, cluster summary, figures) appears on the host immediately and **survives** `docker stop` and `docker rm`.

Bind mount vs. volume: a bind mount maps a specific host folder you choose, so you can open the files directly. A Docker volume is storage created and managed by Docker itself (usually under `/var/lib/docker`), which is better for container-to-container data but less convenient for viewing results.

## 3. Container lifecycle evidence

```bash
docker images                 # custom image exists
docker ps                     # running containers
docker logs bd-a1             # JupyterLab startup log and token URL
```


Screenshots are stored in `screenshots/`:

| Evidence | File |
|----------|------|
| Successful `docker build` | `screenshots/01_docker_build.png` |
| `docker images` | `screenshots/02_docker_images.png` |
| `docker ps`| `screenshots/03_docker_ps.png` |
| `docker logs`| `screenshots/04_docker_logs.png` |
| JupyterLab with the notebook open | `screenshots/05_jupyterlab.png` |
| Docker Hub repository page | `screenshots/06_docker_hub.png` |
| Teammate pulling and running the image | `screenshots/07_pull_and_run.png`, `screenshots/08_pull_and_run.png`|

## 4. Docker Hub distribution

- **Repository:** `omarisleem/bd-a1`
- **Tag:** `latest`
- **Pull command:** `docker pull omarisleem/bd-a1:latest`

Publishing:

```bash
docker login
docker build -t omarisleem/bd-a1:latest .
docker push omarisleem/bd-a1:latest
```

Verification by another team member (on a different machine or after removing the local image with `docker rmi omarisleem/bd-a1:latest`):

```bash
docker pull omarisleem/bd-a1:latest
mkdir -p output/figures
docker run -d --name bd-a1 -p 8888:8888 \
  -v "$(pwd)/output:/home/jovyan/bd-a1/output" \
  omarisleem/bd-a1:latest
docker logs bd-a1
```

The image already contains the notebook and dataset, so the verifier only needs an empty `output/` folder to receive the results. The first pull can take several minutes because the base image is large.

## 5. Full reproduction from scratch

```bash
# 1. Get the project (unzip or git clone), then enter it
cd bd-a1


# 2. Build the image
docker build -t omarisleem/bd-a1:latest .

# 3. Run the container with the output bind mount
mkdir -p output/figures
docker run -d --name bd-a1 -p 8888:8888 \
  -v "$(pwd)/output:/home/jovyan/bd-a1/output" \
  omarisleem/bd-a1:latest

# 4. Open the URL printed by this command in a browser
docker logs bd-a1

# 5. In JupyterLab open notebook/analysis.ipynb and run Kernel -> Restart and Run All
# 6. Check the results on the host in output/
ls output output/figures
```

Expected files after a full run:

| File | Content |
|------|---------|
| `output/cleaned_data.csv` | Deduplicated reviews with `label`, `cleaned_text` and numeric text features |
| `output/model_metrics.txt` | Supervised model results, confusion matrices, top terms, interpretation, limitations |
| `output/cluster_summary.txt` | k selection, cluster sizes, silhouette score, top terms, comparison with labels, interpretation |
| `output/figures/correlation_heatmap.png` | Correlation of text features and label |
| `output/figures/top20_with_stopwords.png`, `top20_no_stopwords.png` | Word-frequency charts |
| `output/figures/group_comparison.png` | Positive vs. negative comparison |
| `output/figures/confusion_matrix.png` | Confusion matrices for both classifiers |

All random operations use `RANDOM_STATE = 42`, so a rerun on the same image gives the same results. The notebook uses relative paths (`../data/dataset.csv`, `../output`), so it must be opened from the `notebook/` folder (JupyterLab does this by default).

## Notebook overview

1. **Data analysis and preprocessing:** loading, dtypes/info/statistics, missing values and duplicates, `loc`/`iloc`/`np.r_`, transformations (label encoding, type conversion, feature creation), simple/stratified/cluster sampling, and correlation of text features.
2. **Text analysis:** cleaning into `cleaned_text`, tokenization, top-20 words with and without stop words, positive vs. negative comparison, and five written insights.
3. **Supervised classification:** stratified 80/20 split, TF-IDF (fit on the training set only), Multinomial Naive Bayes and Logistic Regression, accuracy/precision/recall/F1 and confusion matrices.
4. **K-Means clustering:** TF-IDF features, k chosen from k = 2 to 15 using silhouette, cluster sizes, top terms per cluster, and comparison with the sentiment labels.

## Results summary

| Model | Accuracy | Precision | Recall | F1 |
|-------|----------|-----------|--------|----|
| Multinomial Naive Bayes | 0.8603 | 0.8731 | 0.8445 | 0.8585 |
| Logistic Regression | 0.8968 | 0.8880 | 0.9092 | 0.8984 |

Precision, recall and F1 are for the positive class. Logistic Regression is the better model on every metric.

K-Means: k = 2 had the highest silhouette score (0.0020), but all scores were close to zero, so the reviews do not form well-separated clusters in TF-IDF space. The two clusters follow sentiment only partly (73.3% negative in cluster 0, 66.2% positive in cluster 1). See `output/cluster_summary.txt` for details.

## Repository

GitHub (bonus): https://github.com/omarisleem/bd-a1.git