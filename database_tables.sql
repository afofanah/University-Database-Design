
-- =============================================
-- University Database Schema and Queries
-- =============================================
-- Author: A.J. Fofanah (PhD)
-- Email: a.fofanah@griffith.edu.au or dmitripeter.fofanah@gmail.com
-- Description: 
-- A comprehensive SQL Server database solution for university management systems.
-- This implementation features 20 interconnected tables covering all aspects of 
-- university operations including student records, faculty management, course 
-- administration, research activities, and facility management. Includes 50 
-- optimized queries ranging from basic data retrieval to complex analytics,
-- along with stored procedures and security configurations for enterprise-level 
-- deployment. Designed for scalability, data integrity, and performance.
-- =============================================

-- Create the University Database
CREATE DATABASE University;
GO

-- Database structure and schema created by A.J. Fofanah (PhD)
-- A comprehensive SQL implementation for university management systems
-- This script includes tables, relationships, indexes, and sample queries
-- for effective university data management

USE University;
GO

-- =============================================
-- Table Structure (20 Tables)
-- =============================================

-- 1. Department Table
CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName VARCHAR(100) NOT NULL,
    DepartmentCode VARCHAR(10) NOT NULL UNIQUE,
    BudgetAmount DECIMAL(15,2) NOT NULL,
    EstablishedDate DATE NOT NULL,
    BuildingName VARCHAR(100),
    PhoneNumber VARCHAR(20),
    Email VARCHAR(100)
);

-- 2. Faculty Table
CREATE TABLE Faculty (
    FacultyID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE,
    Gender CHAR(1) CHECK (Gender IN ('M', 'F', 'O')),
    Email VARCHAR(100) UNIQUE,
    PhoneNumber VARCHAR(20),
    HireDate DATE NOT NULL,
    Salary DECIMAL(12,2) NOT NULL,
    DepartmentID INT FOREIGN KEY REFERENCES Department(DepartmentID),
    Title VARCHAR(50) NOT NULL,
    IsFullTime BIT DEFAULT 1,
    EmergencyContact VARCHAR(100),
    OfficeLocation VARCHAR(50)
);

