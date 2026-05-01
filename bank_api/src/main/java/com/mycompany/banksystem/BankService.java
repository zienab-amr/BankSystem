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
            
            // ✅ هات البنك المركزي (ID = 1) من قاعدة البيانات
            Centralbank centralBank = em.find(Centralbank.class, 1);
            
            // ✅ حطه للبنك الجديد (تلقائياً)
            if (centralBank != null) {
                bank.setCentralBank(centralBank);
                System.out.println("✅ CentralBank ID = 1 assigned automatically");
            } else {
                System.out.println("⚠️ CentralBank not found, bank added without it");
            }
            
            em.persist(bank); 
            em.getTransaction().commit();
            System.out.println("✅ Bank inserted successfully into the database!");
            
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            System.out.println("❌ Error occurred while inserting the Bank: " + e.getMessage());
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
            Account account = em.find(Account.class, accountId);
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
            em.remove(customer); // 👈 بس كده
            System.out.println("Customer deleted successfully");
        }

        em.getTransaction().commit();

    } catch (Exception e) {
        if (em.getTransaction().isActive()) {
            em.getTransaction().rollback();
        }
        e.printStackTrace();
    }
    finally {
        em.close();
    }
}
    
    // ==========================================
    // COMPLEX QUERIES (JPQL - ODB Mapping)
    // ==========================================

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

 public List<Map<String, Object>> getTotalBalancePerBank() {
    EntityManager em = emf.createEntityManager();
    try {
        String jpql = "SELECT b.bankname, SUM(a.balance) " +
                      "FROM Account a JOIN a.bankID b " +
                      "GROUP BY b.bankname";

        List<Object[]> results = em.createQuery(jpql).getResultList();

        List<Map<String, Object>> response = new ArrayList<>();

        for (Object[] r : results) {
            Map<String, Object> map = new HashMap<>();
            map.put("bankName", r[0]);
            map.put("totalBalance", r[1]);
            response.add(map);
        }

        return response;

    } finally {
        em.close();
    }
}
 
   public List<Map<String, Object>> getVIPCustomers(BigDecimal minBalance) {
    EntityManager em = emf.createEntityManager();
    try {
        String jpql = "SELECT c.fname, c.lname, a.balance, a.accountType " +
                      "FROM Account a JOIN a.customerID c " +
                      "WHERE a.balance >= :balance";

        List<Object[]> results = em.createQuery(jpql)
                .setParameter("balance", minBalance)
                .getResultList();

        List<Map<String, Object>> response = new ArrayList<>();

        for (Object[] r : results) {
            Map<String, Object> map = new HashMap<>();
            map.put("firstName", r[0]);
            map.put("lastName", r[1]);
            map.put("balance", r[2]);
            map.put("type", r[3]);
            response.add(map);
        }

        return response;

    } finally {
        em.close();
    }
}
   
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
    
