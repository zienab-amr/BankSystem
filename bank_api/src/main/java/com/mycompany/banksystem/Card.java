/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.banksystem;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.xml.bind.annotation.XmlRootElement;

/**
 *
 * @author Royal
 */
@Entity
@Table(name = "card")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Card.findAll", query = "SELECT c FROM Card c"),
    @NamedQuery(name = "Card.findByCardID", query = "SELECT c FROM Card c WHERE c.cardID = :cardID"),
    @NamedQuery(name = "Card.findByCardtype", query = "SELECT c FROM Card c WHERE c.cardtype = :cardtype"),
    @NamedQuery(name = "Card.findByMaskednumber", query = "SELECT c FROM Card c WHERE c.maskedNumber = :maskednumber"),
    @NamedQuery(name = "Card.findByExpiryDate", query = "SELECT c FROM Card c WHERE c.expiryDate = :expiryDate"),
    @NamedQuery(name = "Card.findByCvvHash", query = "SELECT c FROM Card c WHERE c.cvvHash = :cvvHash"),
    @NamedQuery(name = "Card.findByStatus", query = "SELECT c FROM Card c WHERE c.status = :status"),
    @NamedQuery(name = "Card.findByDailyLimit", query = "SELECT c FROM Card c WHERE c.dailyLimit = :dailyLimit"),
    @NamedQuery(name = "Card.findByCreatedAt", query = "SELECT c FROM Card c WHERE c.createdAt = :createdAt")})
public class Card implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "Card_ID")
    private Integer cardID;
    @Column(name = "Card_type")
    private String cardtype;
    @Column(name = "Masked_number")
    private String maskedNumber;
    @Column(name = "expiry_date")
    @Temporal(TemporalType.DATE)
    private Date expiryDate;
    @Column(name = "cvv_hash")
    private String cvvHash;
    @Column(name = "status")
    private String status;
    // @Max(value=?)  @Min(value=?)//if you know range of your decimal fields consider using these annotations to enforce field validation
    @Column(name = "daily_limit")
    private BigDecimal dailyLimit;
    @Column(name = "created_at")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createdAt;
    @JoinColumn(name = "Account_ID", referencedColumnName = "Account_ID")
    @ManyToOne
    private Account accountID;

    public Card() {
    }

    public Card(String cardtype, String maskedNumber, Date expiryDate, String cvvHash, String status, BigDecimal dailyLimit, Date createdAt, Account accountID) {
        this.cardtype = cardtype;
        this.maskedNumber = maskedNumber;
        this.expiryDate = expiryDate;
        this.cvvHash = cvvHash;
        this.status = status;
        this.dailyLimit = dailyLimit;
        this.createdAt = createdAt;
        this.accountID = accountID;
    }
    
    

    public Card(Integer cardID) {
        this.cardID = cardID;
    }

    public Integer getCardID() {
        return cardID;
    }

    public void setCardID(Integer cardID) {
        this.cardID = cardID;
    }

    public String getCardtype() {
        return cardtype;
    }

    public void setCardtype(String cardtype) {
        this.cardtype = cardtype;
    }

    public String getMaskedNumber() {
        return maskedNumber;
    }

    public void setMaskedNumber(String maskednumber) {
        this.maskedNumber = maskednumber;
    }

    public Date getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(Date expiryDate) {
        this.expiryDate = expiryDate;
    }

    public String getCvvHash() {
        return cvvHash;
    }

    public void setCvvHash(String cvvHash) {
        this.cvvHash = cvvHash;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public BigDecimal getDailyLimit() {
        return dailyLimit;
    }

    public void setDailyLimit(BigDecimal dailyLimit) {
        this.dailyLimit = dailyLimit;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public Account getAccountID() {
        return accountID;
    }

    public void setAccountID(Account accountID) {
        this.accountID = accountID;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (cardID != null ? cardID.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Card)) {
            return false;
        }
        Card other = (Card) object;
        if ((this.cardID == null && other.cardID != null) || (this.cardID != null && !this.cardID.equals(other.cardID))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.mycompany.banksystem.Card[ cardID=" + cardID + " ]";
    }
    
}
