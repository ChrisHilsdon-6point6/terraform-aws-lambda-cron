from datetime import datetime

def lambda_handler(event, context):
    now = datetime.now()

    date_time = now.strftime("%m/%d/%Y, %H:%M:%S")
    print("Script running at:", date_time)