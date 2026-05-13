package com.mycompany.banksystem;

import java.util.*;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import java.math.BigDecimal;
import javax.persistence.NoResultException;

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
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }
    
    public void insertBank(Bank bank) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();

        // Check Swift Code
        List results = em.createNativeQuery(
            "SELECT Bank_ID FROM bank WHERE swift_code = ?")
            .setParameter(1, bank.getSwiftCode())
            .getResultList();

        if (!results.isEmpty()) {
            em.getTransaction().rollback();
            throw new IllegalArgumentException("Swift code already exists for another bank");
        }

            Centralbank centralBank = em.find(Centralbank.class, 1);
            if (centralBank != null) {
                bank.setCentralBank(centralBank);
            }

            em.persist(bank); 
            em.getTransaction().commit();
            System.out.println("✅ Bank inserted successfully!");

    } catch (IllegalArgumentException e) {
        if (em.getTransaction().isActive()) em.getTransaction().rollback();
        throw e;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
        throw new RuntimeException(e);
        } finally {
            em.close();
        }
    }
    
   
   public void insertCard(Card card) {
    EntityManager em = emf.createEntityManager();
    try {
        em.getTransaction().begin();

        // 1. التأكد أولاً أن البطاقة غير موجودة مسبقاً (عن طريق الرقم مثلاً)
        String checkQuery = "SELECT COUNT(c) FROM Card c WHERE c.maskedNumber = :num";
        Long count = em.createQuery(checkQuery, Long.class)
                      .setParameter("num", card.getMaskedNumber())
                      .getSingleResult();

        if (count > 0) {
            System.out.println("⚠️ Card already exists with this number!");
            // يمكنك رمي Exception هنا ليعرف الـ Resource أن الإضافة فشلت بسبب التكرار
            throw new RuntimeException("Card already exists");
        }

        // 2. التحقق من وجود الحساب المرتبط بالبطاقة
        if (card.getAccountID() != null && card.getAccountID().getAccountID() != null) {
            Account account = em.find(Account.class, card.getAccountID().getAccountID());
            if (account != null) {
                card.setAccountID(account);
            }
        }

        // 3. الإضافة إذا لم تكن موجودة
        em.persist(card); 
        em.getTransaction().commit();
        System.out.println("✅ Card inserted successfully!");
        
    } catch (Exception e) {
        if (em.getTransaction().isActive()) em.getTransaction().rollback();
        e.printStackTrace();
        throw e; 
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
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }

    public EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    public void insertCustomer(Customer customer) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();

        // Check National ID
        List<Customer> dupNationalId = em.createQuery(
            "SELECT c FROM Customer c WHERE c.nationalID = :nid",
            Customer.class)
            .setParameter("nid", customer.getNationalID())
            .getResultList();

        if (!dupNationalId.isEmpty()) {
            em.getTransaction().rollback();
            throw new IllegalArgumentException("National ID already exists");
        }

        // Check Phone
        List<Customer> dupPhone = em.createQuery(
            "SELECT c FROM Customer c WHERE c.phone = :phone",
            Customer.class)
            .setParameter("phone", customer.getPhone())
            .getResultList();

        if (!dupPhone.isEmpty()) {
            em.getTransaction().rollback();
            throw new IllegalArgumentException("Phone already exists");
        }

            em.persist(customer); 
            em.getTransaction().commit();
            System.out.println("Customer inserted successfully!");

    } catch (IllegalArgumentException e) {
        if (em.getTransaction().isActive()) em.getTransaction().rollback();
        throw e;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
        throw new RuntimeException(e);
        } finally {
            em.close();
        }
    }
    
    public void updateAccount(Account account) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            if(account != null){
            em.merge(account); 
            em.getTransaction().commit();
            }
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }

    public void updateCard(Card card) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            if(card != null){
            em.merge(card); 
            em.getTransaction().commit();
            }
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }

    public void updateCentralBank(Centralbank centralbank) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            if(centralbank != null){
            em.merge(centralbank); 
            em.getTransaction().commit();
            }
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }

    public void updateCustomer(Customer customer) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();

        // Check National ID
        List<Customer> dupNationalId = em.createQuery(
            "SELECT c FROM Customer c WHERE c.nationalID = :nid AND c.customerID != :id",
            Customer.class)
            .setParameter("nid", customer.getNationalID())
            .setParameter("id", customer.getCustomerID())
            .getResultList();

        if (!dupNationalId.isEmpty()) {
            em.getTransaction().rollback();
            throw new IllegalArgumentException("National ID already exists for another customer");
        }

        // Check Phone
        List<Customer> dupPhone = em.createQuery(
            "SELECT c FROM Customer c WHERE c.phone = :phone AND c.customerID != :id",
            Customer.class)
            .setParameter("phone", customer.getPhone())
            .setParameter("id", customer.getCustomerID())
            .getResultList();

        if (!dupPhone.isEmpty()) {
            em.getTransaction().rollback();
            throw new IllegalArgumentException("Phone already exists for another customer");
        }

            em.merge(customer); 
            em.getTransaction().commit();
            System.out.println("Customer updated successfully!");

    } catch (IllegalArgumentException e) {
        if (em.getTransaction().isActive()) em.getTransaction().rollback();
        throw e;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
        throw new RuntimeException(e);
        } finally {
            em.close();
        }
    }

    public void updateBank(int id, String name, String swift, String status) {
        EntityManager em = emf.createEntityManager();
        try {
        // Check swift code uniqueness
        List results = em.createNativeQuery(
            "SELECT Bank_ID FROM bank WHERE swift_code = ? AND Bank_ID != ?")
            .setParameter(1, swift)
            .setParameter(2, id)
            .getResultList();

        if (!results.isEmpty()) {
            throw new IllegalArgumentException("Swift code already exists for another bank");
        }

            em.getTransaction().begin();
            int rows = em.createNativeQuery(
            "UPDATE bank SET Bank_name = ?, swift_code = ?, status = ? WHERE Bank_ID = ?")
            .setParameter(1, name)
            .setParameter(2, swift)
            .setParameter(3, status)
            .setParameter(4, id)
            .executeUpdate();

            em.getTransaction().commit();
            System.out.println("✅ Bank updated! ID: " + id + " | Rows affected: " + rows);

    } catch (IllegalArgumentException e) {
        if (em.getTransaction().isActive()) em.getTransaction().rollback();
        throw e;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
            throw new RuntimeException(e);
        } finally {
            em.close();
        }
    }

    public void deleteBank(int id) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();

            // 1. Delete cards linked to accounts of this bank
            em.createNativeQuery(
                "DELETE FROM card WHERE Account_ID IN (SELECT Account_ID FROM account WHERE Bank_ID = ?)"
            )
            .setParameter(1, id)
            .executeUpdate();

            em.createNativeQuery("DELETE FROM account WHERE Bank_ID = ?")
            .setParameter(1, id)
            .executeUpdate();

            int rows = em.createNativeQuery("DELETE FROM bank WHERE Bank_ID = ?")
            .setParameter(1, id)
            .executeUpdate();

            em.getTransaction().commit();
            System.out.println("✅ Bank deleted! ID: " + id + " | Rows affected: " + rows);
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
            throw new RuntimeException(e);
        } finally {
            em.close();
        }
    }
   
    public void deleteAccount(int accountId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            Account account = em.find(Account.class, accountId);
            if (account != null) em.remove(account);
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }

    public void deleteCard(int cardId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            Card card = em.find(Card.class, cardId);
            if (card != null) em.remove(card);
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }

    public void deleteCentralBank(int centralBankId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            Centralbank centralbank = em.find(Centralbank.class, centralBankId);
            if (centralbank != null) em.remove(centralbank);
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }

    public void deleteCustomer(int customerId) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            Customer customer = em.find(Customer.class, customerId);
            if (customer != null) em.remove(customer);
            em.getTransaction().commit();
            System.out.println("Customer deleted successfully!");
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }

    // ==========================================
    // COMPLEX QUERIES
    // ==========================================

    public List<Map<String, Object>> getTotalBalancePerBank() {
        EntityManager em = emf.createEntityManager();
        try {
            String jpql = "SELECT b.bankname, SUM(a.balance) FROM Account a JOIN a.bankID b GROUP BY b.bankname";
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
            String jpql = "SELECT c.fname, c.lname, a.balance, a.accountType FROM Account a JOIN a.customerID c WHERE a.balance >= :balance";
            List<Object[]> results = em.createQuery(jpql).setParameter("balance", minBalance).getResultList();
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

    public List<Map<String, Object>> rankBanksByPerformance() {
        EntityManager em = emf.createEntityManager();
        try {
            String jpql = "SELECT b.bankname, COUNT(a), SUM(a.balance) FROM Bank b LEFT JOIN b.accountCollection a GROUP BY b.bankname ORDER BY SUM(a.balance) DESC";
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

    public List<Map<String, Object>> getRecentCardsActivity() {
        EntityManager em = emf.createEntityManager();
        try {
            Date dateThreshold = new Date(System.currentTimeMillis() - (30L * 24 * 60 * 60 * 1000));
            String jpql = "SELECT c.fname, c.lname, cr.cardtype, cr.status, cr.createdAt FROM Card cr JOIN cr.accountID a JOIN a.customerID c WHERE cr.createdAt >= :dateThreshold ORDER BY cr.createdAt DESC";
            List<Object[]> results = em.createQuery(jpql).setParameter("dateThreshold", dateThreshold).getResultList();
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

public List<Map<String, Object>> getHighRiskCustomers() {
    EntityManager em = emf.createEntityManager();
    try {
        String jpql = "SELECT c.fname, c.lname, COUNT(DISTINCT a.accountID), COUNT(DISTINCT cr.cardID), SUM(a.balance) " +
                      "FROM Customer c LEFT JOIN c.accountCollection a LEFT JOIN a.cardCollection cr " +
                      "GROUP BY c.customerID, c.fname, c.lname " +
                      "HAVING COUNT(DISTINCT a.accountID) > 1 OR COUNT(DISTINCT cr.cardID) > 2 OR SUM(a.balance) < 1000";
        List<Object[]> results = em.createQuery(jpql).getResultList();
        List<Map<String, Object>> response = new ArrayList<>();
        for (Object[] row : results) {
            Map<String, Object> map = new HashMap<>();
            map.put("firstName", row[0] != null ? row[0] : "");
            map.put("lastName",  row[1] != null ? row[1] : "");
            map.put("accounts",  row[2] != null ? row[2] : 0);
            map.put("cards",     row[3] != null ? row[3] : 0);
            map.put("totalBalance", row[4] != null ? row[4] : 0);
            response.add(map);
        }
        return response;
    } finally {
        em.close();
    }
}


public List<Map<String, Object>> getCustomersByRiskLevel() {
    EntityManager em = emf.createEntityManager();
    try {
        BigDecimal riskThreshold = (BigDecimal) em.createQuery(
            "SELECT cb.riskThreshold FROM Centralbank cb WHERE cb.centralBankID = 1"
        ).getSingleResult();

        String jpql = "SELECT c.fname, c.lname, b.bankname, cb.monitoringLevel, " +
                      "SUM(a.balance), COUNT(DISTINCT a.accountID) " +
                      "FROM Customer c " +
                      "JOIN c.accountCollection a " +
                      "JOIN a.bankID b " +
                      "JOIN b.centralBankID cb " +
                      "GROUP BY c.customerID, c.fname, c.lname, b.bankname, cb.monitoringLevel " +
                      "HAVING SUM(a.balance) < :riskThreshold " +
                      "ORDER BY cb.monitoringLevel DESC";

        List<Object[]> results = em.createQuery(jpql)
                .setParameter("riskThreshold", riskThreshold)
                .getResultList();

        List<Map<String, Object>> response = new ArrayList<>();
        for (Object[] row : results) {
            Map<String, Object> map = new HashMap<>();
            map.put("firstName",       row[0] != null ? row[0] : "");
            map.put("lastName",        row[1] != null ? row[1] : "");
            map.put("bankName",        row[2] != null ? row[2] : "");
            map.put("monitoringLevel", row[3] != null ? row[3] : "");
            map.put("totalBalance",    row[4] != null ? row[4] : 0);
            map.put("accounts",        row[5] != null ? row[5] : 0);
            response.add(map);
        }
        return response;
    } catch (Exception e) {
        e.printStackTrace();
        throw new RuntimeException(e);
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

    public List<Customer> getAllCustomers() {
        EntityManager em = emf.createEntityManager();
        try {
            return em.createNamedQuery("Customer.findAll", Customer.class).getResultList();
        } finally {
            em.close();
        }
    }

    public List<Customer> getCustomersByBankId(int bankId) {
        EntityManager em = emf.createEntityManager();
        try {
            String jpql = "SELECT DISTINCT c FROM Customer c JOIN c.accountCollection a WHERE a.bankID.bankID = :bankId";
            return em.createQuery(jpql, Customer.class).setParameter("bankId", bankId).getResultList();
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

    public void closeConnection() {
        if (emf != null && emf.isOpen()) {
            emf.close();
            System.out.println("EntityManagerFactory closed successfully.");
        }
    }
   public List<Account> getAccountsByCustomerId(int customerId) {
    EntityManager em = emf.createEntityManager();
    try {
        String jpql = "SELECT a FROM Account a WHERE a.customerID.customerID = :id";

        return em.createQuery(jpql, Account.class)
                .setParameter("id", customerId)
                .getResultList();

    } finally {
        em.close();
    }
}
   public Card findCard(String cardNumber) {
    EntityManager em = emf.createEntityManager();
    try {
        if (cardNumber == null || cardNumber.trim().isEmpty()) {
            return null;
        }
        
        String normalized = cardNumber.replaceAll("\\s+", "").trim();
        
        String sql = "SELECT c.Card_ID, c.Card_type, c.Masked_number, c.expiry_date, " +
                     "c.cvv_hash, c.status, c.daily_limit, c.created_at, c.Account_ID " +
                     "FROM card c WHERE REPLACE(c.Masked_number, ' ', '') = ?";
        
        Object[] result = (Object[]) em.createNativeQuery(sql)
            .setParameter(1, normalized)
            .getSingleResult();
        
        if (result == null) return null;
        
        Card card = new Card();
        card.setCardID((Integer) result[0]);
        card.setCardtype((String) result[1]);
        card.setMaskedNumber((String) result[2]);
        card.setExpiryDate((java.util.Date) result[3]);
        card.setCvvHash((String) result[4]);
        card.setStatus((String) result[5]);
        card.setDailyLimit((BigDecimal) result[6]);
        card.setCreatedAt((java.util.Date) result[7]);
        
        if (result[8] != null) {
            Integer accountId = (Integer) result[8];
            String accountSql = "SELECT a.Account_ID, c.Customer_ID, c.Phone " +
                               "FROM account a " +
                               "LEFT JOIN customer c ON a.Customer_ID = c.Customer_ID " +
                               "WHERE a.Account_ID = ?";
            
            Object[] accountResult = (Object[]) em.createNativeQuery(accountSql)
                .setParameter(1, accountId)
                .getSingleResult();
            
            if (accountResult != null) {
                Account account = new Account();
                account.setAccountID((Integer) accountResult[0]);
                
                if (accountResult[1] != null) {
                    Customer customer = new Customer();
                    customer.setCustomerID((Integer) accountResult[1]);
                    customer.setPhone((String) accountResult[2]);
                    account.setCustomerID(customer);
                }
                card.setAccountID(account);
            }
        }
        
        return card;
        
    } catch (NoResultException e) {
        System.out.println("Card not found: " + cardNumber);
        return null;
    } catch (Exception e) {
        System.out.println("ERROR in findCard: " + e.getMessage());
        e.printStackTrace();
        return null;
    } finally {
        em.close();
    }
}
}