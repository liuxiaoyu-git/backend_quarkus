package com.example.quarkus;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;

import java.net.URL;
import java.net.InetAddress;
import java.net.UnknownHostException;
import javax.ws.rs.GET;
import javax.ws.rs.HeaderParam;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import org.jboss.logging.Logger;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.eclipse.microprofile.metrics.MetricUnits;
import org.eclipse.microprofile.metrics.annotation.Counted;
import org.eclipse.microprofile.metrics.annotation.Timed;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.media.Content;
@Path("/")
public class BackendResource {
    @ConfigProperty(name = "app.version", defaultValue = "v1")
    String version;

    @ConfigProperty(name = "app.backend", defaultValue = "http://localhost:8080/version")
    String backend;

    @ConfigProperty(name = "app.message", defaultValue = "Hello, World")
    String message;

    @ConfigProperty(name = "app.errorCodeNotLive", defaultValue = "503")
    String errorCodeNotLive;

    @ConfigProperty(name = "app.errorCodeNotReady", defaultValue = "504")
    String errorCodeNotReady;

    @ConfigProperty(name = "app.showResponse", defaultValue = "true")
    String showResponse;

    private static final Logger logger = Logger.getLogger(BackendResource.class);

    @GET
    @Path("/")
    @Produces(MediaType.TEXT_PLAIN)
    @Operation(summary = "Call Service")
    @APIResponse(responseCode = "200", content = @Content(mediaType = MediaType.TEXT_PLAIN))
    @Counted(
        name = "countBackend", 
        description = "Counts how many times the backend method has been invoked"
        )
    @Timed(
        name = "timeBackend", 
        description = "Times how long it takes to invoke the backend method", 
        unit = MetricUnits.MILLISECONDS
        )
    public Response callBackend(@HeaderParam("user-agent") String userAgent) throws IOException {
        if (ApplicationConfig.IS_ALIVE.get() && ApplicationConfig.IS_READY.get()) {
            URL url;
            try {
                logger.info("Request to: " + backend);
                logger.info("showResponse: "+showResponse);
                logger.debug("User-Agent: "+userAgent);
                url = new URL(backend);
                final HttpURLConnection con = (HttpURLConnection) url.openConnection();
                con.setRequestMethod("GET");
                final int returnCode = con.getResponseCode();
                logger.info("Return Code: " + returnCode);
                if (Boolean.parseBoolean(showResponse)) {
                        String inputLine;
                        BufferedReader in = new BufferedReader(new InputStreamReader(
                            con.getInputStream()));
                        StringBuffer response = new StringBuffer();
                        while ((inputLine = in .readLine()) != null) {
                            response.append(inputLine);
                        } in .close();
                        logger.info("Response Body: " + response.toString());
                        if (response.toString().length() > 0) message = response.toString();
                    }

                    return Response.status(returnCode).encoding("text/plain")
                        .entity(generateMessage(message, Integer.toString(returnCode))).build();
                }
                catch (final IOException e) {
                    return Response.status(503).encoding("text/plain")
                        .entity(generateMessage(e.getMessage(), "503"))
                        .build();
                }
            } else {
                if (!ApplicationConfig.IS_ALIVE.get()) {
                    logger.info("Applicartion liveness is set to false, return " + errorCodeNotLive);
                    return Response.status(Integer.parseInt(errorCodeNotLive)).encoding("text/plain")
                        .entity(generateMessage("Application liveness is set to fasle", errorCodeNotLive))
                        .build();
                } else {
                    logger.info("Applicartion readiness is set to false, return " + errorCodeNotReady);
                    return Response.status(Integer.parseInt(errorCodeNotReady)).encoding("text/plain")
                        .entity(generateMessage("Application readiness is set to false", errorCodeNotReady))
                        .build();
                }

            }
        }

        @GET
        @Path("/version")
        @Produces(MediaType.TEXT_PLAIN)
        @Operation(summary = "Show Version")
        @APIResponse(responseCode = "200", content = @Content(mediaType = MediaType.TEXT_PLAIN))
        public Response version() {
            logger.info("Get Version:"+version);
            return Response.ok().encoding("text/plain").entity(generateMessage("", "200")).build();
        }

        @GET
        @Path("/stop")
        @Produces(MediaType.TEXT_PLAIN)
        @Operation(summary = "Set Liveness to false")
        @APIResponse(responseCode = "200", content = @Content(mediaType = MediaType.TEXT_PLAIN))
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
        @Operation(summary = "Set Readiness to false")
        @APIResponse(responseCode = "200", content = @Content(mediaType = MediaType.TEXT_PLAIN))
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
        @Operation(summary = "Set Liveness to true")
        @APIResponse(responseCode = "200", content = @Content(mediaType = MediaType.TEXT_PLAIN))
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
        @Operation(summary = "Set Readiness to true")
        @APIResponse(responseCode = "200", content = @Content(mediaType = MediaType.TEXT_PLAIN))
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
        @Operation(summary = "Show Liveness and Readiness")
        @APIResponse(responseCode = "200", content = @Content(mediaType = MediaType.TEXT_PLAIN))
        public Response statusApp() {
            logger.info("Check status");
            final String msg = "Liveness=" + ApplicationConfig.IS_ALIVE.get() + " Readiness=" +
                ApplicationConfig.IS_READY.get();
            return Response.ok().entity(generateMessage(msg, "200")).build();
        }

        private String generateMessage(final String msg, final String status) {
            //return "Backend version: " + version + ", Hostname: " + getLocalHostname() + ", Status: " + status + ", Message: " + msg;
            return "Backend version:" + version + ", Response:" + status + ", Host:" + getLocalHostname() + ", Status:" + status + ", Message: " + msg;
        }

        private String getLocalHostname() {
            InetAddress inetAddr;
            String hostname = "";
            try {
                inetAddr = InetAddress.getLocalHost();
                hostname = inetAddr.getHostName();
            } catch (final UnknownHostException e) {
                logger.error("Error get local hostname: " + e.getMessage());
            }
            return hostname;
        }
    }
