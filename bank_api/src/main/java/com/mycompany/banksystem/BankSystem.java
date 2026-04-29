package com.mycompany.banksystem;

<<<<<<< HEAD:bank_api/src/main/java/com/mycompany/banksystem/BankSystem.java
import java.math.BigDecimal; 
import java.util.Date;
=======
import java.math.BigDecimal;
import java.util.*;
>>>>>>> d5e4a4f (update):src/main/java/com/mycompany/banksystem/BankSystem.java

public class BankSystem {

    public static void main(String[] args) {

        BankService service = new BankService();

        try {
            // ================= SEED DATA =================
            DataSeeder seeder = new DataSeeder(service);
            seeder.seed();

            System.out.println("--- All Data Inserted Successfully! ---");

<<<<<<< HEAD:bank_api/src/main/java/com/mycompany/banksystem/BankSystem.java
            System.out.println("\n--- Testing VIP Query ---");
            service.getVIPCustomers(100000.00);
=======
            // ================= GET DATA FROM DB =================
            Account a1 = service.getAnyAccount();   
            Customer c1 = service.getAnyCustomer();
            Bank nbe = service.getAnyBank();
            Card card1 = service.getAnyCard();
            
            // ================= QUERIES =================
            service.getVIPCustomers(new BigDecimal("1000"));
            service.getActiveCardsWithCustomerDetails();
            service.getHighRiskActiveBanks();
            service.getTotalBalancePerBank();
            service.countAccountsPerCustomer();
            service.getCreditCardsByBankName("Bank 2");
            service.rankBanksByPerformance();
            service.getHighRiskCustomers();
            service.getRecentAccountsActivity();
            service.getRecentCardsActivity();
>>>>>>> d5e4a4f (update):src/main/java/com/mycompany/banksystem/BankSystem.java

            // ================= UPDATE TEST =================
            System.out.println("\n--- TEST UPDATE ACCOUNT ---");
            a1.setBalance(new BigDecimal("999999.99"));
            service.updateAccount(a1);

            System.out.println("\n--- TEST UPDATE BANK ---");
            nbe.setStatus("suspended");
            service.updateBank(nbe);

            System.out.println("\n--- TEST UPDATE CUSTOMER ---");
            c1.setEmail("newemail@test.com");
            service.updateCustomer(c1);

            System.out.println("\n--- TEST UPDATE CARD ---");
            card1.setStatus("blocked");
            service.updateCard(card1);

            // ================= DELETE =================
            System.out.println("\n========== TEST DELETE ==========");
            service.deleteCard(card1.getCardID());
            
            service.deleteAccount(a1.getAccountID());

            System.out.println("========== DELETE DONE ==========");
          
   } 
        catch (Exception e) 
   {
       e.printStackTrace();
        } finally {
            service.closeConnection();
        }
    }
}