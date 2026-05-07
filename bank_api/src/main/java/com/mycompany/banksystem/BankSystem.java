package com.mycompany.banksystem;
import org.glassfish.grizzly.http.server.HttpServer;
import org.glassfish.jersey.grizzly2.httpserver.GrizzlyHttpServerFactory;
import org.glassfish.jersey.server.ResourceConfig;
import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerResponseContext;
import javax.ws.rs.container.ContainerResponseFilter;
import java.net.URI;

public class BankSystem {
    public static void main(String[] args) throws Exception {

BankService service = new BankService();
try {
    DataSeeder seeder = new DataSeeder(service);
    seeder.seed();
    System.out.println("--- All Data Inserted Successfully! ---");
} catch (Exception e) {
    System.out.println("Seeding skipped: " + e.getMessage());
}

        ResourceConfig config = new ResourceConfig();
        config.register(BankResource.class);
        config.packages("com.mycompany.banksystem");
        config.register(new ContainerResponseFilter() {
            @Override
            public void filter(ContainerRequestContext request, ContainerResponseContext response) {
                response.getHeaders().add("Access-Control-Allow-Origin", "*");
                response.getHeaders().add("Access-Control-Allow-Headers", "origin, content-type, accept, authorization");
                response.getHeaders().add("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, HEAD");
            }
        });

HttpServer server = GrizzlyHttpServerFactory.createHttpServer(
    URI.create("http://0.0.0.0:8080/api/"), config
);

        System.out.println("Backend running at http://localhost:8080/api/banks");
        System.out.println("Press Enter to stop...");
        System.in.read();
        server.stop();
        service.closeConnection();
    }
}