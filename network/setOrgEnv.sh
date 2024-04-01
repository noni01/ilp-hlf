#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0




# default to using applicant
ORG=${1:-applicant}

# Exit on first error, print all commands.
set -e
set -o pipefail

# Where am I?
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

ORDERER_CA=${DIR}/network/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
PEER0_applicant_CA=${DIR}/network/organizations/peerOrganizations/applicant.example.com/tlsca/tlsca.applicant.example.com-cert.pem
PEER0_verifierA_CA=${DIR}/network/organizations/peerOrganizations/verifierA.example.com/tlsca/tlsca.verifierA.example.com-cert.pem
PEER0_verifierB_CA=${DIR}/network/organizations/peerOrganizations/verifierB.example.com/tlsca/tlsca.verifierB.example.com-cert.pem


if [[ ${ORG,,} == "applicant" || ${ORG,,} == "digibank" ]]; then

   CORE_PEER_LOCALMSPID=applicantMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/network/organizations/peerOrganizations/applicant.example.com/users/Admin@applicant.example.com/msp
   CORE_PEER_ADDRESS=localhost:7051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/network/organizations/peerOrganizations/applicant.example.com/tlsca/tlsca.applicant.example.com-cert.pem

elif [[ ${ORG,,} == "verifierA" || ${ORG,,} == "magnetocorp" ]]; then

   CORE_PEER_LOCALMSPID=verifierAMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/network/organizations/peerOrganizations/verifierA.example.com/users/Admin@verifierA.example.com/msp
   CORE_PEER_ADDRESS=localhost:9051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/network/organizations/peerOrganizations/verifierA.example.com/tlsca/tlsca.verifierA.example.com-cert.pem

else
   echo "Unknown \"$ORG\", please choose applicant/Digibank or verifierA/Magnetocorp"
   echo "For example to get the environment variables to set upa verifierA shell environment run:  ./setOrgEnv.sh verifierA"
   echo
   echo "This can be automated to set them as well with:"
   echo
   echo 'export $(./setOrgEnv.sh verifierA | xargs)'
   exit 1
fi

# output the variables that need to be set
echo "CORE_PEER_TLS_ENABLED=true"
echo "ORDERER_CA=${ORDERER_CA}"
echo "PEER0_applicant_CA=${PEER0_applicant_CA}"
echo "PEER0_verifierA_CA=${PEER0_verifierA_CA}"
echo "PEER0_verifierB_CA=${PEER0_verifierB_CA}"

echo "CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH}"
echo "CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS}"
echo "CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE}"

echo "CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID}"