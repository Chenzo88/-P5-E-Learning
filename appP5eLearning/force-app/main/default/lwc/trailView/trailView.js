import { api, LightningElement, wire } from 'lwc';
import getTrailWrapper from '@salesforce/apex/UnitService.getTrailWrapper';




export default class TrailView extends LightningElement {

@api recordId;

modulesList;
passedModuleIds;
trail
progressTrail
moduleId
passedUnitsIds
unitList
objectData
mapOfValues


@wire(getTrailWrapper, { trailId: '$recordId' })
    wiredData(result) {
       const {data,error} = result;    
      if (data) { 
        console.log('ESTO ES TODO----------',JSON.stringify(data));
        this.objectData= JSON.stringify({data});
        this.mapOfValues= JSON.parse(this.objectData);
        this.trail= data.trail;   
        this.passedUnitsIds = this.mapOfValues.data.passedUnitIds;
        this.passedModuleIds = this.mapOfValues.data.passedModuleIds;
        this.unitList = this.mapOfValues.data.modulesList[0].Units__r;
        this.modulesList = data.modulesList;
        this.progressTrail = data.progressTrail;
        console.log('ESTO ES MODULE LIST----------',this.modulesList);
        console.log('ESTO ES MODULE COMPLETED LIST----------',this.passedModuleIds);
        console.log('ESTO ES TRAILLLLLLL----------',this.trail);
        console.log('ESTO ES lista de unidades----------',this.passedUnitsIds); 
      
      
        
              } else if (error) {
         console.error('Error-->', error);
      }
    }



}



  
 /*   jsonResp
  this.jsonResp= JSON.parse( data );
        console.log(this.jsonResp); */

/* 


        {"modulesList":[{"Name":"Apex Specialist Module 1","Estimated_Module_Time__c":200,"Score__c":200,"Id":"a003t0000152v19AAA","Units__r":[{"Module__c":"a003t0000152v19AAA","Id":"a033t00000Sb0TMAAZ","Name":"Apex Specialist Unit 2 (1)","Time__c":100,"Score__c":100},{"Module__c":"a003t0000152v19AAA","Id":"a033t00000Sb0TQAAZ","Name":"Apex Specialist Unit 1 (1)","Time__c":100,"Score__c":100}]},{"Name":"Apex Specialist Module 2","Estimated_Module_Time__c":200,"Score__c":200,"Id":"a003t0000152v1EAAQ","Units__r":[{"Module__c":"a003t0000152v1EAAQ","Id":"a033t00000Sb0TLAAZ","Name":"Apex Specialist Unit 1 (2)","Time__c":100,"Score__c":100},{"Module__c":"a003t0000152v1EAAQ","Id":"a033t00000Sb0TVAAZ","Name":"Apex Specialist Unit 2 (2)","Time__c":100,"Score__c":100}]}],
        "passedModuleIds":["a003t0000152v19AAA"]
        ,"passedUnitIds":["a033t00000Sb0TVAAZ"],
        "progressTrail":50,
        "trail":{"Name":"Apex Specialist Trail","Description__c":"trail de prueba","Total_Time__c":400,"Total_Score__c":400,"Id":"a023t00000j0uNXAAY"}}


    POSICION [0] DE MODULE LIST:
     {"Name":"Apex Specialist Module 1","Estimated_Module_Time__c":200,"Score__c":200,"Id":"a003t0000152v19AAA","Units__r":[{"Module__c":"a003t0000152v19AAA","Id":"a033t00000Sb0TMAAZ","Name":"Apex Specialist Unit 2 (1)","Time__c":100,"Score__c":100},
     {"Module__c":"a003t0000152v19AAA","Id":"a033t00000Sb0TQAAZ","Name":"Apex Specialist Unit 1 (1)","Time__c":100,"Score__c":100} */

   /*  TRAIL:
     {"Name":"Apex Specialist Trail","Description__c":"trail de prueba","Total_Time__c":400,"Total_Score__c":400,"Id":"a023t00000j0uNXAAY"} */

   /* "modulesList":[{"Name":"Apex Specialist Module 1","Estimated_Module_Time__c":200,"Score__c":200,"Id":"a003t0000152v19AAA","Units__r":[{"Module__c":"a003t0000152v19AAA","Id":"a033t00000Sb0TMAAZ","Name":"Apex Specialist Unit 2 (1)","Time__c":100,"Score__c":100},{"Module__c":"a003t0000152v19AAA","Id":"a033t00000Sb0TQAAZ","Name":"Apex Specialist Unit 1 (1)","Time__c":100,"Score__c":100}]},
   
   {"Name":"Apex Specialist Module 2",
   "Estimated_Module_Time__c":200,
   "Score__c":200,"Id":"a003t0000152v1EAAQ",
   
   "Units__r":[{"Module__c":"a003t0000152v1EAAQ",
   "Id":"a033t00000Sb0TLAAZ",
   "Name":"Apex Specialist Unit 1 (2)",
   "Time__c":100,"Score__c":100},
   
   {"Module__c":"a003t0000152v1EAAQ",
   "Id":"a033t00000Sb0TVAAZ",
   "Name":"Apex Specialist Unit 2 (2)",
   "Time__c":100,"Score__c":100}]}],

   "passedModuleIds":["a003t0000152v19AAA"],

   "passedUnitIds":[],

   "progressTrail":50,

   "trail":{"Name":"Apex Specialist Trail","Description__c":"trail de prueba","Total_Time__c":400,"Total_Score__c":400,"Id":"a023t00000j0uNXAAY"}} */

/*     manejarModulo(event){
        this.moduleId = event.detail.moduleId;
        console.log('En el padre este dato------',this.moduleId);

    } */

