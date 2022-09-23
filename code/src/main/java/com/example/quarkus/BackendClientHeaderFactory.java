package com.example.quarkus;

import javax.enterprise.context.ApplicationScoped;
import javax.ws.rs.core.MultivaluedHashMap;
import javax.ws.rs.core.MultivaluedMap;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.eclipse.microprofile.rest.client.ext.ClientHeadersFactory;
import org.jboss.logging.Logger;

@ApplicationScoped
public class BackendClientHeaderFactory implements ClientHeadersFactory {
    
    @ConfigProperty(name = "app.forward_headers",defaultValue = "x-request-id,x-b3-traceid,x-b3-spanid,x-b3-parentspanid,x-b3-sampled")
    String forward_headers;

    private static final Logger logger = Logger.getLogger(BackendClientHeaderFactory.class);

    @Override
    public MultivaluedMap<String, String> update(MultivaluedMap<String, String> incomingHeaders,
            MultivaluedMap<String, String> clientOutgoingHeaders) {
        
        MultivaluedMap<String, String> result = new MultivaluedHashMap<>();
        String[] headers = forward_headers.split("[,]", 0);
        for(String item: headers) {
            if(incomingHeaders.getFirst(item)!=null){
                logger.info("Header: "+item+":"+incomingHeaders.getFirst(item));
                result.add(item,incomingHeaders.getFirst(item));
            }
       }     
       return result;
    }
}
