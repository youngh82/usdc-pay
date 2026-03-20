.PHONY: dev test lint type-check fmt build clean help

dev:
	docker compose up -d
	uvicorn api.main:app --reload --port 8000

test:
	pytest tests/ -v --tb=short

lint:
	ruff check .

type-check:
	mypy api/ listener/ worker/

fmt:
	black .
	ruff check --fix .

build:
	docker compose build

clean:
	docker compose down -v
	find . -type d -name __pycache__ -exec rm -rf {} +

help:
	@echo "dev        - 로컬 서버 실행"
	@echo "test       - 테스트 실행"
	@echo "lint       - 린트 검사"
	@echo "type-check - 타입 검사"
	@echo "fmt        - 코드 포맷팅"
	@echo "build      - 도커 이미지 빌드"
	@echo "clean      - 컨테이너 + 캐시 정리"