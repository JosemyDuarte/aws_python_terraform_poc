import requests


def handler(event, context):
    print("Starting request with event [{}] and context [{}]".format(event, context))
    return download(event['web_page_url'])


def download(path: str) -> [bytes, bytearray]:
    print("Downloading page from [{}] ...".format(path))
    return requests.get(path).content
