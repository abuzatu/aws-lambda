# Hello world to deploy a ML forecast to a lambda function in AWS

Assuming you have an AWS account (can be setup for free to test), 

# 1. Build the forecast ML model

For a hello world, assuming you have locally Python 3.9, you can build a quick linear regression using the `california_housing` dataset from sklearn, serialize it as a `.joblib` file. Run the Jupyter Notebook `notebooks/train_model.ipynb`. It will store the trained model in `models/your_trained_model.joblib`.

# 2. Create a Docker container that serves the prediction for the lambda function

It will use a handler function.

Build the image `docker build -t lambda-docker-caragea7-1 .`.

Create and start the docker container `docker run -p 9000:8080 --name lambda-docker-caragea7-1 lambda-docker-caragea7-1`. This will keep this terminal blocked.

In another terminal, run the ML forecast locally with
```
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"input_data":[8.3252, 41.0, 6.984127, 1.023810, 322.0, 2.555556, 37.88, -122.23]}'
```

You will get an output like `{"statusCode": 200, "body": {"prediction": 4.151943055154604}}`, which means the predicted value was `4.151943055154604`. We will check later we obtain the same prediction in the cloud. 

## How To make changes

Remove the container `docker rm lambda-docker-caragea7-1 && docker image rm lambda-docker-caragea7-1` and repeat the steps of build the image, create the container and run the prediction. Once you are happy, we can deploy it in the cloud.

# 3. Deploy the container to an Elastic Container Registery (ECR)

From the command line on your terminal, create an ECR instance, by running `aws ecr create-repository --repository-name lambda-docker-caragea7-1 --image-scanning-configuration scanOnPush=true`

This will create an output like this
```
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:eu-north-1:211125497258:repository/lambda-docker-caragea7-1",
        "registryId": "211125497258",
        "repositoryName": "lambda-docker-caragea7-1",
        "repositoryUri": "211125497258.dkr.ecr.eu-north-1.amazonaws.com/lambda-docker-caragea7-1",
        "createdAt": "2024-01-20T14:28:34.584000+02:00",
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": true
        },
        "encryptionConfiguration": {
            "encryptionType": "AES256"
        }
    }
}
```

From this we remember the URI `211125497258.dkr.ecr.eu-north-1.amazonaws.com` to use in the next steps.

From the [AWS console](https://eu-north-1.console.aws.amazon.com/ecr/private-registry/repositories?region=eu-north-1) it will appear indeed there with the name `lambda-docker-caragea7-1`.

Confirm you have the local image by running `docker image ls` that appears the image `lambda-docker-caragea7-1. `

Create a tag of the local image with its future name using the URI `docker tag lambda-docker-caragea7-1:latest 211125497258.dkr.ecr.eu-north-1.amazonaws.com/lambda-docker-caragea7-1:latest`.

Give permissions to access this image with `aws ecr get-login-password | docker login --username AWS --password-stdin 211125497258.dkr.ecr.eu-north-1.amazonaws.com/lambda-docker-caragea7-1`.

Push the image to the ECR with `docker push 211125497258.dkr.ecr.eu-north-1.amazonaws.com/lambda-docker-caragea7-1:latest`. 

Now the image exists in ECR and we can create a lambda function from this docker image.

# 4. Create a lambda function

From the AWS console search for `Lambda`, click `Create a function`, choose the third option `Container image`, click `Browser images`, click on `Select repository`, choose 
our image `lambda-docker-caragea7-1`, you will see a list of several versions, and you select the latest, and on bottom right click on `Select image`. This brings you back to the previous page where you select a name for the lambda function, like `caragea7_lambda_1` and on the bottom right you click on `Create function`. 

# 5. Test that the lambda functions forecasts correctly

Click on `Test`, and in the window with format `JSON` for the input replace the default with 
```
{
    "input_data" : [8.3252, 41.0, 6.984127, 1.023810, 322.0, 2.555556, 37.88, -122.23]
}
```
Then click on middle right on `Test`. In a few moments you will see a message in green `Execution function succeeded.` and you can click on `Details` or `Logs` to see them. The details shows the same result as when we ran locally, confirming all worked correctly. It is the return of the lambda function.
```
{
  "statusCode": 200,
  "body": {
    "prediction": 4.151943055154604
  }
}
```
The logs take us to another AWS service called `Cloud Watch`, that lists all the logging info we added throught our script, so in more detail.

# Conclusion

Now we can train a model locally and make it available for forecast in AWS via a lambda function. We could call this function from a REST API via `AWS API Gateway` for example.