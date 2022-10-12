import { api, LightningElement } from 'lwc';

export default class ModuleView extends LightningElement {

@api module;
@api passedModuleIds;
@api passedUnitsIds;


get checkIcon() {
   if(this.passedModuleIds.includes(this.module.Id))
        return 'action:approval';
        }


        
}
  





/* module='yyyyxyyyy'
passedModulesIds=['xxxyxxx','yyyyxyyyy']
showCheck=false;
i=0;

for(i = 0 ; i < passedModulesIds.length ; i++){
if(passedModulesIds[i].includes(module)){
    showCheck=true;
}
} */


/* completedModule

passedModulesIds = { "passedModuleIds":["a003t0000152v19AAA"]};
module="a003t0000152v19AAA";

for(let key in this.passedModulesIds){
  for(let i =0; i<key.length;i++){
    if(this.passedModulesIds[key][i]==this.module.Id){
      this.completedModule=true;
    }
  }
} */






/* envioalPadre(){

  let moduleId = this.module.Id;
       
        const response = new CustomEvent("optionselect",{
            detail:{
                moduleId,
               }})
        this.dispatchEvent(response);

}

connectedCallback(){
    console.log('Module en el hijo----------',this.module);
}
 */