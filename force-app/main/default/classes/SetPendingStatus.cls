public with sharing class SetPendingStatus {
    private List<Contact> contacts;

    public SetPendingStatus(List<Contact> contacts) {
        this.contacts = contacts;
    }


    public SetPendingStatus(List<Contact> contacts, Map<Id, Contact> oldContacts) {
        this.contacts = filterRelevantRecords(contacts, oldContacts);   
    }


    public void execute() {
        for(Contact contact : contacts) {
            contact.SyncMessage__c = 'Pending';
        }
    }


    private List<Contact> filterRelevantRecords(List<Contact> contacts, Map<Id, Contact> oldContacts) {
        List<Contact> result = new List<Contact>();

        for(Contact contact : contacts) {
            Contact oldContact = oldContacts.get(contact.Id);
            
            if(SyncWithOtherOrg.isChanged(contact, oldContact)) {
                result.add(contact);
            }
        }

        return result;
    }
}
