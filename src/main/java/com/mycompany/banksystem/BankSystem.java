package com.mycompany.banksystem;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;

public class BankSystem {
    public static void main(String[] args) {
        
        // 1. بنعمل Factory بناءً على اسم الـ Persistence Unit 
        // (مهم جداً: افتحي ملف persistence.xml اللي في فولدر META-INF واتأكدي من اسم الـ name واكتبيه هنا بدل BankSystemPU لو مختلف)
        EntityManagerFactory emf = Persistence.createEntityManagerFactory("BankSystemPU");
        EntityManager em = emf.createEntityManager();

        try {
            // 2. بنبدأ الـ Transaction عشان هنعدل في الداتابيز
            em.getTransaction().begin();

            // 3. بنعمل Object جديد من جدول البنك ونملاه بيانات
            Bank newBank = new Bank();
            newBank.setBankname("البنك الأهلي المصري"); // راجعي اسم الـ Setter من كلاس البنك عندك
            newBank.setSwiftCode("NBEGEGCX");
            newBank.setCountry("Egypt");
            newBank.setStatus("active"); 

            // 4. بنحفظ الأوبجكت في الداتابيز (بتمثل جملة INSERT)
            em.persist(newBank);

            // 5. بنأكد الحفظ
            em.getTransaction().commit();
            
            System.out.println("تم إضافة البنك بنجاح في الداتابيز! عاش جداً!");

        } catch (Exception e) {
            // لو حصل أي إيرور بنلغي العملية عشان الداتابيز ماتبوظش
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
        } finally {
            // 6. بنقفل الاتصال
            em.close();
            emf.close();
        }
    }
}