package com.example.quarkus.health;

import javax.enterprise.context.ApplicationScoped;

import com.example.quarkus.ApplicationConfig;

import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.Liveness;
import org.jboss.logging.Logger;

@Liveness
@ApplicationScoped
public class AppLiveness implements HealthCheck {

    private static final Logger logger = Logger.getLogger(AppLiveness.class);

    @Override
    public HealthCheckResponse call() {
        logger.debug("Liveness Healtcheck");
        if (ApplicationConfig.IS_ALIVE.get())
            return HealthCheckResponse.up("Live");
        else
            return HealthCheckResponse.down("Live");
    }
}