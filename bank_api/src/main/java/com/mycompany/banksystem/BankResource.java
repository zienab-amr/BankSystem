package com.mycompany.banksystem;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import javax.ws.rs.*;
import javax.ws.rs.core.*;
import java.util.List;
import java.util.Map;
import javax.persistence.EntityManager;

@Path("/") 
@Produces(MediaType.APPLICATION_JSON)
public class BankResource {

    private final BankService service = new BankService();

    @OPTIONS
    @Path("{path : .*}")
    public Response options() {
        return Response.ok()
                .header("Access-Control-Allow-Origin", "*")
                .header("Access-Control-Allow-Headers", "origin, content-type, accept, authorization")
                .header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, HEAD")
                .build();
    }

    @GET
    @Path("/banks")
    public Response getBanks(
            @QueryParam("page") @DefaultValue("0") int page,
            @QueryParam("pageSize") @DefaultValue("10") int pageSize) {
        try {
            List<Bank> banks = service.getBanksPaginated(page, pageSize);
            return Response.ok(banks)
                    .header("Access-Control-Allow-Origin", "*") // السماح بالوصول للبيانات
                    .build();
        } catch (Exception e) {
            return Response.serverError().entity("Error fetching banks: " + e.getMessage()).build();
        }
    }

    @POST
    @Path("/add")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response addBank(Bank bank) {
        try {
            service.insertBank(bank);
            return Response.status(Response.Status.CREATED)
                    .entity(bank)
                    .header("Access-Control-Allow-Origin", "*")
                    .build();
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
            
            return Response.ok(customers).build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.serverError().entity("Error fetching customers: " + e.getMessage()).build();
        }
    }
    @GET
    @Path("/customers/all") 
    public Response getAllCustomers() {
        try {
            System.out.println("🔥 API called: Fetching ALL customers from database");
            List<Customer> allCustomers = service.getAllCustomers(); // تأكدي إن الميثود دي موجودة في الـ Service
            return Response.ok(allCustomers)
                    .header("Access-Control-Allow-Origin", "*")
                    .build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.serverError()
                    .entity("Error fetching all customers: " + e.getMessage())
                    .header("Access-Control-Allow-Origin", "*")
                    .build();
        }
    }

