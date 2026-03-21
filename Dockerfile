# --- Build stage ---
FROM python:3.11-slim AS builder
WORKDIR /app

# 1. 설정 파일 복사
COPY pyproject.toml .

# 2. [핵심] 모든 소스 코드를 먼저 복사해줍니다.
COPY . .

# 3. 그 다음 설치 (이제 api, db 폴더를 찾을 수 있습니다)
RUN pip install --no-cache-dir .

# --- Runtime stage ---
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY . .

ENV SERVICE=api
CMD if [ "$SERVICE" = "api" ]; then \
      uvicorn api.main:app --host 0.0.0.0 --port 8000; \
    elif [ "$SERVICE" = "listener" ]; then \
      python -m listener.monitor; \
    elif [ "$SERVICE" = "worker" ]; then \
      python -m worker.webhook; \
    fi