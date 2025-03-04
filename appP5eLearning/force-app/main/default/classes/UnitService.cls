
public with sharing class UnitService {

    @AuraEnabled(cacheable=false)
    public static Boolean registerUnitResponse(Id unitId, String jsonAnswer) {

        System.debug(unitId + jsonAnswer);

        Savepoint sp = Database.setSavepoint();
        Progress_Module_Per_Unit__c[] moduleResp = new List<Progress_Module_Per_Unit__c>(); 
        Progress_Module_Per_Unit__c moduleResponse = new Progress_Module_Per_Unit__c();

        try{


            //Busco desde la unidad el id modulo y sus question hijas en query
            Unit__c unit = [SELECT Module__c, (SELECT Id, Name FROM Questions__r), (SELECT Id, Tries__c FROM Progresses_Unit_Per_Responses__r WHERE Progress_Module_Per_Unit__r.User__c =:UserInfo.getUserId() ORDER BY Tries__c DESC LIMIT 1)FROM Unit__c WHERE Id =:unitId ];

            //verifico si ya existe modulo.

            moduleResp = [SELECT Id FROM Progress_Module_Per_Unit__c WHERE Module__c =: unit.Module__c AND User__c=: UserInfo.getUserId() AND Status__c= 'In Progress'];

            System.debug(moduleResp);

            if(moduleResp.size() < 1){

                 //Si no existe creo tabla de Progress module per unit pata 1er unidad repsondida y la inserto
                 moduleResponse= new Progress_Module_Per_Unit__c(User__c= UserInfo.getUserId(), Module__c = unit.Module__c, Status__c= 'In Progress');

            insert moduleResponse;     

            } else {
                moduleResponse = moduleResp[0]; 
            }
                    
              // Creo Unit Response y la populo con datos del qeury            
                    Progress_Unit_Per_Response__c unitResponse = new Progress_Unit_Per_Response__c (
                        Unit__c= unitId,
                        Progress_Module_Per_Unit__c= moduleResponse.Id,
                        Status__c= 'Draft'
                       // User__c= UserInfo.getUserId()                                                          
                    );



                    if(!unit.Progresses_Unit_Per_Responses__r.isEmpty()){ 
                        unitResponse.Tries__c= unit.Progresses_Unit_Per_Responses__r[0].Tries__c +1;// checkear!!!
                    }else{
                        unitResponse.Tries__c=1;
                    }
            //inserto la unit response.
            insert unitResponse;

             
            //guardo todas las questions con options en map traidas del user.
            Map<Id,Id> unitAnswersMap = (Map<Id,Id>)JSON.deserializeStrict(jsonAnswer, Map<Id,Id>.class);

            //Creo Lista de Answers de questions.        
            List<Answer_For_Progress__c> questionAnswers =  new List<Answer_For_Progress__c>();

            for (Question__c question : unit.Questions__r){

                //verificar si la pregunta de la query fue respondida en el mapa qeu viene de usuario
                if(unitAnswersMap.containsKey(question.Id)){

                    Answer_For_Progress__c questionResponse = new Answer_For_Progress__c (
                        Question__c= question.Id,
                        Option__c= unitAnswersMap.get(question.Id),
                        Progress_Unit_Per_Response__c= unitResponse.Id    
                           
                    );
                    questionAnswers.add(questionResponse);
                }
                //else{

                 //   throw new Exception('La pregunta '+question.Name+' no fue respondida y es requerida.');
                //}            
            }

            insert questionAnswers;

            //Actualizo el status__c a Answered para dispara el proceso de evaluacion.
            unitResponse.Status__c= 'Answered';
            update unitResponse;
            return true;

        }catch(Exception e){

            Database.rollback(sp);
            throw e;
        }
    
   }

   public class TrailWrapper{ 
        //Registro de Trail solicitado
        @AuraEnabled
        public Trail__c trail; 
        //Módulos con Unidades relacionadas
        @AuraEnabled
        public List<Module__c> modulesList;
        //Ids de módulos relacionados al Trail actual en los que el Alumno ya aprobó
        @AuraEnabled
        public List<Id> passedModuleIds; 
        //Ids de Unidades relacionadas a módulos del Trail actual que el Alumno ya aprobó
        @AuraEnabled
        public List<Id> passedUnitIds; 
        //Porcentaje de progreso del Alumno en el Trail
        @AuraEnabled
        public Integer progressTrail; 

        public TrailWrapper(Trail__c trail, List<Module__c> modulesList, List<Id> passedModuleIds, List<Id> passedUnitIds){
            this.trail = trail;
            this.modulesList = modulesList;
            this.passedModuleIds = passedModuleIds;
            this.passedUnitIds = passedUnitIds;      
            this.progressTrail = passedModuleIds.size()*100 / modulesList.size();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static TrailWrapper getTrailWrapper(Id trailId){
        //New Instance of TrailWrapper
        TrailWrapper trailWrap = new TrailWrapper([SELECT Name, Description__c, Total_Time__c, Total_Score__c FROM Trail__c WHERE Id =: trailId], getModules(trailId), getModuleIdsCompleted(trailId), getUnitIdsCompleted(trailId));

        return trailWrap;
    }

        private static List<Module__c> getModules(Id trailId){
            //Search related modules
            List<Progress_Trail_Per_Module__c> trailModules = [SELECT Module__c FROM Progress_Trail_Per_Module__c WHERE Trail__c =: trailId];
            
            Set<Id> moduleIds = new Set<Id>();
            for(Progress_Trail_Per_Module__c trailModule : trailModules){
                moduleIds.add(trailModule.Module__c);
            }
            return [SELECT Name, Estimated_Module_Time__c, Score__c, (SELECT Name, Time__c, Score__c, Content__c FROM Units__r) FROM Module__c WHERE Id IN : moduleIds];
        }

        private static List<Id> getModuleIdsCompleted(Id trailId){
        
            List<Progress_Module_Per_Unit__c> moduleResponses = [SELECT Module__c FROM Progress_Module_Per_Unit__c WHERE Is_Completed__c= true AND Module__c IN :getModules(trailId) AND User__c =: Userinfo.getUserId()];
            //Status__c = 'Completed'

            Set<Id> completedModuleIds = new Set<Id>();
            for(Progress_Module_Per_Unit__c moduleResp : moduleResponses){
                completedModuleIds.add(moduleResp.Module__c);
            }
            return new List<Id>(completedModuleIds);
        }
        
        private static List<Id> getUnitIdsCompleted(Id trailId){
            List<Progress_Unit_Per_Response__c> unitResponses = [SELECT Unit__c FROM Progress_Unit_Per_Response__c WHERE Stage__c = 'Completed' AND User__c =: Userinfo.getUserId() AND Unit__r.Module__c IN : getModules(trailId)];

            Set<Id> completedUnitIds = new Set<Id>();
            for(Progress_Unit_Per_Response__c unitResp : unitResponses){
                completedUnitIds.add(unitResp.Unit__c);
            }
            return  new List<Id>(completedUnitIds);    
        }



    public class UnitWrapper{
        @AuraEnabled public Unit__c unit; 
        //Registro de Unidad solicitada
        @AuraEnabled public List<Question__c> questionList;    
        //Listado de Preguntas con Opciones relacionadas

        public UnitWrapper(Unit__c unit, List<Question__c> questionList){

                this.unit = unit;
                this.questionList = questionList;
        } 
    }   

            @AuraEnabled(cacheable=true)
            public static UnitWrapper getUnitWrapper(Id unitId){
                //New Instance of UnitWrapper
                UnitWrapper unitWrap = new UnitWrapper([SELECT Id, Name, Content__c, Time__c, Score__c FROM Unit__c WHERE Id =: unitId], getQuestions(unitId));

                return unitWrap;
            }

            private static List<Question__c> getQuestions(Id unitId){
                    //Search related questions
                            
                    return [SELECT Name, Question_Content__c, (SELECT Name, Option_Content__c FROM Options__r) FROM Question__c WHERE Unit__c =: unitId];
            }   

}



    //------------------------------------------------------------------------------

/*
        //creo lista de Id de las preguntas que vinen del usuario del mapa
        List<Id> idQuestion = new List<Id>();
         for (Id e : answersMap.keySet()){
            idQuestion.add(e);
         }

         //creo lista de opciones traida de query que esten relacionadas a las Id de preguntas recibidas para determinar que valor tienen.

        List<Option__c> queryoptions = [SELECT Question__c, Is_Correct__c FROM Option__c WHERE Question__c IN:idQuestion];

        //creo mapa para retornar si son tru or false.

         
        Map<Id,Boolean> respuestasConValor = new Map<Id,Boolean>();
        
        //loopeo la query y determino si la question fue respondida tru or false.
        
        for(Option__c idOption : opcionesVerdaderas){
            if(idOption.Is_Correct__c != true){
                respuestasConValor.put(idOption.Question__c, true);
                }else{
                    respuestasConValor.put(idOption.Question__c, false);
            }
        }

        //aca no entiendo el primer valro de tries

            SObject triesQuery = [SELECT ID, Tries__c FROM Progress_Unit_Per_Response WHERE Question__c IN:idQuestion ORDER BY Tries__c DESC LIMIT 1];
        Integer tries = Integer.valueOf(triesQuery.get('Tries__c'));
        tries = tries +1; 


*/
 

//--------------------------------------------------------------------------


/* 

 public static final String opcionesDadas= '{"a013t00001J13bOAAR": "a063t00000aijUIAAY","a013t00001J13bPAAR": "a063t00000aijUYAAY", "a013t00001J13bQAAR":"a063t00000aijUKAAY"}';

System.debug(userOwner);         
System.debug(answersMap);
System.debug(idOption);
System.debug(correctOptions);
System.debug(userAnswer); 
*/