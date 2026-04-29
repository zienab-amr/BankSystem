package com.mycompany.banksystem;

import java.util.*;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import java.math.BigDecimal;

public class BankService {
    
    private EntityManagerFactory emf;

    public BankService() {
        emf = Persistence.createEntityManagerFactory("BankSystemPU");
    }

    public void insertAccount(Account account) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(account); 
            em.getTransaction().commit();
            System.out.println("Account inserted successfully into the database!");
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            System.out.println("Error occurred while inserting the Account.");
        } finally {
            em.close();
        }
    }
    
    public void insertBank(Bank bank) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(bank); 
            em.getTransaction().commit();
            System.out.println("Bank inserted successfully into the database!");
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            System.out.println("Error occurred while inserting the Bank.");
        } finally {
            em.close();
        }
    }
    
      public void insertCard(Card card) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(card); 
            em.getTransaction().commit();
            System.out.println("Card inserted successfully into the database!");
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            System.out.println("Error occurred while inserting the Card.");
        } finally {
            em.close();
        }
    }
    
        public void insertCentralBank(Centralbank centralbank) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(centralbank); 
            em.getTransaction().commit();
            System.out.println("Central Bank inserted successfully into the database!");
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            System.out.println("Error occurred while inserting the Central Bank.");
        } finally {
            em.close();
        }
    }
        public void insertCustomer(Customer customer) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(customer); 
            em.getTransaction().commit();
            System.out.println("Customer inserted successfully into the database!");
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            System.out.println("Error occurred while inserting the Customer.");
        } finally {
            em.close();
        }
    }
    
    public void updateAccount(Account account) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            
            // دالة merge هي المسئولة عن التعديل (Update) في الـ ODB
            em.merge(account); 
            
            em.getTransaction().commit();
            System.out.println("Account updated successfully in the database!");
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            System.out.println("Error occurred while updating the Account.");
        } finally {
            em.close();
        }
    }

    
    public void updateBank(Bank bank) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            em.merge(bank); 
            em.getTransaction().commit();
            System.out.println("Bank updated successfully in the database!");
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            System.out.println("Error occurred while updating the Bank.");
        } finally {
            em.close();
        }
    }

        public void updateCard(Card card) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            em.merge(card); 
            em.getTransaction().commit();
            System.out.println("Card updated successfully in the database!");
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            System.out.println("Error occurred while updating the Card.");
        } finally {
            em.close();
        }
    }

        public void updateCentralBank(Centralbank centralbank) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            em.merge(centralbank); 
            em.getTransaction().commit();
            System.out.println("Central Bank updated successfully in the database!");
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            System.out.println("Error occurred while updating the Central Bank.");
        } finally {
            em.close();
        }
    }

       public void updateCustomer(Customer customer) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            em.merge(customer); 
            em.getTransaction().commit();
            System.out.println("Customer updated successfully in the database!");
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            System.out.println("Error occurred while updating the Customer.");
        } finally {
            em.close();
        }
    }
   
    public void deleteAccount(int accountId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            
            // 1. بندور على الحساب بالـ ID
            Account account = em.find(Account.class, accountId);
            
            // 2. لو لقاه، يمسحه
            if (account != null) {
                em.remove(account); 
                System.out.println("Account deleted successfully from the database!");
            } else {
                System.out.println("Account with ID " + accountId + " not found!");
            }
            
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            System.out.println("Error occurred while deleting the Account.");
        } finally {
            em.close();
        }
    }

    
    public void deleteBank(int bankId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            Bank bank = em.find(Bank.class, bankId);
            if (bank != null) {
                em.remove(bank);
                System.out.println("Bank deleted successfully from the database!");
            } else {
                System.out.println("Bank with ID " + bankId + " not found!");
            }
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            System.out.println("Error occurred while deleting the Bank.");
        } finally {
            em.close();
        }
    }

    public void deleteCard(int cardId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            Card card = em.find(Card.class, cardId);
            if (card != null) {
                em.remove(card);
                System.out.println("Card deleted successfully from the database!");
            } else {
                System.out.println("Card with ID " + cardId + " not found!");
            }
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            System.out.println("Error occurred while deleting the Card.");
        } finally {
            em.close();
        }
    }

    
    public void deleteCentralBank(int centralBankId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            Centralbank centralbank = em.find(Centralbank.class, centralBankId);
            if (centralbank != null) {
                em.remove(centralbank);
                System.out.println("Central Bank deleted successfully from the database!");
            } else {
                System.out.println("Central Bank with ID " + centralBankId + " not found!");
            }
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            System.out.println("Error occurred while deleting the Central Bank.");
        } finally {
            em.close();
        }
    }

    
    public void deleteCustomer(int customerId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            Customer customer = em.find(Customer.class, customerId);
            if (customer != null) {
                em.remove(customer);
                System.out.println("Customer deleted successfully from the database!");
            } else {
                System.out.println("Customer with ID " + customerId + " not found!");
            }
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            System.out.println("Error occurred while deleting the Customer.");
        } finally {
            em.close();
        }
    }
    
    // ==========================================
    // 6 Complex Queries (JPQL - ODB Mapping)
    // ==========================================

    // 1. Join 3 Tables (Customer + Account + Card)
    // الفكرة: استخراج بيانات العملاء (الاسم والتليفون) اللي عندهم كروت حالتها "نشطة" (active)
    public void getActiveCardsWithCustomerDetails() {
        EntityManager em = emf.createEntityManager();
        try {
            String jpql = "SELECT c.fname, c.lname, c.phone, cr.maskedNumber FROM Card cr JOIN cr.accountID a JOIN a.customerID c WHERE cr.status = 'active'";
            List<Object[]> results = em.createQuery(jpql).getResultList();
            
            System.out.println("--- Active Cards & Owners ---");
            for (Object[] result : results) {
                System.out.println("Name: " + result[0] + " " + result[1] + " | Phone: " + result[2] + " | Card: " + result[3]);
            }
        } finally {
            em.close();
        }
    }

    // 2. Aggregate Function (SUM) + Join (Account + Bank)
    // الفكرة: حساب إجمالي الأموال (السيولة) المودعة في كل بنك على حدة
    public void getTotalBalancePerBank() {
        EntityManager em = emf.createEntityManager();
        try {
            String jpql = "SELECT b.bankname, SUM(a.balance) FROM Account a JOIN a.bankID b GROUP BY b.bankname";
            List<Object[]> results = em.createQuery(jpql).getResultList();
            
            System.out.println("--- Total Balance Per Bank ---");
            for (Object[] result : results) {
                System.out.println("Bank: " + result[0] + " | Total Money: $" + result[1]);
            }
        } finally {
            em.close();
        }
    }

    // 3. Filtering with Parameters + Join (Customer + Account)
    // الفكرة: البحث عن كبار العملاء (VIP) اللي رصيدهم بيتخطى مبلغ معين يتم تمريره للدالة
    public void getVIPCustomers(BigDecimal  minBalance) {
        EntityManager em = emf.createEntityManager();
        try {
            String jpql = "SELECT c.fname, c.lname, a.balance, a.accountType FROM Account a JOIN a.customerID c WHERE a.balance >= :balance";
            List<Object[]> results = em.createQuery(jpql).setParameter("balance", minBalance).getResultList();
            
            System.out.println("--- VIP Customers (Balance >= " + minBalance + ") ---");
            for (Object[] result : results) {
                System.out.println("Name: " + result[0] + " " + result[1] + " | Balance: $" + result[2] + " | Type: " + result[3]);
            }
        } finally {
            em.close();
        }
    }

    // 4. Join (Bank + CentralBank) with Multiple Conditions
    // الفكرة: معرفة البنوك النشطة التي تقع تحت رقابة "عالية" (high monitoring) من البنك المركزي
    public void getHighRiskActiveBanks() {
        EntityManager em = emf.createEntityManager();
        try {
            String jpql = "SELECT b.bankname, b.swiftCode, cb.name FROM Bank b JOIN b.centralBankID cb WHERE cb.monitoringLevel = 'high' AND b.status = 'active'";
            List<Object[]> results = em.createQuery(jpql).getResultList();
            
            System.out.println("--- Active Banks under High Monitoring ---");
            for (Object[] result : results) {
                System.out.println("Bank: " + result[0] + " (SWIFT: " + result[1] + ") | Monitored by: " + result[2]);
            }
        } finally {
            em.close();
        }
    }

    // 5. Aggregate Function (COUNT) + Group By + Join (Account + Customer)
    // الفكرة: تقرير إحصائي يوضح كل عميل يمتلك كم حساب بنكي في النظام
    public void countAccountsPerCustomer() {
        EntityManager em = emf.createEntityManager();
        try {
            String jpql = "SELECT c.fname, c.lname, COUNT(a) FROM Account a JOIN a.customerID c GROUP BY c.fname, c.lname";
            List<Object[]> results = em.createQuery(jpql).getResultList();
            
            System.out.println("--- Number of Accounts per Customer ---");
            for (Object[] result : results) {
                System.out.println("Customer: " + result[0] + " " + result[1] + " | Total Accounts: " + result[2]);
            }
        } finally {
            em.close();
        }
    }

    // 6. Complex 3-Table Join (Card + Account + Bank)
    // الفكرة: استخراج كروت الـ Credit المرتبطة ببنوك معينة (مثل البنك الأهلي)
    public void getCreditCardsByBankName(String targetBankName) {
        EntityManager em = emf.createEntityManager();
        try {
            String jpql = "SELECT cr.cardtype, cr.maskedNumber, b.bankname FROM Card cr JOIN cr.accountID a JOIN a.bankID b WHERE cr.cardtype = 'credit' AND b.bankname = :bName";
            List<Object[]> results = em.createQuery(jpql).setParameter("bName", targetBankName).getResultList();
            
            System.out.println("--- Credit Cards for " + targetBankName + " ---");
            for (Object[] result : results) {
                System.out.println("Card Type: " + result[0] + " | Number: " + result[1] + " | Bank: " + result[2]);
            }
        } finally {
            em.close();
        }
    }
    public void rankBanksByPerformance() {
    EntityManager em = emf.createEntityManager();
    try {
        String jpql =
            "SELECT b.bankname, " +
            "COUNT(a), " +
            "SUM(a.balance) " +
            "FROM Bank b " +
            "LEFT JOIN b.accountCollection a " +
            "GROUP BY b.bankname " +
            "ORDER BY SUM(a.balance) DESC";

        List<Object[]> results = em.createQuery(jpql).getResultList();

        System.out.println("--- Bank Performance Ranking ---");
        int rank = 1;

        for (Object[] row : results) {
            System.out.println(
                "#" + rank++ +
                " Bank: " + row[0] +
                " | Accounts: " + row[1] +
                " | Total Balance: " + row[2]
            );
        }

    } finally {
        em.close();
    }
    
}
    public void getHighRiskCustomers() {
    EntityManager em = emf.createEntityManager();

    try {
        String jpql =
            "SELECT c.fname, c.lname, " +
            "COUNT(DISTINCT a.accountID), " +
            "COUNT(DISTINCT cr.cardID), " +
            "SUM(a.balance) " +
            "FROM Customer c " +
            "LEFT JOIN c.accountCollection a " +
            "LEFT JOIN a.cardCollection cr " +
            "GROUP BY c.customerID, c.fname, c.lname " +
            "HAVING COUNT(DISTINCT a.accountID) > 1 " +
            "OR COUNT(DISTINCT cr.cardID) > 2 " +
            "OR SUM(a.balance) < 1000";

        List<Object[]> results = em.createQuery(jpql).getResultList();

        System.out.println("--- HIGH RISK CUSTOMERS ---");

        for (Object[] row : results) {
            System.out.println(
                "Name: " + row[0] + " " + row[1] +
                " | Accounts: " + row[2] +
                " | Cards: " + row[3] +
                " | Total Balance: " + row[4]
            );
        }

    } finally {
        em.close();
    }
}
                 //****************//
    
    public void getRecentAccountsActivity() {
    EntityManager em = emf.createEntityManager();

    try {
        String jpql =
            "SELECT c.fname, c.lname, a.accountType, a.balance, a.openedat " +
            "FROM Account a " +
            "JOIN a.customerID c " +
            "WHERE a.openedat >= :dateThreshold " +
            "ORDER BY a.openedat DESC";

        Date dateThreshold = new Date(System.currentTimeMillis() - (30L * 24 * 60 * 60 * 1000));

        List<Object[]> results = em.createQuery(jpql)
                .setParameter("dateThreshold", dateThreshold)
                .getResultList();

        System.out.println("--- Recent Accounts (Last 30 Days) ---");

        for (Object[] row : results) {
            System.out.println(
                "Customer: " + row[0] + " " + row[1] +
                " | Type: " + row[2] +
                " | Balance: " + row[3] +
                " | Opened At: " + row[4]
            );
        }

    } finally {
        em.close();
    }
}
    public void getRecentCardsActivity() {
    EntityManager em = emf.createEntityManager();

    try {
        String jpql =
            "SELECT c.fname, c.lname, cr.cardtype, cr.status, cr.createdAt " +
            "FROM Card cr " +
            "JOIN cr.accountID a " +
            "JOIN a.customerID c " +
            "WHERE cr.createdAt >= :dateThreshold " +
            "ORDER BY cr.createdAt DESC";

        Date dateThreshold = new Date(System.currentTimeMillis() - (30L * 24 * 60 * 60 * 1000));

        List<Object[]> results = em.createQuery(jpql)
                .setParameter("dateThreshold", dateThreshold)
                .getResultList();

        System.out.println("--- Recent Cards (Last 30 Days) ---");

        for (Object[] row : results) {
            System.out.println(
                "Customer: " + row[0] + " " + row[1] +
                " | Card: " + row[2] +
                " | Status: " + row[3] +
                " | Created At: " + row[4]
            );
        }

    } finally {
        em.close();
    }
}
   public Account getAnyAccount() {
    EntityManager em = emf.createEntityManager();
    try {
        return em.createNamedQuery("Account.findAll", Account.class)
                 .setMaxResults(1)
                 .getSingleResult();
    } finally {
        em.close();
    }
}

public Customer getAnyCustomer() {
    EntityManager em = emf.createEntityManager();
    try {
        return em.createNamedQuery("Customer.findAll", Customer.class)
                 .setMaxResults(1)
                 .getSingleResult();
    } finally {
        em.close();
    }
}

public Bank getAnyBank() {
    EntityManager em = emf.createEntityManager();
    try {
        return em.createNamedQuery("Bank.findAll", Bank.class)
                 .setMaxResults(1)
                 .getSingleResult();
    } finally {
        em.close();
    }
}

public Card getAnyCard() {
    EntityManager em = emf.createEntityManager();
    try {
        return em.createNamedQuery("Card.findAll", Card.class)
                 .setMaxResults(1)
                 .getSingleResult();
    } finally {
        em.close();
    }
}

public Centralbank getAnyCentralBank() {
    EntityManager em = emf.createEntityManager();
    try {
        return em.createNamedQuery("Centralbank.findAll", Centralbank.class)
                 .setMaxResults(1)
                 .getSingleResult();
    } finally {
        em.close();
    }
}
public void closeConnection() {
    if (emf != null && emf.isOpen()) {
        emf.close();
        System.out.println("EntityManagerFactory closed successfully.");
    }
}
}