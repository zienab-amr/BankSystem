/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.banksystem;

import java.io.Serializable;
import java.math.BigDecimal;
import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Table;
import javax.xml.bind.annotation.XmlRootElement;

/**
 *
 * @author Royal
 */
@Entity
@Table(name = "centralbank")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "Centralbank.findAll", query = "SELECT c FROM Centralbank c"),
    @NamedQuery(name = "Centralbank.findByCentralBankID", query = "SELECT c FROM Centralbank c WHERE c.centralBankID = :centralBankID"),
    @NamedQuery(name = "Centralbank.findByName", query = "SELECT c FROM Centralbank c WHERE c.name = :name"),
    @NamedQuery(name = "Centralbank.findByCountry", query = "SELECT c FROM Centralbank c WHERE c.country = :country"),
    @NamedQuery(name = "Centralbank.findByRegulatoryCode", query = "SELECT c FROM Centralbank c WHERE c.regulatoryCode = :regulatoryCode"),
    @NamedQuery(name = "Centralbank.findByRiskThreshold", query = "SELECT c FROM Centralbank c WHERE c.riskThreshold = :riskThreshold"),
    @NamedQuery(name = "Centralbank.findByMonitoringLevel", query = "SELECT c FROM Centralbank c WHERE c.monitoringLevel = :monitoringLevel"),
    @NamedQuery(name = "Centralbank.findByStatus", query = "SELECT c FROM Centralbank c WHERE c.status = :status")})
public class Centralbank implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "CentralBank_ID")
    private Integer centralBankID;
    @Column(name = "name")
    private String name;
    @Column(name = "country")
    private String country;
    @Column(name = "regulatory_code")
    private String regulatoryCode;
    // @Max(value=?)  @Min(value=?)//if you know range of your decimal fields consider using these annotations to enforce field validation
    @Column(name = "risk_threshold")
    private BigDecimal riskThreshold;
    @Column(name = "monitoring_level")
    private String monitoringLevel;
    @Column(name = "status")
    private String status;

    public Centralbank() {
    }

    public Centralbank(String name, String country, String regulatoryCode, BigDecimal riskThreshold, String monitoringLevel, String status) {
        this.name = name;
        this.country = country;
        this.regulatoryCode = regulatoryCode;
        this.riskThreshold = riskThreshold;
        this.monitoringLevel = monitoringLevel;
        this.status = status;
    }

    public Centralbank(Integer centralBankID) {
        this.centralBankID = centralBankID;
    }

    public Integer getCentralBankID() {
        return centralBankID;
    }

    public void setCentralBankID(Integer centralBankID) {
        this.centralBankID = centralBankID;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getRegulatoryCode() {
        return regulatoryCode;
    }

    public void setRegulatoryCode(String regulatoryCode) {
        this.regulatoryCode = regulatoryCode;
    }

    public BigDecimal getRiskThreshold() {
        return riskThreshold;
    }

    public void setRiskThreshold(BigDecimal riskThreshold) {
        this.riskThreshold = riskThreshold;
    }

    public String getMonitoringLevel() {
        return monitoringLevel;
    }

    public void setMonitoringLevel(String monitoringLevel) {
        this.monitoringLevel = monitoringLevel;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (centralBankID != null ? centralBankID.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Centralbank)) {
            return false;
        }
        Centralbank other = (Centralbank) object;
        if ((this.centralBankID == null && other.centralBankID != null) || (this.centralBankID != null && !this.centralBankID.equals(other.centralBankID))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.mycompany.banksystem.Centralbank[ centralBankID=" + centralBankID + " ]";
    }
    
}
