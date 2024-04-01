import React from "react";

export default function MainContent() {
  return (
    <div className="main-content container px-4 md:px-32">
      <div className="content-heading text-3xl md:text-4xl font-bold text-gray-800 font-barlow">
        Why Choose Us?
      </div>
      <div className="content mt-6 md:pl-11">
        <ul>
          <li className="mb-4 md:mb-6">
            Efficiency: Our platform streamlines the permit application process,
            saving you time and hassle.
          </li>
          <li className="mb-4 md:mb-6">
            Security: Utilizing blockchain technology, we ensure the highest
            level of security for your personal data and permit information.
          </li>
          <li className="mb-4 md:mb-6">
            Accessibility: Apply for your Inner Line Permit anytime, anywhere,
            with our user-friendly online platform.
          </li>
          <li className="mb-4 md:mb-6">
            Transparency: Track the status of your permit application in
            real-time, providing you with peace of mind throughout the process.
          </li>
        </ul>
      </div>
    </div>
  );
}
