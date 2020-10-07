@IsTest
private class SyncWithOtherOrg_Test {
    
    @IsTest 
    private static void executeWithCalloutError() {

        // Setup
        new HttpMock()
            .post('/services/data/v49.0/composite/sobjects/Contact/ExternalId__c', new CalloutException())
            .mock();


        // Exercise
        Test.startTest();
            new Contact_t().persist();
        Test.stopTest();


        // Verify
        Contact contact = [Select SyncMessage__c From Contact];
        System.assertEquals(Label.CalloutError, contact.SyncMessage__c);
    }
    
    
    @IsTest 
    private static void executeWithSyncError() {

        // Setup
        new HttpMock()
            .post('/services/data/v49.0/composite/sobjects/Contact/ExternalId__c', error())
            .mock();


        // Exercise
        Test.startTest();
            new Contact_t().persist();
        Test.stopTest();


        // Verify
        Contact contact = [Select SyncMessage__c From Contact];
        System.assertEquals('Code: message', contact.SyncMessage__c);
    }
    
    
    @IsTest 
    private static void executeWithSuccess() {

        // Setup
        new HttpMock()
            .post('/services/data/v49.0/composite/sobjects/Contact/ExternalId__c', success())
            .mock();


        // Exercise
        Test.startTest();
            new Contact_t().persist();
        Test.stopTest();


        // Verify
        Contact contact = [Select SyncMessage__c From Contact];
        System.assertEquals(SalesforceApi.SUCCESS_MESSAGE, contact.SyncMessage__c);
    }
    
    
    @IsTest 
    private static void executeWithMixedResponse() {

        // Setup
        List<SalesforceApi.Response> responses = new List<SalesforceApi.Response>();
        responses.addAll(success());
        responses.addAll(error());
        
        new HttpMock()
            .post('/services/data/v49.0/composite/sobjects/Contact/ExternalId__c', responses)
            .mock();


        // Exercise
        Test.startTest();
            new Contact_t().first('a');
	        new Contact_t().first('b').persist();
        Test.stopTest();


        // Verify
        List<Contact> contacts = [Select SyncMessage__c From Contact];
        System.assertEquals(SalesforceApi.SUCCESS_MESSAGE, contacts[0].SyncMessage__c);
        System.assertEquals('Code: message', contacts[1].SyncMessage__c);
    }
    
    
    // HELPER
    
    private static List<SalesforceApi.Response> success() {
        return new List<SalesforceApi.Response> {
		            new SalesforceApi.Response(true, new Random().string(18))
               };
    }
    
    
    private static List<SalesforceApi.Response> error() {
        return new List<SalesforceApi.Response> {
            new SalesforceApi.Response(new List<SalesforceApi.Error> {
                new SalesforceApi.Error('Code', 'message')
            })
        };
    }
}