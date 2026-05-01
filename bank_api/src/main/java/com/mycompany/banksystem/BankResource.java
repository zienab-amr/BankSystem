package com.mycompany.banksystem;

import javax.ws.rs.*;
import javax.ws.rs.core.*;
import java.util.List;

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
        // بنستخدم الخدمة عشان نسجل الحساب في الداتابيز
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
}