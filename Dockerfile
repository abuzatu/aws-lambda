# set a base image that includes Lambda Runtime API:
# Source: https://hub.docker.com/r/amazon/aws-lambda-python
FROM amazon/aws-lambda-python:3.9

# optional: ensure that pip is up to date
RUN /var/lang/bin/python3.9 -m pip install --upgrade pip

# Install necessary dependencies
# RUN pip install joblib numpy logging

# first we COPY only requirements.txt to ensure that later builds
# with changes to your sc code will be faster due to caching of this layer
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy your Python script and model files into the container
COPY src/your_regression_script.py .
COPY models/your_trained_model.joblib .

# specifiy the Lambda handler that will be invoked on container start
CMD ["your_regression_script.lambda_handler"]


