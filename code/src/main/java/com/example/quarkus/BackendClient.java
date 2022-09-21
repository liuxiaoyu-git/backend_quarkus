package com.example.quarkus;



import javax.ws.rs.Consumes;
import javax.ws.rs.GET;

import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.eclipse.microprofile.rest.client.annotation.RegisterClientHeaders;
import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;


@RegisterRestClient
 @RegisterClientHeaders(BackendClientHeaderFactory.class)
public interface BackendClient {

    @GET
    @Consumes(MediaType.TEXT_PLAIN)
    Response sendMessage();
}
