package com.example.quarkus;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.URL;
import java.net.InetAddress;
import java.net.UnknownHostException;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import org.jboss.logging.Logger;
import org.eclipse.microprofile.config.inject.ConfigProperty;

@Path("/")
public class BackendResource {
    @ConfigProperty(name = "version", defaultValue = "1.0.0")
    String version;

    @ConfigProperty(name = "backend", defaultValue = "http://localhost:8080/version")
    String backend;

    @ConfigProperty(name = "message", defaultValue = "Hello, World")
    String message;

    private static final Logger logger = Logger.getLogger(BackendResource.class);

    @GET
    @Path("/")
    @Produces(MediaType.TEXT_PLAIN)
    public Response callBackend() throws IOException {
        if (ApplicationConfig.IS_ALIVE.get() && ApplicationConfig.IS_READY.get()) {
            URL url;
            final String inputLine = "";
            try {
                logger.info("Request to: " + backend);
                url = new URL(backend);
                final HttpURLConnection con = (HttpURLConnection) url.openConnection();
                con.setRequestMethod("GET");
                final int returnCode = con.getResponseCode();
                logger.info("Return Code: " + returnCode);
                return Response.status(returnCode).encoding("text/plain")
                    .entity(generateMessage(message, Integer.toString(returnCode))).build();
            } catch (final IOException e) {
                return Response.status(503).encoding("text/plain")
                    .entity(generateMessage(e.getMessage(), "503"))
                    .build();
            }
        } else {
            int status = 503;
            if(!ApplicationConfig.IS_ALIVE.get()){
                logger.info("Applicartion liveness is set to false, return 504");
                status=504;
            }
            return Response.status(status).encoding("text/plain")
                .entity(generateMessage("Application is stopped", String.valueOf(status)))
                .build();
        }
    }

    @GET
    @Path("/version")
    @Produces(MediaType.TEXT_PLAIN)
    public Response version() {
        logger.info("Get Version");
        return Response.ok().encoding("text/plain").entity(generateMessage("", "200")).build();
    }

    @GET
    @Path("/stop")
    @Produces(MediaType.TEXT_PLAIN)
    public Response stopApp() {
        ApplicationConfig.IS_ALIVE.set(false);
        logger.info("Set Liveness to false");
        return Response.ok().encoding("text/plain")
            .entity(generateMessage("Liveness: " + ApplicationConfig.IS_ALIVE.get(), "200"))
            .build();
    }

    @GET
    @Path("/not_ready")
    @Produces(MediaType.TEXT_PLAIN)
    public Response notReadyApp() {
        ApplicationConfig.IS_READY.set(false);
        logger.info("Set Readiness to false");
        return Response.ok().encoding("text/plain")
            .entity(generateMessage("Readiness: " + ApplicationConfig.IS_READY.get(), "200"))
            .build();
    }

    @GET
    @Path("/start")
    @Produces(MediaType.TEXT_PLAIN)
    public Response startApp() {
        logger.info("Set Liveness to true");
        if (!ApplicationConfig.IS_ALIVE.get())
            ApplicationConfig.IS_ALIVE.set(true);
        return Response.ok().encoding("text/plain")
            .entity(generateMessage("Liveness: " + ApplicationConfig.IS_ALIVE.get(), "200"))
            .build();
    }

    @GET
    @Path("/ready")
    @Produces(MediaType.TEXT_PLAIN)
    public Response readyApp() {
        logger.info("Set Readiness to true");
        ApplicationConfig.IS_READY.set(true);
        return Response.ok().encoding("text/plain")
            .entity(generateMessage("Readiness: " + ApplicationConfig.IS_READY.get(), "200"))
            .build();
    }

    @GET
    @Path("/status")
    @Produces(MediaType.TEXT_PLAIN)
    public Response statusApp() {
        logger.info("Check status");
        final String msg = "Liveness=" + ApplicationConfig.IS_ALIVE.get() + " Readiness=" +
            ApplicationConfig.IS_READY.get();
        return Response.ok().entity(generateMessage(msg, "200")).build();
    }

    private String generateMessage(final String msg, final String status) {
        //return "Backend version: " + version + ", Hostname: " + getLocalHostname() + ", Status: " + status + ", Message: " + msg;
        return "Backend version:"+version+", Response:"+status+", Host:"+getLocalHostname()+", Status:"+ status + ", Message: "+ msg;
    }

    private String getLocalHostname() {
        InetAddress inetAddr;
        String hostname = "";
        try {
            inetAddr = InetAddress.getLocalHost();
            hostname = inetAddr.getHostName();
        } catch (final UnknownHostException e) {
            logger.error("Error get local hostname: "+e.getMessage());
        }
        return hostname;
    }
}