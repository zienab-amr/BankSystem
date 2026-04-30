package com.mycompany.banksystem;

import javax.ws.rs.*;
import javax.ws.rs.core.*;
import java.util.List;

@Path("/") // Base path for all resources in this class
@Produces(MediaType.APPLICATION_JSON)
public class BankResource {

    private final BankService service = new BankService();

    // ================= BANK ENDPOINTS =================

    @GET
    @Path("/banks")
    public Response getBanks(
            @QueryParam("page") @DefaultValue("0") int page,
            @QueryParam("pageSize") @DefaultValue("10") int pageSize) {
        try {
            List<Bank> banks = service.getBanksPaginated(page, pageSize);
            return Response.ok(banks).build();
        } catch (Exception e) {
            return Response.serverError().entity("Error fetching banks: " + e.getMessage()).build();
        }
    }

    @POST
    @Path("/banks")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response addBank(Bank bank) {
        try {
            service.insertBank(bank);
            return Response.status(Response.Status.CREATED).entity(bank).build();
        } catch (Exception e) {
            return Response.serverError().entity("Error adding bank: " + e.getMessage()).build();
        }
    }

    // ================= CUSTOMER ENDPOINTS =================

    @GET
    @Path("/customers") // Flutter should call: http://localhost:8080/api/customers?bankId=X
    public Response getCustomersByBank(@QueryParam("bankId") int bankId) {
        try {
            System.out.println("🔥 API called for Customers with bankId: " + bankId);
            List<Customer> customers = service.getCustomersByBankId(bankId);
            
            // If the list is empty, we still return 200 OK with an empty array []
            return Response.ok(customers).build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.serverError().entity("Error fetching customers: " + e.getMessage()).build();
        }
    }
}