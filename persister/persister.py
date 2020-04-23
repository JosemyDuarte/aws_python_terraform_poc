import os
import tempfile
from datetime import datetime

import boto3


def handler(event, context):
    print("Starting request with event [{}] and context [{}]".format(event, context))
    save(event['content'], event['result_filename'])


def save(content: [bytes, bytearray], file_name):
    print("Saving content to [{}]...".format(file_name))
    print("Content received [{}]".format(content))
    tmp = tempfile.NamedTemporaryFile()
    with open(tmp.name, 'w') as f:
        f.write(content)
    s3 = boto3.resource('s3')
    s3.Bucket(os.environ['bucket_name']).upload_file(tmp.name,
                                                     "{}/{}".format(datetime.today().strftime('%Y-%m-%d'), file_name))
