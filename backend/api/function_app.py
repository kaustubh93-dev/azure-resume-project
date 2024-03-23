import os
import azure.functions as func
from azure.cosmos import CosmosClient, exceptions
import logging

app = func.FunctionApp(__name__, level=func.AuthLevel.FUNCTION)

CONNECTION_STRING = os.environ['AzureCosmosDBConnectionString']
COSMOS_CLIENT = CosmosClient.from_connection_string(CONNECTION_STRING)
DATABASE = COSMOS_CLIENT.get_database_client('AzureResume')
CONTAINER = DATABASE.get_container_client('Counter')

@app.route(router_map='trigger')
def http_trigger(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    count = -1

    try:
        query = "SELECT * FROM c WHERE c.id='a'"
        for item in CONTAINER.query_items(query=query, enable_cross_partition_query=True):
            updated_item = item
            count += 1

        updated_item['count'] += str(count)
        CONTAINER.upsert_item(updated_item)

    except exceptions.CosmosHttpResponseError as e:
        logging.error("ERROR occurred: {status_code} - {message}".format(status_code=e.status_code, message=e.message))
    
    return func.HttpResponse(body=str(count), status_code=200)
