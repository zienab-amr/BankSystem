/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.banksystem;

import java.io.Serializable;
import java.util.Collection;
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
import javax.persistence.*;
/**
 *
 * @author Royal
 */
@Entity
@Table(name = "bank")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Bank.findAll", query = "SELECT b FROM Bank b"),
    @NamedQuery(name = "Bank.findByBankID", query = "SELECT b FROM Bank b WHERE b.bankID = :bankID"),
    @NamedQuery(name = "Bank.findByBankname", query = "SELECT b FROM Bank b WHERE b.bankname = :bankname"),
    @NamedQuery(name = "Bank.findBySwiftCode", query = "SELECT b FROM Bank b WHERE b.swiftCode = :swiftCode"),
    @NamedQuery(name = "Bank.findByCountry", query = "SELECT b FROM Bank b WHERE b.country = :country"),
    @NamedQuery(name = "Bank.findByStatus", query = "SELECT b FROM Bank b WHERE b.status = :status")})
public class Bank implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "Bank_ID")
    private Integer bankID;
    @Column(name = "Bank_name")
    private String bankname;
    @Column(name = "swift_code")
    private String swiftCode;
    @Column(name = "country")
    private String country;
    @Column(name = "status")
    private String status;
   @OneToMany(mappedBy = "bankID", cascade = CascadeType.ALL, orphanRemoval = true)
private Collection<Account> accountCollection;
    @ManyToOne
    @JoinColumn(name = "CentralBank_ID", nullable = false)
    private Centralbank centralBankID;
    public Bank() {
    }
    
    public Bank(String bankname, String swiftCode, String country, String status, Centralbank centralBank) {
        this.bankname = bankname;
        this.swiftCode = swiftCode;
        this.country = country;
        this.status = status;
     
        this.centralBankID = centralBank;
    }

    public void setCentralBank(Centralbank centralBank) {
        this.centralBankID = centralBank;
    }

    public static long getSerialVersionUID() {
        return serialVersionUID;
    }
    

    public Centralbank getCentralBank() {
        return centralBankID;
    }

    public Bank(Integer bankID) {
        this.bankID = bankID;
    }

    public Integer getBankID() {
        return bankID;
    }

    public void setBankID(Integer bankID) {
        this.bankID = bankID;
    }

    public String getBankname() {
        return bankname;
    }

    public void setBankname(String bankname) {
        this.bankname = bankname;
    }

    public String getSwiftCode() {
        return swiftCode;
    }

    public void setSwiftCode(String swiftCode) {
        this.swiftCode = swiftCode;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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
        hash += (bankID != null ? bankID.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        if (!(object instanceof Bank)) {
            return false;
        }
        Bank other = (Bank) object;
        if ((this.bankID == null && other.bankID != null) || (this.bankID != null && !this.bankID.equals(other.bankID))) {
            return false;
        }
        return true;
    }
    

    @Override
    public String toString() {
        return "com.mycompany.banksystem.Bank[ bankID=" + bankID + " ]";
    }
    
}
