package org.onap.sdnc.oam.datamigrator.migrators;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import org.apache.commons.lang3.StringUtils;
import java.util.Map;
import java.util.Set;

public abstract class RenameDeleteLeafMigrator extends Migrator {

    protected static Map<String,String> renamedFields ;
    protected static Set<String> deletedFields ;

    @Override
    protected String convertData(JsonObject sourceData) {
        JsonObject target =  convert(sourceData,"");
        return  target.toString();
    }

    protected JsonObject convert(JsonObject source,String parent) {
        JsonObject target = new JsonObject();
        for (String key : source.keySet()){
            String prefixKey = StringUtils.isNotEmpty(parent) ? parent + "."+key : key;
            if(!deletedFields.contains(prefixKey)) {
                JsonElement value = source.get(key);
                if (value.isJsonPrimitive()) {
                    target.add(renamedFields.getOrDefault(prefixKey,key), value);
                } else if(value.isJsonArray()){
                    JsonArray targetList = new JsonArray();
                    JsonArray sourceArray = value.getAsJsonArray();
                    for(JsonElement  e : sourceArray){
                         targetList.add(convert(e.getAsJsonObject(),prefixKey));
                    }
                    target.add(renamedFields.getOrDefault(prefixKey,key), targetList);
                } else{
                    target.add(renamedFields.getOrDefault(prefixKey,key), convert(value.getAsJsonObject(),prefixKey));
                }
            }
        }
        return target;
    }
}
