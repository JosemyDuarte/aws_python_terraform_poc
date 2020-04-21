

def handler(event, context):
    print("Starting request with event [{}] and context [{}]".format(event, context))
    save(event['content'], event['result_filename'])


def save(content: [bytes, bytearray], file_name):
    print("Saving content to [{}]...".format(file_name))
    print("Content received [{}]".format(content))
    with open(file_name, "wb+") as file:
        file.write(content)
