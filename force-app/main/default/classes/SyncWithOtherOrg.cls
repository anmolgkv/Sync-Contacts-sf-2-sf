public inherited sharing class SyncWithOtherOrg {
    
    private Set<Id> contactIds;


    // CONSTRUCTOR

    public SyncWithOtherOrg(List<Contact> contacts) {
        contactIds = new Map<Id, Contact>(contacts).keySet();
    }
    

    // PUBLIC

    public void execute() {
        if(!contactIds.isEmpty()) {
            sendToOtherOrg(contactIds);
        }
    }


    // PRIVATE
    
    @future(callout=true)
    private static void sendToOtherOrg(Set<Id> contactIds) {
        List<Contact> externalContacts = new List<Contact>();
        
        for(Contact contact : new ContactsSelector().byIds(contactIds)) {
            contact.ExternalId__c = contact.Id;
            contact.Id = null;
            externalContacts.add(contact);
        }
        
        try {
            List<SalesforceApi.Response> responses = new SalesforceApi().sendToOtherOrg(externalContacts); 
            persistSyncState(externalContacts, responses);           
        }
        catch(CalloutException ex) {
            persistSyncState(externalContacts, null);
        }
    }


    private static void persistSyncState(List<Contact> contacts, List<SalesforceApi.Response> responses) {

        for(Integer i = 0; i < contacts.size(); i++) {
            contacts[i].Id = contacts[i].ExternalId__c;
            contacts[i].SyncMessage__c = responses != null ? responses[i].message() : Label.CalloutError;
            contacts[i].ExternalId__c = responses != null ? responses[i].id : null;
        }
        
        // Note: Disable domain logic to avoid infinite loop
        fflib_SObjectDomain.getTriggerEvent(Contacts.class).disableAll();

        DMLManager.updateAsUser(contacts);
    }
}