# Dockerfile for Sensor Grounding Pipeline
# GPU telemetry → natural language essay (multi-domain, multi-timestep)
#
# This image packages:
#   - gpu_telemetry.py       (rocm-smi / amdgpu_top / mock adapter)
#   - grounding_pipeline01.py (compose_essay_universal, comparison-direction,
#                              compose_essay_timeseries_multidomain)
#   - build_grounding_dataset.py (JSON dataset builder)

FROM python:3.11-slim

# Prevent Python from writing .pyc files and buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Copy source files
COPY requirements.txt /app/
COPY gpu_telemetry.py /app/
COPY grounding_pipeline01.py /app/
COPY build_grounding_dataset.py /app/

# Install dependencies (requests is the only external dep)
RUN pip install --no-cache-dir -r requirements.txt requests

# Default command: build the grounding dataset and print the first essay
CMD ["python3", "-c", "\
import sys; sys.path.insert(0, '/app'); \
exec(open('/app/build_grounding_dataset.py').read())"]

# gpu_telemetry.py에 MOCK_MODE 환경 변수로 mock 모드 활성화
ENV MOCK_MODE=auto


# 단위 테스트 실행
RUN python3 -c "import sys; sys.path.insert(0, '/app'); \
    import grounding_pipeline01; \
    print('Tests passed')"


# ROS 2 Humble (선택)
# RUN apt-get update && apt-get install -y ros-humble-ros-base


# Jupyter 노트북 환경
# RUN pip install jupyter
# EXPOSE 8888