-- 3. Student Table
CREATE TABLE Student (
    StudentID INT PRIMARY KEY IDENTITY(10000,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender CHAR(1) CHECK (Gender IN ('M', 'F', 'O')),
    Email VARCHAR(100) UNIQUE,
    PhoneNumber VARCHAR(20),
    EnrollmentDate DATE NOT NULL,
    GraduationDate DATE,
    MajorDepartmentID INT FOREIGN KEY REFERENCES Department(DepartmentID),
    MinorDepartmentID INT FOREIGN KEY REFERENCES Department(DepartmentID),
    GPA DECIMAL(3,2) CHECK (GPA BETWEEN 0.00 AND 4.00),
    Address VARCHAR(200),
    EmergencyContact VARCHAR(100),
    IsInternational BIT DEFAULT 0
);

-- 4. Course Table
CREATE TABLE Course (
    CourseID INT PRIMARY KEY IDENTITY(1,1),
    CourseCode VARCHAR(20) NOT NULL UNIQUE,
    CourseName VARCHAR(100) NOT NULL,
    Credits INT NOT NULL CHECK (Credits > 0),
    DepartmentID INT FOREIGN KEY REFERENCES Department(DepartmentID),
    Description TEXT,
    IsActive BIT DEFAULT 1,
    PrerequisiteCourseID INT FOREIGN KEY REFERENCES Course(CourseID),
    MaxStudents INT CHECK (MaxStudents > 0),
    CourseLevel VARCHAR(20) CHECK (CourseLevel IN ('Freshman', 'Sophomore', 'Junior', 'Senior', 'Graduate'))
);

-- 5. Section Table
CREATE TABLE Section (
    SectionID INT PRIMARY KEY IDENTITY(1,1),
    CourseID INT FOREIGN KEY REFERENCES Course(CourseID),
    SectionNumber VARCHAR(10) NOT NULL,
    Semester VARCHAR(20) NOT NULL,
    Year INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    BuildingName VARCHAR(50),
    RoomNumber VARCHAR(10),
    DaysOfWeek VARCHAR(10),
    StartTime TIME,
    EndTime TIME,
    MaxEnrollment INT NOT NULL,
    CONSTRAINT UQ_Section UNIQUE (CourseID, SectionNumber, Semester, Year)
);

-- 6. Enrollment Table
CREATE TABLE Enrollment (
    EnrollmentID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT FOREIGN KEY REFERENCES Student(StudentID),
    SectionID INT FOREIGN KEY REFERENCES Section(SectionID),
    EnrollmentDate DATE NOT NULL DEFAULT GETDATE(),
    Grade CHAR(2),
    GradePoints DECIMAL(3,2),
    IsWithdrawn BIT DEFAULT 0,
    WithdrawalDate DATE,
    CONSTRAINT UQ_Enrollment UNIQUE (StudentID, SectionID)
);

-- 7. Teaching Table
CREATE TABLE Teaching (
    TeachingID INT PRIMARY KEY IDENTITY(1,1),
    FacultyID INT FOREIGN KEY REFERENCES Faculty(FacultyID),
    SectionID INT FOREIGN KEY REFERENCES Section(SectionID),
    Role VARCHAR(50) DEFAULT 'Instructor',
    CONSTRAINT UQ_Teaching UNIQUE (FacultyID, SectionID)
);

-- 8. Building Table
CREATE TABLE Building (
    BuildingID INT PRIMARY KEY IDENTITY(1,1),
    BuildingName VARCHAR(100) NOT NULL UNIQUE,
    BuildingCode VARCHAR(10) NOT NULL UNIQUE,
    TotalFloors INT NOT NULL,
    YearBuilt INT,
    Address VARCHAR(200),
    PhoneNumber VARCHAR(20),
    FacilityManagerName VARCHAR(100),
    TotalClassrooms INT,
    TotalOffices INT,
    TotalStudySpaces INT
);

-- 9. Room Table
CREATE TABLE Room (
    RoomID INT PRIMARY KEY IDENTITY(1,1),
    BuildingID INT FOREIGN KEY REFERENCES Building(BuildingID),
    RoomNumber VARCHAR(10) NOT NULL,
    Capacity INT NOT NULL,
    RoomType VARCHAR(50) NOT NULL CHECK (RoomType IN ('Classroom', 'Laboratory', 'Office', 'Conference', 'Study Space', 'Auditorium')),
    HasProjector BIT DEFAULT 0,
    HasComputers BIT DEFAULT 0,
    HasWhiteboard BIT DEFAULT 0,
    IsAccessible BIT DEFAULT 1,
    FloorNumber INT NOT NULL,
    SquareFootage INT,
    CONSTRAINT UQ_Room UNIQUE (BuildingID, RoomNumber)
);

-- 10. Scholarship Table
CREATE TABLE Scholarship (
    ScholarshipID INT PRIMARY KEY IDENTITY(1,1),
    ScholarshipName VARCHAR(100) NOT NULL,
    Description TEXT,
    Amount DECIMAL(12,2) NOT NULL,
    DonorName VARCHAR(100),
    IsActive BIT DEFAULT 1,
    ApplicationDeadline DATE,
    MinimumGPA DECIMAL(3,2),
    DepartmentID INT FOREIGN KEY REFERENCES Department(DepartmentID),
    RequiredMajor BIT DEFAULT 0,
    MaximumAwardsPerYear INT
);

-- 11. StudentScholarship Table
CREATE TABLE StudentScholarship (
    StudentScholarshipID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT FOREIGN KEY REFERENCES Student(StudentID),
    ScholarshipID INT FOREIGN KEY REFERENCES Scholarship(ScholarshipID),
    AwardDate DATE NOT NULL,
    AwardAmount DECIMAL(12,2) NOT NULL,
    AcademicYear VARCHAR(20) NOT NULL,
    Semester VARCHAR(20) NOT NULL,
    IsRenewable BIT DEFAULT 0,
    ApplicationDate DATE,
    CONSTRAINT UQ_StudentScholarship UNIQUE (StudentID, ScholarshipID, AcademicYear, Semester)
);

-- 12. StaffMember Table
CREATE TABLE StaffMember (
    StaffID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE,
    Gender CHAR(1) CHECK (Gender IN ('M', 'F', 'O')),
    Email VARCHAR(100) UNIQUE,
    PhoneNumber VARCHAR(20),
    HireDate DATE NOT NULL,
    Salary DECIMAL(12,2) NOT NULL,
    DepartmentID INT FOREIGN KEY REFERENCES Department(DepartmentID),
    Position VARCHAR(100) NOT NULL,
    IsFullTime BIT DEFAULT 1,
    SupervisorID INT FOREIGN KEY REFERENCES StaffMember(StaffID),
    OfficeLocation VARCHAR(50),
    EmergencyContact VARCHAR(100)
);

-- 13. Event Table
CREATE TABLE Event (
    EventID INT PRIMARY KEY IDENTITY(1,1),
    EventName VARCHAR(100) NOT NULL,
    Description TEXT,
    StartDateTime DATETIME NOT NULL,
    EndDateTime DATETIME NOT NULL,
    BuildingID INT FOREIGN KEY REFERENCES Building(BuildingID),
    RoomID INT FOREIGN KEY REFERENCES Room(RoomID),
    OrganizerID INT,
    OrganizerType VARCHAR(20) CHECK (OrganizerType IN ('Staff', 'Faculty', 'Student', 'External')),
    AttendeeCapacity INT,
    RegistrationRequired BIT DEFAULT 0,
    RegistrationDeadline DATETIME,
    EventType VARCHAR(50),
    IsPublic BIT DEFAULT 1
);

-- 14. ResearchProject Table
CREATE TABLE ResearchProject (
    ProjectID INT PRIMARY KEY IDENTITY(1,1),
    ProjectName VARCHAR(200) NOT NULL,
    Description TEXT,
    StartDate DATE NOT NULL,
    EndDate DATE,
    FundingAmount DECIMAL(15,2),
    LeadFacultyID INT FOREIGN KEY REFERENCES Faculty(FacultyID),
    DepartmentID INT FOREIGN KEY REFERENCES Department(DepartmentID),
    Status VARCHAR(20) CHECK (Status IN ('Proposed', 'Active', 'Completed', 'Suspended', 'Cancelled')),
    FundingSource VARCHAR(100),
    ProjectGoals TEXT,
    LastUpdated DATETIME DEFAULT GETDATE()
);

-- 15. ResearchTeamMember Table
CREATE TABLE ResearchTeamMember (
    TeamMemberID INT PRIMARY KEY IDENTITY(1,1),
    ProjectID INT FOREIGN KEY REFERENCES ResearchProject(ProjectID),
    MemberID INT NOT NULL,
    MemberType VARCHAR(20) CHECK (MemberType IN ('Faculty', 'Student', 'Staff', 'External')),
    JoinDate DATE NOT NULL,
    LeaveDate DATE,
    Role VARCHAR(100) NOT NULL,
    TimeCommitmentPerWeek INT,
    Compensation DECIMAL(12,2),
    CONSTRAINT UQ_ResearchTeamMember UNIQUE (ProjectID, MemberID, MemberType)
);

-- 16. Publication Table
CREATE TABLE Publication (
    PublicationID INT PRIMARY KEY IDENTITY(1,1),
    Title VARCHAR(255) NOT NULL,
    Abstract TEXT,
    PublicationDate DATE,
    JournalName VARCHAR(200),
    Volume VARCHAR(20),
    Issue VARCHAR(20),
    Pages VARCHAR(20),
    DOI VARCHAR(100) UNIQUE,
    CitationCount INT DEFAULT 0,
    ProjectID INT FOREIGN KEY REFERENCES ResearchProject(ProjectID),
    PublicationType VARCHAR(50) CHECK (PublicationType IN ('Journal Article', 'Conference Paper', 'Book Chapter', 'Book', 'Technical Report', 'Thesis', 'Patent'))
);

-- 17. PublicationAuthor Table
CREATE TABLE PublicationAuthor (
    PublicationAuthorID INT PRIMARY KEY IDENTITY(1,1),
    PublicationID INT FOREIGN KEY REFERENCES Publication(PublicationID),
    AuthorID INT NOT NULL,
    AuthorType VARCHAR(20) CHECK (AuthorType IN ('Faculty', 'Student', 'Staff', 'External')),
    AuthorOrder INT NOT NULL,
    IsCorrespondingAuthor BIT DEFAULT 0,
    CONSTRAINT UQ_PublicationAuthor UNIQUE (PublicationID, AuthorID, AuthorType)
);

-- 18. Library Table
CREATE TABLE Library (
    LibraryID INT PRIMARY KEY IDENTITY(1,1),
    LibraryName VARCHAR(100) NOT NULL,
    BuildingID INT FOREIGN KEY REFERENCES Building(BuildingID),
    TotalCapacity INT NOT NULL,
    TotalBooks INT,
    TotalJournals INT,
    OpeningTime TIME,
    ClosingTime TIME,
    HeadLibrarianID INT FOREIGN KEY REFERENCES StaffMember(StaffID),
    EstablishedDate DATE,
    WebsiteURL VARCHAR(200)
);

-- 19. Book Table
CREATE TABLE Book (
    BookID INT PRIMARY KEY IDENTITY(1,1),
    LibraryID INT FOREIGN KEY REFERENCES Library(LibraryID),
    Title VARCHAR(255) NOT NULL,
    Author VARCHAR(255) NOT NULL,
    ISBN VARCHAR(20) UNIQUE,
    PublicationYear INT,
    Publisher VARCHAR(100),
    Category VARCHAR(50),
    Subcategory VARCHAR(50),
    TotalCopies INT NOT NULL DEFAULT 1,
    AvailableCopies INT NOT NULL DEFAULT 1,
    ShelfLocation VARCHAR(50),
    AcquisitionDate DATE,
    Price DECIMAL(10,2)
);

-- 20. BookLoan Table
CREATE TABLE BookLoan (
    LoanID INT PRIMARY KEY IDENTITY(1,1),
    BookID INT FOREIGN KEY REFERENCES Book(BookID),
    BorrowerID INT NOT NULL,
    BorrowerType VARCHAR(20) CHECK (BorrowerType IN ('Student', 'Faculty', 'Staff')),
    CheckoutDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    ReturnDate DATE,
    IsRenewed BIT DEFAULT 0,
    RenewalCount INT DEFAULT 0,
    LateFee DECIMAL(8,2) DEFAULT 0,
    LibrarianID INT FOREIGN KEY REFERENCES StaffMember(StaffID)
);

-- =============================================
-- Add Indexes for Performance
-- =============================================

CREATE INDEX IX_Faculty_DepartmentID ON Faculty(DepartmentID);
CREATE INDEX IX_Student_MajorDepartmentID ON Student(MajorDepartmentID);
CREATE INDEX IX_Course_DepartmentID ON Course(DepartmentID);
CREATE INDEX IX_Section_CourseID ON Section(CourseID);
CREATE INDEX IX_Enrollment_StudentID ON Enrollment(StudentID);
CREATE INDEX IX_Enrollment_SectionID ON Enrollment(SectionID);
CREATE INDEX IX_Teaching_FacultyID ON Teaching(FacultyID);
CREATE INDEX IX_Teaching_SectionID ON Teaching(SectionID);
CREATE INDEX IX_Room_BuildingID ON Room(BuildingID);
CREATE INDEX IX_StudentScholarship_StudentID ON StudentScholarship(StudentID);
CREATE INDEX IX_StudentScholarship_ScholarshipID ON StudentScholarship(ScholarshipID);
CREATE INDEX IX_StaffMember_DepartmentID ON StaffMember(DepartmentID);
CREATE INDEX IX_Event_BuildingID ON Event(BuildingID);
CREATE INDEX IX_Event_RoomID ON Event(RoomID);
CREATE INDEX IX_ResearchProject_LeadFacultyID ON ResearchProject(LeadFacultyID);
CREATE INDEX IX_ResearchProject_DepartmentID ON ResearchProject(DepartmentID);
CREATE INDEX IX_ResearchTeamMember_ProjectID ON ResearchTeamMember(ProjectID);
CREATE INDEX IX_Publication_ProjectID ON Publication(ProjectID);
CREATE INDEX IX_PublicationAuthor_PublicationID ON PublicationAuthor(PublicationID);
CREATE INDEX IX_Book_LibraryID ON Book(LibraryID);
CREATE INDEX IX_BookLoan_BookID ON BookLoan(BookID);

