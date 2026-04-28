package com.mycompany.banksystem;

import java.math.BigDecimal; 
import java.util.Date;

public class BankSystem {
    public static void main(String[] args) {
        
        BankService service = new BankService();

        try {
            System.out.println("--- Starting Data Seeding ---");

            // 1. Adding Central Banks
            Centralbank cbe = new Centralbank("Central Bank of Egypt", "Egypt", "CBE100", new BigDecimal("15.50"), "high", "active");
            service.insertCentralBank(cbe);

            // 2. Adding Commercial Banks
            Bank nbe = new Bank("National Bank of Egypt", "NBEGEGCX", "Egypt", "active");
            Bank bmq = new Bank("Banque Misr", "BMIXEGCA", "Egypt", "active");
            Bank cib = new Bank("CIB Egypt", "CIBEEGCA", "Egypt", "active");
            
            service.insertBank(nbe);
            service.insertBank(bmq);
            service.insertBank(cib);

            // 3. Adding Customers
            Customer c1 = new Customer("Zeinab", "Amr", "2026-04-19", "zeinab@email.com", "01012345678", "active", "29901011234567",null);
            Customer c2 = new Customer("Ahmed", "Ali", "2026-04-19", "ahmed@email.com", "01198765432", "active", "28805051234567",null);
            Customer c3 = new Customer("Sara", "Hassan", "2026-04-19", "sara@email.com", "01211223344", "active", "29508081234567",null);
            
            service.insertCustomer(c1);
            service.insertCustomer(c2);
            service.insertCustomer(c3);

            // 4. Adding Accounts (استخدمنا BigDecimal للرصيد)
           Account a1 = new Account("savings", new BigDecimal("50000.00"), "EGP", "active", new Date(), c1, nbe, null);
        Account a2 = new Account("current", new BigDecimal("120000.50"), "USD", "active", new Date(), c1, cib, null);
        Account a3 = new Account("business", new BigDecimal("1500000.00"), "EGP", "active", new Date(), c2, bmq, null);
        Account a4 = new Account("savings", new BigDecimal("2500.00"), "EGP", "frozen", new Date(), c3, nbe, null);

            service.insertAccount(a1);
            service.insertAccount(a2);
            service.insertAccount(a3);
            service.insertAccount(a4);

            // 5. Adding Cards (استخدمنا BigDecimal للـ daily limit)
            Card card1 = new Card("debit", "4444-xxxx-xxxx-1111", new Date(), "hash123", "active", new BigDecimal("10000.00"), new Date(), a1);
            Card card2 = new Card("credit", "5555-xxxx-xxxx-2222", new Date(), "hash456", "active", new BigDecimal("50000.00"), new Date(), a2);
            Card card3 = new Card("prepaid", "6666-xxxx-xxxx-3333", new Date(), "hash789", "expired", new BigDecimal("5000.00"), new Date(), a3);
            Card card4 = new Card("debit", "4444-xxxx-xxxx-4444", new Date(), "hash000", "active", new BigDecimal("15000.00"), new Date(), a1);
            
            service.insertCard(card1);
            service.insertCard(card2);
            service.insertCard(card3);
            service.insertCard(card4);

            System.out.println("--- All Data Inserted Successfully! ---");

            System.out.println("\n--- Testing VIP Query ---");
            service.getVIPCustomers(100000.00);

        } catch (Exception e) {
            System.out.println("Error during data seeding: " + e.getMessage());
            e.printStackTrace();
        } finally {
            service.closeConnection();
        }
    }
}