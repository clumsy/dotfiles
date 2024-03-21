#!/usr/bin/env python3

import boto3
import json
import sys

ask = sys.stdin.read()  # Will contain the multiline question

modelId = 'anthropic.claude-v2'
accept = 'application/json'
contentType = 'application/json'
brt = boto3.client(service_name='bedrock-runtime')
body = json.dumps({
    "prompt": f"\n\nHuman: You are an expert in programming and your ONLY output is the valid code, \
                  can include comments but keep them short and escape accordingly. {ask}\n\nAssistant:",
    "max_tokens_to_sample": 300,
    "temperature": 0.1,
    "top_p": 0.9,
})

response = brt.invoke_model(body=body, modelId=modelId, accept=accept, contentType=contentType)
response_body = json.loads(response.get('body').read())
answer = response_body.get('completion')

print(ask, answer)
