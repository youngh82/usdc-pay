# --- Build stage ---
FROM python:3.11-slim AS builder
WORKDIR /app

# 1. 설정 파일 먼저 복사 (캐시 활용을 위해)
COPY pyproject.toml .

# 2. 소스 코드 전체 복사 
# (.dockerignore에 적은 파일들은 자동으로 제외됩니다)
COPY . .

# 3. 패키지 설치
RUN pip install --no-cache-dir .

# --- Runtime stage ---
FROM python:3.11-slim
WORKDIR /app

# 빌드 스테이지에서 설치된 패키지만 가져오기
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# 실제 실행에 필요한 파일들 복사
COPY . .

ENV SERVICE=api
CMD if [ "$SERVICE" = "api" ]; then \
      uvicorn api.main:app --host 0.0.0.0 --port 8000; \
    elif [ "$SERVICE" = "listener" ]; then \
      python -m listener.monitor; \
    elif [ "$SERVICE" = "worker" ]; then \
      python -m worker.webhook; \
    fi