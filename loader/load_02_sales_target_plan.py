import os
from google.oauth2 import service_account
from googleapiclient.discovery import build
from dotenv import load_dotenv
from io import BytesIO
from googleapiclient.http import MediaIoBaseDownload
import pandas as pd
from sqlalchemy import create_engine

load_dotenv()

SERVICE_ACCOUNT_FILE = os.getenv('GOOGLE_SERVICE_ACCOUNT_KEY')
FOLDER_DRIVE_ID = os.getenv('GOOGLE_DRIVE_FOLDER_ID')
SCOPES = ["https://www.googleapis.com/auth/drive.readonly"]

def get_service_account():

    credentials = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE,
        scopes = SCOPES
    )

    service = build(
        "drive",
        "v3",
        credentials = credentials
    )

    return service

def download_data(service, file_id):

    request = service.files().get_media(
        fileId = file_id,
        supportsAllDrives = True
    )

    buffer = BytesIO()

    downloader = MediaIoBaseDownload(
        buffer,
        request
    )

    done = False
    while not done:
        status, done = downloader.next_chunk()

    buffer.seek(0)
    return buffer

def read_data(file_name, buffer, sheet_name):
    if file_name.endswith(".csv"):
        data = pd.read_csv(buffer)
    elif file_name.endswith(".xlsx"):
        data = pd.read_excel(buffer, engine = "openpyxl", sheet_name = sheet_name)
    return data

service = get_service_account()
buffer = download_data(service, file_id = '1-BLii_-P0NQ4jlcG9ckbyfkZk54vo19s')
plan_v1 = read_data('SRC02_sales_target_plan.xlsx', buffer, sheet_name = 'Plan_v1_Original')
plan_v2 = read_data('SRC02_sales_target_plan.xlsx', buffer, sheet_name = 'Plan_v2_Adjustment_H2')

plan_v1['is_latest'] = [0]*len(plan_v1)
plan_v2['is_latest'] = [1]*len(plan_v2)

sales_target_plan = pd.concat([plan_v1, plan_v2], axis = 0)

user = os.getenv('PG_USER')
pwd = os.getenv('PG_PWD')
host = os.getenv('PG_HOST')
db_name = os.getenv('PG_DB_NAME')
port = os.getenv('PG_PORT')

connection_string = (
    f"postgresql+psycopg2://{user}:{pwd}@{host}:{port}/{db_name}"
)
engine = create_engine(connection_string)

sales_target_plan.to_sql(
    name = 'sales_target_plan',
    con = engine,
    schema = 'bronze',
    if_exists = 'append'
)

print("All done")
