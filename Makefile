PY ?= python3

.PHONY: help bootstrap install preflight ci test lint format clean run api migrate backup restore package release security loadtest monitor seed

help:
	@echo "MUDRA - Makefile Commands"
	@echo "========================="
	@echo "Setup & Installation:"
	@echo "  make install    - Install dependencies"
	@echo "  make bootstrap  - Full environment setup"
	@echo "  make seed       - Seed database with demo data"
	@echo ""
	@echo "Development:"
	@echo "  make run        - Start GUI application"
	@echo "  make api        - Start API server"
	@echo "  make test       - Run test suite"
	@echo "  make lint       - Run code linting"
	@echo "  make format     - Format code with black"
	@echo "  make clean      - Clean cache and temp files"
	@echo ""
	@echo "Quality & CI:"
	@echo "  make preflight  - Run preflight checks"
	@echo "  make ci         - Run CI checks"
	@echo "  make security   - Run security audit"
	@echo ""
	@echo "Database:"
	@echo "  make migrate    - Run database migrations"
	@echo "  make backup     - Backup database"
	@echo "  make restore    - Restore database (BACKUP=path)"
	@echo ""
	@echo "Deployment:"
	@echo "  make package    - Build desktop package"
	@echo "  make release    - Create release bundle (TAG=version)"
	@echo "  make loadtest   - Run API load tests"
	@echo "  make monitor    - Monitor system health"

install:
	$(PY) -m pip install --upgrade pip
	$(PY) -m pip install -r requirements.txt
	$(PY) -m pip install -r requirements-dev.txt

seed:
	$(PY) -m database.seed.seed_database

lint:
	ruff check .
	mypy --ignore-missing-imports mudra/ || true

format:
	black .
	ruff check --fix .

clean:
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	rm -rf .pytest_cache .mypy_cache .ruff_cache 2>/dev/null || true

bootstrap:
	bash scripts/bootstrap.sh

preflight:
	$(PY) scripts/preflight.py

ci:
	$(PY) scripts/ci_checks.py

test:
	$(PY) -m pytest tests/unit tests/integration -q

run:
	$(PY) mudra_app.py

api:
	$(PY) -m backend.run_api

migrate:
	$(PY) scripts/migrate.py

backup:
	$(PY) scripts/backup_db.py

restore:
	$(PY) scripts/restore_db.py --backup $(BACKUP)

package:
	bash scripts/package_desktop.sh

release:
	bash scripts/build_release_bundle.sh $(TAG)

security:
	$(PY) scripts/security_audit.py

loadtest:
	$(PY) scripts/load_test_api.py

monitor:
	$(PY) scripts/monitor_health.py --iterations 12