public List<Map<String, Object>> rankBanksByPerformance() {
    EntityManager em = emf.createEntityManager();
    try {
        String jpql =
            "SELECT b.bankname, COUNT(a), SUM(a.balance) " +
            "FROM Bank b LEFT JOIN b.accountCollection a " +
            "GROUP BY b.bankname " +
            "ORDER BY SUM(a.balance) DESC";

        List<Object[]> results = em.createQuery(jpql).getResultList();

        List<Map<String, Object>> response = new ArrayList<>();

        int rank = 1;
        for (Object[] row : results) {
            Map<String, Object> map = new HashMap<>();
            map.put("rank", rank++);
            map.put("bankName", row[0]);
            map.put("accounts", row[1]);
            map.put("totalBalance", row[2]);

            response.add(map);
        }

        return response;

    } finally {
        em.close();
    }
}
  public List<Map<String, Object>> getHighRiskCustomers() {
    EntityManager em = emf.createEntityManager();
    try {
        String jpql =
            "SELECT c.fname, c.lname, COUNT(DISTINCT a.accountID), " +
            "COUNT(DISTINCT cr.cardID), SUM(a.balance) " +
            "FROM Customer c " +
            "LEFT JOIN c.accountCollection a " +
            "LEFT JOIN a.cardCollection cr " +
            "GROUP BY c.customerID, c.fname, c.lname " +
            "HAVING COUNT(DISTINCT a.accountID) > 1 " +
            "OR COUNT(DISTINCT cr.cardID) > 2 " +
            "OR SUM(a.balance) < 1000";

        List<Object[]> results = em.createQuery(jpql).getResultList();

        List<Map<String, Object>> response = new ArrayList<>();

        for (Object[] row : results) {
            Map<String, Object> map = new HashMap<>();
            map.put("firstName", row[0]);
            map.put("lastName", row[1]);
            map.put("accounts", row[2]);
            map.put("cards", row[3]);
            map.put("totalBalance", row[4]);

            response.add(map);
        }
        return response;

    } finally {
        em.close();
    }
}
    

  public List<Map<String, Object>> getRecentCardsActivity() {
    EntityManager em = emf.createEntityManager();
    try {
      
        Date dateThreshold = new Date(System.currentTimeMillis() - (30L * 24 * 60 * 60 * 1000));
        String jpql = "SELECT c.fname, c.lname, cr.cardtype, cr.status, cr.createdAt " +
                      "FROM Card cr JOIN cr.accountID a JOIN a.customerID c " +
                      "WHERE cr.createdAt >= :dateThreshold " +
                      "ORDER BY cr.createdAt DESC";

        List<Object[]> results = em.createQuery(jpql)
                .setParameter("dateThreshold", dateThreshold)
                .getResultList();

        List<Map<String, Object>> response = new ArrayList<>();

        for (Object[] row : results) {
            Map<String, Object> map = new HashMap<>();
            map.put("firstName", row[0]);
            map.put("lastName", row[1]);
            map.put("cardType", row[2]);
            map.put("status", row[3]);
            map.put("createdAt", row[4]);

            response.add(map);
        }

        return response;

    } finally {
        em.close();
    }
}
  
    public Account getAnyAccount() {
        EntityManager em = emf.createEntityManager();
        try {
            return em.createNamedQuery("Account.findAll", Account.class).setMaxResults(1).getSingleResult();
        } finally {
            em.close();
        }
    }

    public Customer getAnyCustomer() {
        EntityManager em = emf.createEntityManager();
        try {
            return em.createNamedQuery("Customer.findAll", Customer.class).setMaxResults(1).getSingleResult();
        } finally {
            em.close();
        }
    }

    public Bank getAnyBank() {
        EntityManager em = emf.createEntityManager();
        try {
            return em.createNamedQuery("Bank.findAll", Bank.class).setMaxResults(1).getSingleResult();
        } finally {
            em.close();
        }
    }

    public Card getAnyCard() {
        EntityManager em = emf.createEntityManager();
        try {
            return em.createNamedQuery("Card.findAll", Card.class).setMaxResults(1).getSingleResult();
        } finally {
            em.close();
        }
    }

    public Centralbank getAnyCentralBank() {
        EntityManager em = emf.createEntityManager();
        try {
            return em.createNamedQuery("Centralbank.findAll", Centralbank.class).setMaxResults(1).getSingleResult();
        } finally {
            em.close();
        }
    }

    public List<Bank> getBanksPaginated(int page, int pageSize) {
        EntityManager em = emf.createEntityManager();
        try {
            return em.createNamedQuery("Bank.findAll", Bank.class)
                     .setFirstResult(page * pageSize)
                     .setMaxResults(pageSize)
                     .getResultList();
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
    public List<Customer> getAllCustomers() {
    EntityManager em = emf.createEntityManager();
    try {
        // تأكد أن "Customer.findAll" معرفة داخل كلاس الـ Entity الخاص بالـ Customer
        return em.createNamedQuery("Customer.findAll", Customer.class).getResultList();
    } finally {
        em.close();
    }
}
    //fatma
    public List<Customer> getCustomersByBankId(int bankId) {
    EntityManager em = emf.createEntityManager();
    try {
        String jpql = "SELECT DISTINCT c FROM Customer c " +
                      "JOIN c.accountCollection a " +
                      "WHERE a.bankID.bankID = :bankId";
        return em.createQuery(jpql, Customer.class)
                 .setParameter("bankId", bankId)
                 .getResultList();
    } finally {
        em.close();
    }
}
}