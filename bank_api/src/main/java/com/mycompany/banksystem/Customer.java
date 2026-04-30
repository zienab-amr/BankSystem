/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.banksystem;

import java.io.Serializable;
import java.util.*;
import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlTransient;

/**
 *
 * @author Royal
 */
@Entity
@Table(name = "customer")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Customer.findAll", query = "SELECT c FROM Customer c"),
    @NamedQuery(name = "Customer.findByCustomerID", query = "SELECT c FROM Customer c WHERE c.customerID = :customerID"),
    @NamedQuery(name = "Customer.findByFname", query = "SELECT c FROM Customer c WHERE c.fname = :fname"),
    @NamedQuery(name = "Customer.findByLname", query = "SELECT c FROM Customer c WHERE c.lname = :lname"),
    @NamedQuery(name = "Customer.findByCreatedat", query = "SELECT c FROM Customer c WHERE c.createdat = :createdat"),
    @NamedQuery(name = "Customer.findByEmail", query = "SELECT c FROM Customer c WHERE c.email = :email"),
    @NamedQuery(name = "Customer.findByPhone", query = "SELECT c FROM Customer c WHERE c.phone = :phone"),
    @NamedQuery(name = "Customer.findByStatus", query = "SELECT c FROM Customer c WHERE c.status = :status"),
    @NamedQuery(name = "Customer.findByNationalID", query = "SELECT c FROM Customer c WHERE c.nationalID = :nationalID")})
public class Customer implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "Customer_ID")
    private Integer customerID;
    @Column(name = "Fname")
    private String fname;
    @Column(name = "Lname")
    private String lname;
    @Column(name = "Created_at")
    private String createdat;
    @Column(name = "Email")
    private String email;
    @Column(name = "Phone")
    private String phone;
    @Column(name = "Status")
    private String status;
    @Column(name = "National_ID")
    private String nationalID;
    @OneToMany(mappedBy = "customerID")
    private Collection<Account> accountCollection;

    public Customer() {
    }

    public Customer(String fname, String lname, String createdat, String email, String phone, String status, String nationalID, Collection<Account> accountCollection) {
        this.fname = fname;
        this.lname = lname;
        this.createdat = createdat;
        this.email = email;
        this.phone = phone;
        this.status = status;
        this.nationalID = nationalID;
        this.accountCollection = accountCollection;
    }
    
public void addAccount(Account account) {
    if (accountCollection == null)
        accountCollection = new ArrayList<>();

    accountCollection.add(account);
    account.setCustomerID(this);
}
    public Customer(Integer customerID) {
        this.customerID = customerID;
    }

    public Integer getCustomerID() {
        return customerID;
    }

    public void setCustomerID(Integer customerID) {
        this.customerID = customerID;
    }

    public String getFname() {
        return fname;
    }

    public void setFname(String fname) {
        this.fname = fname;
    }

    public String getLname() {
        return lname;
    }

    public void setLname(String lname) {
        this.lname = lname;
    }

    public String getCreatedat() {
        return createdat;
    }

    public void setCreatedat(String createdat) {
        this.createdat = createdat;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNationalID() {
        return nationalID;
    }

    public void setNationalID(String nationalID) {
        this.nationalID = nationalID;
    }

@XmlTransient
    public Collection<Account> getAccountCollection() {
        return accountCollection;
    }

    public void setAccountCollection(Collection<Account> accountCollection) {
        this.accountCollection = accountCollection;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (customerID != null ? customerID.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Customer)) {
            return false;
        }
        Customer other = (Customer) object;
        if ((this.customerID == null && other.customerID != null) || (this.customerID != null && !this.customerID.equals(other.customerID))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.mycompany.banksystem.Customer[ customerID=" + customerID + " ]";
    }
    
}
