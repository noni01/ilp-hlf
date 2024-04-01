#!/bin/bash

function createapplicant() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/applicant.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/applicant.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-applicant --tls.certfiles "${PWD}/organizations/fabric-ca/applicant/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-applicant.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-applicant.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-applicant.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-applicant.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/applicant.example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy applicant's CA cert to applicant's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/applicant.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/applicant/ca-cert.pem" "${PWD}/organizations/peerOrganizations/applicant.example.com/msp/tlscacerts/ca.crt"

  # Copy applicant's CA cert to applicant's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/applicant.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/applicant/ca-cert.pem" "${PWD}/organizations/peerOrganizations/applicant.example.com/tlsca/tlsca.applicant.example.com-cert.pem"

  # Copy applicant's CA cert to applicant's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/applicant.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/applicant/ca-cert.pem" "${PWD}/organizations/peerOrganizations/applicant.example.com/ca/ca.applicant.example.com-cert.pem"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-applicant --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/applicant/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-applicant --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/applicant/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-applicant --id.name applicantadmin --id.secret applicantadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/applicant/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-applicant -M "${PWD}/organizations/peerOrganizations/applicant.example.com/peers/peer0.applicant.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/applicant/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/applicant.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/applicant.example.com/peers/peer0.applicant.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-applicant -M "${PWD}/organizations/peerOrganizations/applicant.example.com/peers/peer0.applicant.example.com/tls" --enrollment.profile tls --csr.hosts peer0.applicant.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/applicant/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/applicant.example.com/peers/peer0.applicant.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/applicant.example.com/peers/peer0.applicant.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/applicant.example.com/peers/peer0.applicant.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/applicant.example.com/peers/peer0.applicant.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/applicant.example.com/peers/peer0.applicant.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/applicant.example.com/peers/peer0.applicant.example.com/tls/server.key"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-applicant -M "${PWD}/organizations/peerOrganizations/applicant.example.com/users/User1@applicant.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/applicant/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/applicant.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/applicant.example.com/users/User1@applicant.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://applicantadmin:applicantadminpw@localhost:7054 --caname ca-applicant -M "${PWD}/organizations/peerOrganizations/applicant.example.com/users/Admin@applicant.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/applicant/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/applicant.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/applicant.example.com/users/Admin@applicant.example.com/msp/config.yaml"
}

function createverifierA() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/verifierA.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/verifierA.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-verifierA --tls.certfiles "${PWD}/organizations/fabric-ca/verifierA/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-verifierA.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-verifierA.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-verifierA.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-verifierA.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/verifierA.example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy verifierA's CA cert to verifierA's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/verifierA.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/verifierA/ca-cert.pem" "${PWD}/organizations/peerOrganizations/verifierA.example.com/msp/tlscacerts/ca.crt"

  # Copy verifierA's CA cert to verifierA's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/verifierA.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/verifierA/ca-cert.pem" "${PWD}/organizations/peerOrganizations/verifierA.example.com/tlsca/tlsca.verifierA.example.com-cert.pem"

  # Copy verifierA's CA cert to verifierA's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/verifierA.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/verifierA/ca-cert.pem" "${PWD}/organizations/peerOrganizations/verifierA.example.com/ca/ca.verifierA.example.com-cert.pem"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-verifierA --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/verifierA/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-verifierA --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/verifierA/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-verifierA --id.name verifierAadmin --id.secret verifierAadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/verifierA/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-verifierA -M "${PWD}/organizations/peerOrganizations/verifierA.example.com/peers/peer0.verifierA.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/verifierA/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/verifierA.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/verifierA.example.com/peers/peer0.verifierA.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-verifierA -M "${PWD}/organizations/peerOrganizations/verifierA.example.com/peers/peer0.verifierA.example.com/tls" --enrollment.profile tls --csr.hosts peer0.verifierA.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/verifierA/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/verifierA.example.com/peers/peer0.verifierA.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/verifierA.example.com/peers/peer0.verifierA.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/verifierA.example.com/peers/peer0.verifierA.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/verifierA.example.com/peers/peer0.verifierA.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/verifierA.example.com/peers/peer0.verifierA.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/verifierA.example.com/peers/peer0.verifierA.example.com/tls/server.key"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-verifierA -M "${PWD}/organizations/peerOrganizations/verifierA.example.com/users/User1@verifierA.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/verifierA/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/verifierA.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/verifierA.example.com/users/User1@verifierA.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://verifierAadmin:verifierAadminpw@localhost:8054 --caname ca-verifierA -M "${PWD}/organizations/peerOrganizations/verifierA.example.com/users/Admin@verifierA.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/verifierA/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/verifierA.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/verifierA.example.com/users/Admin@verifierA.example.com/msp/config.yaml"
}
function createverifierB() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/verifierB.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/verifierB.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11054 --caname ca-verifierB --tls.certfiles "${PWD}/organizations/fabric-ca/verifierB/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-verifierB.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-verifierB.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-verifierB.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-verifierB.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/verifierB.example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy verifierB's CA cert to verifierB's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/verifierB.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/verifierB/ca-cert.pem" "${PWD}/organizations/peerOrganizations/verifierB.example.com/msp/tlscacerts/ca.crt"

  # Copy verifierB's CA cert to verifierB's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/verifierB.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/verifierB/ca-cert.pem" "${PWD}/organizations/peerOrganizations/verifierB.example.com/tlsca/tlsca.verifierB.example.com-cert.pem"

  # Copy verifierB's CA cert to verifierB's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/verifierB.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/verifierB/ca-cert.pem" "${PWD}/organizations/peerOrganizations/verifierB.example.com/ca/ca.verifierB.example.com-cert.pem"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-verifierB --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/verifierB/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-verifierB --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/verifierB/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-verifierB --id.name verifierBadmin --id.secret verifierBadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/verifierB/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-verifierB -M "${PWD}/organizations/peerOrganizations/verifierB.example.com/peers/peer0.verifierB.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/verifierB/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/verifierB.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/verifierB.example.com/peers/peer0.verifierB.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-verifierB -M "${PWD}/organizations/peerOrganizations/verifierB.example.com/peers/peer0.verifierB.example.com/tls" --enrollment.profile tls --csr.hosts peer0.verifierB.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/verifierB/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/verifierB.example.com/peers/peer0.verifierB.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/verifierB.example.com/peers/peer0.verifierB.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/verifierB.example.com/peers/peer0.verifierB.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/verifierB.example.com/peers/peer0.verifierB.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/verifierB.example.com/peers/peer0.verifierB.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/verifierB.example.com/peers/peer0.verifierB.example.com/tls/server.key"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:11054 --caname ca-verifierB -M "${PWD}/organizations/peerOrganizations/verifierB.example.com/users/User1@verifierB.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/verifierB/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/verifierB.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/verifierB.example.com/users/User1@verifierB.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://verifierBadmin:verifierBadminpw@localhost:11054 --caname ca-verifierB -M "${PWD}/organizations/peerOrganizations/verifierB.example.com/users/Admin@verifierB.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/verifierB/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/verifierB.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/verifierB.example.com/users/Admin@verifierB.example.com/msp/config.yaml"
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy orderer org's CA cert to orderer org's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  # Copy orderer org's CA cert to orderer org's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml"

  infoln "Generating the orderer-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls" --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key"

  # Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml"
}