import React from 'react'
import { useState } from 'react';

export default function Navbar() {
    const [isOpen, setIsOpen] = useState(false);

  const toggleNavbar = () => {
    setIsOpen(!isOpen);
  };

  return (
    <nav className="bg-gray-800 p-4">
      <div className="container mx-auto flex justify-between items-center">
        <div className="flex items-center">
          <span className="text-white mr-4 font-semibold">InnerLinePermit</span>
        </div>
        <div className="hidden md:flex">
          <ul className="flex items-center">
            <li className="mr-6">
              <a href="#" className="text-white hover:text-gray-300">Home</a>
            </li>
            <li className="mr-6">
              <a href="#" className="text-white hover:text-gray-300">Apply ILP</a>
            </li>
            <li>
              <a href="#" className="text-white hover:text-gray-300">Status</a>
            </li>
          </ul>
        </div>
        <div className="md:hidden">
          <button onClick={toggleNavbar} className="text-white focus:outline-none">
            <svg
              className="w-6 h-6"
              fill="none"
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              {isOpen ? (
                <path d="M6 18L18 6M6 6l12 12"></path>
              ) : (
                <path d="M4 6h16M4 12h16m-7 6h7"></path>
              )}
            </svg>
          </button>
        </div>
      </div>
      {isOpen && (
        <div className="md:hidden mt-4">
          <ul className="flex flex-col items-center">
            <li className="mb-2">
              <a href="#" className="text-white hover:text-gray-300">Home</a>
            </li>
            <li className="mb-2">
              <a href="#" className="text-white hover:text-gray-300">Apply ILP</a>
            </li>
            <li>
              <a href="#" className="text-white hover:text-gray-300">Status</a>
            </li>
          </ul>
        </div>
      )}
    </nav>
  )
}
