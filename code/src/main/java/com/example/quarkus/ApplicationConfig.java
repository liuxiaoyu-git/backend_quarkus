package com.example.quarkus;

import java.util.concurrent.atomic.AtomicBoolean;

import javax.ws.rs.ApplicationPath;

import javax.ws.rs.core.Application;

@ApplicationPath("/")
public class ApplicationConfig extends Application {
    public static final AtomicBoolean IS_ALIVE = new AtomicBoolean(true);
    public static final AtomicBoolean IS_READY = new AtomicBoolean(true);
}
