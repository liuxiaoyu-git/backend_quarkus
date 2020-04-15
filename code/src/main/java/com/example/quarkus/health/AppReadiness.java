package com.example.quarkus.health;

import javax.enterprise.context.ApplicationScoped;

import com.example.quarkus.ApplicationConfig;

import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.Readiness;
import org.jboss.logging.Logger;

@Readiness
@ApplicationScoped
public class AppReadiness implements HealthCheck {
    private static final Logger logger = Logger.getLogger(AppReadiness.class);

    @Override
    public HealthCheckResponse call() {
        logger.debug("Readiness Healthcheck");
        if (ApplicationConfig.IS_READY.get())
            return HealthCheckResponse.up("Ready");
        else
            return HealthCheckResponse.down("Ready");
    }
}