trigger progressUnitResponses on Progress_Unit_Per_Response__c (before update, after update) {

    if(Trigger.isBefore){
        unitResponseTrigger.onBeforeUpdate(Trigger.New, Trigger.oldMap);

    }else{
        unitResponseTrigger.onAfterUpdate(Trigger.New, Trigger.oldMap); 
    }    
}


   