FROM python:3.11-slim
WORKDIR /app
COPY pyproject.toml .

# Extract runtime dependencies from pyproject and install them first for better layer caching.
RUN python - <<'PY' > /tmp/requirements.txt
import tomllib

with open("pyproject.toml", "rb") as f:
  deps = tomllib.load(f)["project"]["dependencies"]

print("\n".join(deps))
PY
RUN pip install --no-cache-dir -r /tmp/requirements.txt

COPY . .
RUN pip install --no-cache-dir --no-deps .

ENV SERVICE=api
CMD if [ "$SERVICE" = "api" ]; then \
      uvicorn api.main:app --host 0.0.0.0 --port 8000; \
    elif [ "$SERVICE" = "listener" ]; then \
      python -m listener.monitor; \
    elif [ "$SERVICE" = "worker" ]; then \
      python -m worker.webhook; \
    fi