  @POST
@Path("/customer")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public Response addCustomer(Customer customer) {
    try {
        service.insertCustomer(customer); 
        
        return Response.status(Response.Status.CREATED)
                .entity(customer) 
                .header("Access-Control-Allow-Origin", "*") // مهم جداً للـ Web
                .header("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE")
                .header("Access-Control-Allow-Headers", "Content-Type, Accept, Authorization")
                .build();
    } catch (Exception e) {
        return Response.serverError()
                .entity(e.getMessage())
                .header("Access-Control-Allow-Origin", "*")
                .build();
    }
}
@POST
@Path("/account")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public Response addAccount(Account account) {
    try {
        service.insertAccount(account); 
        
        return Response.status(Response.Status.CREATED)
                .entity(account)
                .header("Access-Control-Allow-Origin", "*")
                .header("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
                .header("Access-Control-Allow-Headers", "Content-Type")
                .build();
    } catch (Exception e) {
        return Response.serverError()
                .entity("Error adding account: " + e.getMessage())
                .header("Access-Control-Allow-Origin", "*")
                .build();
    }
}

    @OPTIONS
    @Path("/update/{id}")
    public Response handleOptions() {
        return Response.ok()
                .header("Access-Control-Allow-Origin", "*")
                .header("Access-Control-Allow-Methods", "PUT, POST, GET, DELETE, OPTIONS")
                .header("Access-Control-Allow-Headers", "Content-Type, Accept, Authorization")
                .build();
    }

 @PUT
@Path("/customers/{id}")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public Response updateCustomerPUT(@PathParam("id") int id, Customer customer) {
    try {
        System.out.println("✅ PUT RECEIVED - ID: " + id);

        customer.setCustomerID(id);
        service.updateCustomer(customer);

        return Response.ok(customer)
                .header("Access-Control-Allow-Origin", "*")
                .header("Access-Control-Allow-Methods", "PUT, GET, OPTIONS")
                .header("Access-Control-Allow-Headers", "Content-Type, Accept")
                .build();

    } catch (Exception e) {
        e.printStackTrace();
        return Response.serverError()
                .entity("Error: " + e.getMessage())
                .header("Access-Control-Allow-Origin", "*")
                .build();
    }
}
@DELETE
@Path("/customers/{id}")
@Produces(MediaType.APPLICATION_JSON)
public Response deleteCustomer(@PathParam("id") int id) {
    try {
        service.deleteCustomer(id);

        return Response.ok()
                .entity("Customer deleted successfully")
                .header("Access-Control-Allow-Origin", "*")
                .build();

    } catch (Exception e) {
        e.printStackTrace();
        return Response.serverError()
                .entity("Error deleting customer: " + e.getMessage())
                .header("Access-Control-Allow-Origin", "*")
                .build();
    }
}
@GET
@Path("/reports/total-balance")
@Produces(MediaType.APPLICATION_JSON)
public Response getTotalBalancePerBank() {
    try {
        return Response.ok(service.getTotalBalancePerBank())
                .header("Access-Control-Allow-Origin", "*")
                .build();
    } catch (Exception e) {
        return Response.serverError().entity(e.getMessage()).build();
    }
}
@GET
@Path("/reports/vip")
@Produces(MediaType.APPLICATION_JSON)
public Response getVIPCustomers(@QueryParam("minBalance") double minBalance) {
    try {
        return Response.ok(
                service.getVIPCustomers(BigDecimal.valueOf(minBalance))
        ).header("Access-Control-Allow-Origin", "*")
         .build();

    } catch (Exception e) {
        return Response.serverError().entity(e.getMessage()).build();
    }
}

@GET
@Path("/reports/recent-cards")
@Produces(MediaType.APPLICATION_JSON)
public Response getRecentCards() {
    try {
        return Response.ok(service.getRecentCardsActivity())
                .header("Access-Control-Allow-Origin", "*")
                .build();
    } catch (Exception e) {
        return Response.serverError()
                .entity(e.getMessage())
                .build();
    }
}
@GET
@Path("/reports/bank-ranking")
@Produces(MediaType.APPLICATION_JSON)
public Response getBankRanking() {
    try {
        return Response.ok(service.rankBanksByPerformance())
                .header("Access-Control-Allow-Origin", "*")
                .build();
    } catch (Exception e) {
        return Response.serverError()
                .entity(e.getMessage())
                .build();
    }
}
@OPTIONS
@Path("/banks/{id}")
public Response optionsBank() {
    return Response.ok()
            .header("Access-Control-Allow-Origin", "*")
            .header("Access-Control-Allow-Methods", "GET, PUT, DELETE, OPTIONS")
            .header("Access-Control-Allow-Headers", "Content-Type, Accept, Authorization")
            .build();
}

@DELETE
@Path("/banks/{id}")
@Produces(MediaType.APPLICATION_JSON)
public Response deleteBank(@PathParam("id") int id) {
    try {
        System.out.println("🗑️ DELETE RECEIVED - Bank ID: " + id);

        EntityManager em = service.getEntityManager();
        em.getTransaction().begin();
        em.createNativeQuery("DELETE FROM card WHERE Account_ID IN (SELECT Account_ID FROM account WHERE Bank_ID = ?)")
          .setParameter(1, id).executeUpdate();

        em.createNativeQuery("DELETE FROM account WHERE Bank_ID = ?")
          .setParameter(1, id).executeUpdate();

        em.createNativeQuery("DELETE FROM bank WHERE Bank_ID = ?")
          .setParameter(1, id).executeUpdate();

        em.getTransaction().commit();
        em.close();

        System.out.println("✅ Bank deleted successfully!");

        return Response.ok("Bank deleted successfully")
                .header("Access-Control-Allow-Origin", "*")
                .build();

    } catch (Exception e) {
        e.printStackTrace();
        return Response.serverError()
                .entity("Error: " + e.getMessage())
                .header("Access-Control-Allow-Origin", "*")
                .build();
    }
}
@PUT
@Path("/banks/{id}")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public Response updateBank(@PathParam("id") int id, Bank bank) {
    try {
        System.out.println(" PUT RECEIVED - Bank ID: " + id);
        System.out.println(" New name: " + bank.getBankname());
        System.out.println(" New swift: " + bank.getSwiftCode());
        System.out.println(" New status: " + bank.getStatus());

        EntityManager em = service.getEntityManager();
        em.getTransaction().begin();

        em.createNativeQuery(
            "UPDATE bank SET Bank_name = ?, swift_code = ?, status = ? WHERE Bank_ID = ?"
        )
        .setParameter(1, bank.getBankname())
        .setParameter(2, bank.getSwiftCode())
        .setParameter(3, bank.getStatus())
        .setParameter(4, id)
        .executeUpdate();

        em.getTransaction().commit();
        em.close();

        System.out.println(" DB updated successfully!");

        return Response.ok(bank)
                .header("Access-Control-Allow-Origin", "*")
                .build();

    } catch (Exception e) {
        e.printStackTrace();
        return Response.serverError()
                .entity("Error: " + e.getMessage())
                .header("Access-Control-Allow-Origin", "*")
                .build();
    }
}
@GET
@Path("/reports/high-risk")
@Produces(MediaType.APPLICATION_JSON)
public Response getHighRiskCustomers() {
    try {
        return Response.ok(service.getHighRiskCustomers())
                .header("Access-Control-Allow-Origin", "*")
                .build();
    } catch (Exception e) {
        return Response.serverError().entity(e.getMessage()).build();
    }
}

@GET
@Path("/reports/risk-level")
@Produces(MediaType.APPLICATION_JSON)
public Response getCustomersByRiskLevel() {
    try {
        return Response.ok(service.getCustomersByRiskLevel())
                .header("Access-Control-Allow-Origin", "*")
                .build();
    } catch (Exception e) {
        return Response.serverError().entity(e.getMessage()).build();
    }
}
}