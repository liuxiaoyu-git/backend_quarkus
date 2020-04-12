package com.example.quarkus.health;

import javax.enterprise.context.ApplicationScoped;

import com.example.quarkus.ApplicationConfig;

import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.Readiness;

@Readiness
@ApplicationScoped
public class AppReadiness implements HealthCheck {
    @Override
    public HealthCheckResponse call() {
        if (ApplicationConfig.IS_READY.get())
            return HealthCheckResponse.up("Ready");
        else
            return HealthCheckResponse.down("Ready");
    }
}