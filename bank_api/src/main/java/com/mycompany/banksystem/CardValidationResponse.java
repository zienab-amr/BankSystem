/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.banksystem;

import java.math.BigDecimal;

/**
 *
 * @author Royal
 */
public class CardValidationResponse {

    private boolean exist;
    private boolean active;
    private boolean expired;
    private boolean blocked;
    private boolean frozen;
    private boolean expiryMatched;
    private boolean phoneMatched;
    private BigDecimal balance; 
    private String cardType; 


    public boolean isExist() {
        return exist;
    }

    public void setExist(boolean exist) {
        this.exist = exist;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public boolean isExpired() {
        return expired;
    }

    public void setExpired(boolean expired) {
        this.expired = expired;
    }

    public boolean isBlocked() {
        return blocked;
    }

    public void setBlocked(boolean blocked) {
        this.blocked = blocked;
    }

    public boolean isExpiryMatched() {
        return expiryMatched;
    }

    public void setExpiryMatched(boolean expiryMatched) {
        this.expiryMatched = expiryMatched;
    }

    public boolean isPhoneMatched() {
        return phoneMatched;
    }

    public void setPhoneMatched(boolean phoneMatched) {
        this.phoneMatched = phoneMatched;
    }
    
    public boolean isFrozen() {
        return frozen;
    }

    public void setFrozen(boolean frozen) {
        this.frozen = frozen;
    }

    public BigDecimal getBalance() {
        return balance;
    }

    public void setBalance(BigDecimal balance) {
        this.balance = balance;
    }

    public String getCardType() {
        return cardType;
    }

    public void setCardType(String cardType) {
        this.cardType = cardType;
    }
    
    
}