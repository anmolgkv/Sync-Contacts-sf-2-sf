trigger Contacts on Contact (before insert, after insert, before update, after update) {
    fflib_SObjectDomain.triggerHandler(Contacts.class);
}