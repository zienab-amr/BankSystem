/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.banksystem;

/**
 *
 * @author Royal
 */
public class CardValidationResponse {

    private boolean exist;
    private boolean active;
    private boolean expired;
    private boolean blocked;
    private boolean expiryMatched;
    private boolean phoneMatched;

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
}