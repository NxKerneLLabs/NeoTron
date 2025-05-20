#!/bin/bash

API_KEY=$(terraform output -raw cognitive_service_key)
ENDPOINT=$(terraform output -raw cognitive_service_endpoint)

TEXT="I am thrilled to work on this project!"

curl -X POST "$ENDPOINT/text/analytics/v3.0/sentiment" \
  -H "Content-Type: application/json" \
  -H "Ocp-Apim-Subscription-Key: $API_KEY" \
  -d "{
    \"documents\": [
      {
        \"id\": \"1\",
        \"language\": \"en\",
        \"text\": \"$TEXT\"
      }
    ]
  }" | jq .

echo "Test completed. Check the sentiment analysis results above."

