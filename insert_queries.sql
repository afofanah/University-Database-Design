-- =============================================
-- Sample Data Insertion
-- =============================================

-- Insert sample departments
INSERT INTO Department (DepartmentName, DepartmentCode, BudgetAmount, EstablishedDate, BuildingName, PhoneNumber, Email)
VALUES 
('Computer Science', 'CS', 2500000.00, '1975-09-01', 'Tech Building', '555-1234', 'cs@university.edu'),
('Mathematics', 'MATH', 1800000.00, '1950-09-01', 'Science Hall', '555-2345', 'math@university.edu'),
('Biology', 'BIO', 2200000.00, '1960-09-01', 'Life Sciences', '555-3456', 'bio@university.edu'),
('English', 'ENG', 1500000.00, '1940-09-01', 'Humanities Building', '555-4567', 'english@university.edu'),
('Physics', 'PHY', 2000000.00, '1955-09-01', 'Science Hall', '555-5678', 'physics@university.edu');

-- Insert sample buildings
INSERT INTO Building (BuildingName, BuildingCode, TotalFloors, YearBuilt, Address, PhoneNumber, FacilityManagerName, TotalClassrooms, TotalOffices, TotalStudySpaces)
VALUES 
('Tech Building', 'TECH', 5, 1995, '123 University Dr', '555-1111', 'John Smith', 25, 50, 10),
('Science Hall', 'SCI', 4, 1980, '124 University Dr', '555-2222', 'Sarah Johnson', 20, 40, 8),
('Life Sciences', 'LIFE', 3, 2005, '125 University Dr', '555-3333', 'Michael Brown', 15, 30, 6),
('Humanities Building', 'HUM', 4, 1970, '126 University Dr', '555-4444', 'Emma Davis', 22, 45, 12),
('Library', 'LIB', 6, 2000, '127 University Dr', '555-5555', 'David Wilson', 5, 20, 30);

-- Insert sample faculty
INSERT INTO Faculty (FirstName, LastName, DateOfBirth, Gender, Email, PhoneNumber, HireDate, Salary, DepartmentID, Title, IsFullTime, EmergencyContact, OfficeLocation)
VALUES 
('Robert', 'Smith', '1975-05-15', 'M', 'rsmith@university.edu', '555-1122', '2010-08-15', 95000.00, 1, 'Professor', 1, 'Jane Smith 555-1123', 'TECH 301'),
('Linda', 'Johnson', '1980-07-20', 'F', 'ljohnson@university.edu', '555-2233', '2012-08-15', 85000.00, 2, 'Associate Professor', 1, 'Tom Johnson 555-2234', 'SCI 201'),
('Michael', 'Williams', '1982-03-10', 'M', 'mwilliams@university.edu', '555-3344', '2015-08-15', 75000.00, 3, 'Assistant Professor', 1, 'Susan Williams 555-3345', 'LIFE 101'),
('Elizabeth', 'Brown', '1979-11-25', 'F', 'ebrown@university.edu', '555-4455', '2011-08-15', 90000.00, 4, 'Professor', 1, 'John Brown 555-4456', 'HUM 401'),
('David', 'Jones', '1985-09-30', 'M', 'djones@university.edu', '555-5566', '2018-08-15', 72000.00, 5, 'Assistant Professor', 1, 'Mary Jones 555-5567', 'SCI 301');

-- Insert sample staff members
INSERT INTO StaffMember (FirstName, LastName, DateOfBirth, Gender, Email, PhoneNumber, HireDate, Salary, DepartmentID, Position, IsFullTime, SupervisorID, OfficeLocation, EmergencyContact)
VALUES 
('Patricia', 'Davis', '1982-04-12', 'F', 'pdavis@university.edu', '555-6677', '2015-01-10', 60000.00, 1, 'Administrative Assistant', 1, NULL, 'TECH 100', 'William Davis 555-6678'),
('James', 'Miller', '1979-08-22', 'M', 'jmiller@university.edu', '555-7788', '2012-03-15', 65000.00, 2, 'Lab Coordinator', 1, NULL, 'SCI 100', 'Lisa Miller 555-7789'),
('Jennifer', 'Wilson', '1988-12-05', 'F', 'jwilson@university.edu', '555-8899', '2017-06-01', 55000.00, 3, 'Research Assistant', 1, NULL, 'LIFE 110', 'Robert Wilson 555-8890'),
('Thomas', 'Anderson', '1975-02-18', 'M', 'tanderson@university.edu', '555-9900', '2010-07-15', 75000.00, 4, 'Department Manager', 1, NULL, 'HUM 100', 'Karen Anderson 555-9901'),
('Sarah', 'Taylor', '1990-07-30', 'F', 'staylor@university.edu', '555-0011', '2019-09-01', 52000.00, 5, 'Lab Technician', 1, NULL, 'SCI 110', 'Mark Taylor 555-0012');

