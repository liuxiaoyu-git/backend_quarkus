package com.example.quarkus;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
// import static org.hamcrest.CoreMatchers.is;

@QuarkusTest
public class ExampleResourceTest {

    @Test
    public void testVersion() {
        given()
          .when().get("/version")
          .then()
             .statusCode(200);
             //.body(is("hello"));
    }

    @Test
    public void testReadiness() {
        given()
          .when().get("/health/ready")
          .then()
             .statusCode(200);
    }

    @Test
    public void testLiveness() {
        given()
          .when().get("/health/live")
          .then()
             .statusCode(200);
    }
    
    // @Test
    // public void testService() {
    //     given()
    //       .when().get("/")
    //       .then()
    //          .statusCode(200);
    // }

}