public inherited sharing class SalesforceApi extends ffhttp_Client.AbstractClient {
    
    @TestVisible
    private static final String SUCCESS_MESSAGE = 'Synced Successfully';
    

    // CONSTRUCTOR

    public SalesforceApi() {
        setCredentials( new ffhttp_Client.NamedCredentials('Org1') );
    }


    // PUBLIC

    public List<Response> sendToOtherOrg(List<Contact> contacts) {
        return (List<Response>) new HttpClientRequest(this,
                                upsertEndpoint(),
                                ffhttp_Client.REQUEST_METHOD_POST, new Request(contacts),
                                new ffhttp_JsonDeserializer(List<Response>.class))
                                .param('_HttpMethod', 'PATCH')
                                .execute();
    }


    // PRIVATE

    private String upsertEndpoint() {
        return '/services/data/v49.0/composite/sobjects/Contact/ExternalId__c';
    }


    // INNER

    public class Response extends ffhttp_AbstractJsonSerializable {
        public Boolean success;
        public String id;
        public List<Error> errors;

        public Response(Boolean success, String id) {
            this.success = success;
            this.id = id;
        }
        
        public Response(List<Error> errors) {
            this.success = false;
            this.errors = errors;
        }
        
        public String message() {
            String result  = '';
            if(success) {
                result = SUCCESS_MESSAGE;
            }
            else {
                for(Error error : errors) {
                    result += error.statusCode + ': ' + error.message + '\n';
                }
            }

            return result;
        }
    }


    public class Error {
        public String statusCode;
        public String message;
        
        public Error(String statusCode, String message) {
            this.statusCode = statusCode;
            this.message = message;
        }
    }


    public class Request extends ffhttp_AbstractJsonSerializable {
        public Boolean allOrNone;
        public List<SObject> records;

        public Request(List<SObject> records) {
            this(false, records);
        }
        
        public Request(Boolean allOrNone, List<SObject> records) {
            this.allOrNone = allOrNone;
            this.records = records;
        }
    }


    private class HttpClientRequest extends ffhttp_Client.AbstractClientRequest {        
        
        // CONSTRUCTOR

        public HttpClientRequest(AbstractClient abstractClient, 
                                 String endpoint,
                                 String requestMethod, 
                                 ffhttp_IHttpContent httpContent, 
                                 ffhttp_IDeserialize responseDeserializer) {
            super(abstractClient, endpoint, requestMethod, httpContent, responseDeserializer);
        }
        

        // PRIVATE
        
        private HttpClientRequest param(String key, Object param) {
            super.addParam(key, param);

            return this;
        }
    }
}