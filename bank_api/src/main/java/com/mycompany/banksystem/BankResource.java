package com.mycompany.banksystem;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import javax.ws.rs.*;
import javax.ws.rs.core.*;
import java.util.List;
import java.util.Map;
import javax.persistence.EntityManager;

@Path("/") // Base path for all resources in this class
@Produces(MediaType.APPLICATION_JSON)
public class BankResource {

    private final BankService service = new BankService();

    // 1. ميثود الـ OPTIONS (حيوية جداً لعمل Flutter Web)
    // بتسمح للمتصفح إنه "يستأذن" السيرفر قبل ما يبعت الـ POST الحقيقي
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

    // 2. ميثود إضافة بنك (غيرنا الـ Path لـ /add عشان ميتخانقش مع الـ GET)
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
            
            // If the list is empty, we still return 200 OK with an empty array []
            return Response.ok(customers).build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.serverError().entity("Error fetching customers: " + e.getMessage()).build();
        }
    }
    // ميثود جديدة لجلب كل العملاء بدون التقيد ببنك
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
        
        // الرد ده هو اللي هيخلي فلاتر يشوف الـ Success
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
        // بنستخدم الخدمة Sعشان نسجل الحساب في الداتابيز
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

   // 1. ميثود الـ OPTIONS الشاملة (ضعه قبل ميثود الـ PUT)
    @OPTIONS
    @Path("/update/{id}")
    public Response handleOptions() {
        return Response.ok()
                .header("Access-Control-Allow-Origin", "*")
                .header("Access-Control-Allow-Methods", "PUT, POST, GET, DELETE, OPTIONS")
                .header("Access-Control-Allow-Headers", "Content-Type, Accept, Authorization")
                .build();
    }

    // 2. ميثود الـ PUT المعدلة بمسار أوضح
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
}