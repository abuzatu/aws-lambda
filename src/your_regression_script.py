import joblib
import numpy as np
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Load the trained model
model = joblib.load("your_trained_model.joblib")


def lambda_handler(event, context):
    logger.info(f"Event={event}")
    # Assuming you receive input data in the 'input_data' field of the event
    input_data = np.array(event["input_data"]).reshape(1, -1)

    # Make predictions using the loaded model
    prediction = model.predict(input_data)[0]
    logger.info(f"prediction={prediction}")

    # Return the predictionå
    return {"statusCode": 200, "body": {"prediction": prediction}}
