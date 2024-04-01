#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG="applicant"
P0PORT=7051
CAPORT=7054
PEERPEM=organizations/peerOrganizations/applicant.example.com/tlsca/tlsca.applicant.example.com-cert.pem
CAPEM=organizations/peerOrganizations/applicant.example.com/ca/ca.applicant.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/applicant.example.com/connection-applicant.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/applicant.example.com/connection-applicant.yaml

ORG="verifierA"
P0PORT=9051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/verifierA.example.com/tlsca/tlsca.verifierA.example.com-cert.pem
CAPEM=organizations/peerOrganizations/verifierA.example.com/ca/ca.verifierA.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/verifierA.example.com/connection-verifierA.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/verifierA.example.com/connection-verifierA.yaml

ORG="verifierB"
P0PORT=11051
CAPORT=11054
PEERPEM=organizations/peerOrganizations/verifierB.example.com/tlsca/tlsca.verifierB.example.com-cert.pem
CAPEM=organizations/peerOrganizations/verifierB.example.com/ca/ca.verifierB.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/verifierB.example.com/connection-verifierB.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/verifierB.example.com/connection-verifierB.yaml