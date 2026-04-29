package com.mycompany.banksystem;

import java.math.BigDecimal;
import java.util.*;

public class DataSeeder {

    private final BankService service;
    private final Random random = new Random();

    private final String[] firstNames = {
        "Ahmed", "Omar", "Sara", "Mona", "Youssef",
        "Nour", "Ali", "Hana", "Kareem", "Zeinab"
    };

    private final String[] lastNames = {
        "Hassan", "Ali", "Mohamed", "Amr", "Hamed",
        "Mostafa", "Khaled", "Tarek", "Fathy", "Samir"
    };

    public DataSeeder(BankService service) {
        this.service = service;
    }

    public void seed() {

        try {
            System.out.println("=== START SEEDING ===");

            Centralbank cbe = new Centralbank(
                    "Central Bank of Egypt",
                    "Egypt",
                    "CBE100",
                    new BigDecimal("15.5"),
                    "high",
                    "active"
            );

            service.insertCentralBank(cbe);

            List<Bank> banks = new ArrayList<>();
            List<Customer> customers = new ArrayList<>();
            List<Account> accounts = new ArrayList<>();
            List<Card> cards = new ArrayList<>();

            // ================= BANKS =================
            for (int i = 1; i <= 50; i++) {
                Bank b = new Bank(
                        "Bank " + i,
                        "SWIFT" + i,
                        "Egypt",
                        "active",
                        cbe
                );
                service.insertBank(b);
                banks.add(b);
            }

            // ================= CUSTOMERS =================
            for (int i = 1; i <= 100; i++) {

                Customer c = new Customer(
                        "User" + i,
                        "Test" + i,
                        "2026-04-26",
                        "user" + i + "@mail.com",
                        "0100" + i,
                        "verified",
                        "2990" + i,
                        null
                );

                service.insertCustomer(c);
                customers.add(c);
            }

            // ================= ACCOUNTS =================
            for (int i = 1; i <= 150; i++) {

                Customer c = customers.get(random.nextInt(customers.size()));
                Bank b = banks.get(random.nextInt(banks.size()));

                Account a = new Account(
                        "savings",
                        BigDecimal.valueOf(1000 + random.nextInt(100000)),
                        "EGP",
                        "active",
                        new Date(),
                        c,
                        b,
                        null
                );

                service.insertAccount(a);
                accounts.add(a);
                c.addAccount(a);
            }

            // ================= CARDS =================
            String[] cardTypes = {"debit", "credit", "prepaid"};

            for (int i = 1; i <= 200; i++) {

                Account acc = accounts.get(random.nextInt(accounts.size()));

                String type = cardTypes[random.nextInt(cardTypes.length)];

                Card card = new Card(
                        type,
                        "4444-xxxx-" + i,
                        new Date(),
                        "hash" + i,
                        "active",
                        BigDecimal.valueOf(5000 + random.nextInt(50000)),
                        new Date(),
                        acc
                );

                service.insertCard(card);
                cards.add(card);
                acc.addCard(card);
            }

            System.out.println("=== SEEDING DONE ===");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}