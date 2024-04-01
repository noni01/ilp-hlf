'use strict';

const { Contract } = require ('fabric-contract-api');

class InnerLinePermit extends Contract {

    async initLedger(ctx) {
        console.info('Initializing Ledger');

        const applicants = [
            {
                applicantId: 'applicant123',
                name: 'John Das',
                age: 30,
                address: '123 Main Assam, Guwahati, India',
                nationality: 'India',
                passportNumber: 'ABC123XYZ',
                purposeOfVisit: 'Tourism',
                dateOfApplication: '2024-03-28'
            },
            // Add more dummy applicant data here if needed
        ];

        for (let i = 0; i < applicants.length; i++) {
            applicants[i].status = 'Pending';
            applicants[i].verifierA = '';
            applicants[i].verifierB = '';
            await ctx.stub.putState(applicants[i].applicantId, Buffer.from(JSON.stringify(applicants[i])));
            console.info('Added', applicants[i]);
        }
    }

    async applyForPermit(ctx, applicantId, details) {
        // Check if applicant exists
        let applicantExists = await this.userExists(ctx, applicantId);
        if (!applicantExists) {
            throw new Error(`Applicant with ID ${applicantId} does not exist.`);
        }

        // Add permit application
        let permitApplication = {
            applicant: applicantId,
            details: details,
            status: 'Pending', // Permit status: Pending/Approved/Rejected
            verifierA: '',
            verifierB: ''
        };

        // Store permit application in the ledger
        await ctx.stub.putState(applicantId, Buffer.from(JSON.stringify(permitApplication)));
        console.info('Permit Application submitted by Applicant ID:', applicantId);
        return permitApplication;
    }

    async verifyPermit(ctx, verifierId, applicantId, status) {
        // Check if verifier exists
        let verifierExists = await this.userExists(ctx, verifierId);
        if (!verifierExists) {
            throw new Error(`Verifier with ID ${verifierId} does not exist.`);
        }

        // Get permit application from the ledger
        let permitApplicationAsBytes = await ctx.stub.getState(applicantId);
        if (!permitApplicationAsBytes || permitApplicationAsBytes.length === 0) {
            throw new Error(`Permit Application with ID ${applicantId} does not exist.`);
        }
        let permitApplication = JSON.parse(permitApplicationAsBytes.toString());

        // Update permit status based on verifier's decision
        if (status === 'Approved') {
            if (verifierId === 'verifierA') {
                permitApplication.verifierA = verifierId;
            } else if (verifierId === 'verifierB') {
                permitApplication.verifierB = verifierId;
            }
            // If both verifiers approve, change status to Approved
            if (permitApplication.verifierA !== '' && permitApplication.verifierB !== '') {
                permitApplication.status = 'Approved';
            }
        } else if (status === 'Rejected') {
            permitApplication.status = 'Rejected';
        } else {
            throw new Error(`Invalid status: ${status}. Status must be either 'Approved' or 'Rejected'.`);
        }

        // Update permit application in the ledger
        await ctx.stub.putState(applicantId, Buffer.from(JSON.stringify(permitApplication)));
        console.info(`Permit Application verified by ${verifierId}. Status: ${status}`);
        return permitApplication;
    }

    async userExists(ctx, userId) {
        // Check if user exists in the ledger
        let userAsBytes = await ctx.stub.getState(userId);
        return (!!userAsBytes && userAsBytes.length > 0);
    }

}

module.exports = InnerLinePermit;
