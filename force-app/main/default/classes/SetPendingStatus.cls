public with sharing class SetPendingStatus {
    private List<Contact> contacts;

    public SetPendingStatus(List<Contact> contacts) {
        this.contacts = contacts;
    }


    public void execute() {
        for(Contact contact : contacts) {
            contact.SyncMessage__c = 'Pending';
        }
    }
}
