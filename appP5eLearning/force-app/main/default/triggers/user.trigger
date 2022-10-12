trigger user on User (after update) {

         //calculateRanks(unitRespoByUserId.values());
    
        for(User user : Trigger.New){
            if(user.Score__c >= 50000){
                user.Rank__c = 'RANGER';
            }else if(user.Score__c >= 35000 && user.Score__c<50000){
                user.Rank__c = 'EXPEDITIONER';
            }else if(user.Score__c >= 18000 && user.Score__c<35000 ){
                user.Rank__c = 'MOUNTAINEER';
            }else if(user.Score__c > 9000 && user.Score__c<18000){
                user.Rank__c = 'ADVENTURER';
            }else if(user.Score__c >= 3000 && user.Score__c<9000){
                user.Rank__c = 'EXPLORER';
            }else if(user.Score__c >= 200 && user.Score__c<300){
                user.Rank__c = 'HIKER';
            }else if(user.Score__c <= 199){
                user.Rank__c = 'SCOUT';
            }
        }

}