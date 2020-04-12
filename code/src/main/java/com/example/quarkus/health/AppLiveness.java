package com.example.quarkus.health;

import javax.enterprise.context.ApplicationScoped;

import com.example.quarkus.ApplicationConfig;

import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.Liveness;

@Liveness
@ApplicationScoped
public class AppLiveness implements HealthCheck {

    @Override
    public HealthCheckResponse call() {
        if (ApplicationConfig.IS_ALIVE.get())
            return HealthCheckResponse.up("Live");
        else
            return HealthCheckResponse.down("Live");
    }
}