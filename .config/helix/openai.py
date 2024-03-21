#!/usr/bin/env python3

import json
import os
import sys
from urllib import request


ask = sys.stdin.read()  # Will contain the multiline question

model = "gpt-3.5-turbo"
data = {
    "model": model,
    "messages": [
        {
            "role": "system",
            "content": "You are an expert in programming and should provide only code.",
        },
        {
            "role": "user",
            "content": ask,
        },
    ],
}

OPENAI_API_KEY = os.environ["CHATGPT_API_KEY"]
headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {OPENAI_API_KEY}",
}
url = "https://api.openai.com/v1/chat/completions"
req = request.Request(url, method="POST")
req.add_header("Content-Type", "application/json")
req.add_header("Authorization", f"Bearer {OPENAI_API_KEY}")
data = json.dumps(data)
data = data.encode()

r = request.urlopen(req, data=data)
if r.getcode() != 200:
    print(r.getcode(), r.read())
else:
    response = json.loads(r.read())
    answer = response["choices"][0]["message"]["content"]
    print(ask, answer)
