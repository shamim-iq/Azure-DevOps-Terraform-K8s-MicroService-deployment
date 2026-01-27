# -------- Build Stage --------
FROM python:3.10-slim AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# -------- Runtime Stage --------
FROM python:3.10-slim

WORKDIR /app

# Copy only installed dependencies
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

COPY app.py .

EXPOSE 5000
CMD ["python", "app.py"]
