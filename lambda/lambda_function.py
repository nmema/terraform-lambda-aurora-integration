import json
import psycopg2
import os


def lambda_handler(event, context):
    try:        
        conn = psycopg2.connect(
            host=os.environ['SERVER_HOST'],
            user=os.environ['SERVER_USER'],
            password=os.environ['SERVER_PASSWORD'],
            dbname=os.environ['SERVER_DATABASE'],
            port=5432,
        )

        cursor = conn.cursor()
        cursor.execute('select version();')
        result = cursor.fetchone()

        cursor.close()
        conn.close()

        return {
            'statusCode': 200,
            'body': json.dumps({'posgres_version': result[0]})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
