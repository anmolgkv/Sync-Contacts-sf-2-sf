@IsTest
private class SetPendingStatus_Test {
    @IsTest
    private static void execute() {
        
        // Setup
        fflib_SObjectDomain.getTriggerEvent(Contacts.class).disableAfterInsert();
        fflib_SObjectDomain.getTriggerEvent(Contacts.class).disableAfterUpdate();
        Contact c = (Contact) new Contact_t().persist();

        
        // Exercise
        c.LastName = 'Changed';
        update c;


        // Verify
        c = [Select SyncMessage__c FROM Contact];
        System.assertEquals('Pending', c.SyncMessage__c);
    }
}