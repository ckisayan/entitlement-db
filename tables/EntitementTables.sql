--drop table dbo.EntitledSystem 
CREATE TABLE dbo.EntitledSystem (
    SystemId INT PRIMARY KEY,
    EntitledSystemShortDescription NVARCHAR(255),
    EntitledSystemLongDescription NVARCHAR(500)
);

CREATE TABLE dbo.ObjectTypes (
    ObjectTypeID INT PRIMARY KEY,
    ObjectTypeShortDescription NVARCHAR(255),
	ObjectTypeLongDescription NVARCHAR(500),
	SystemId INT ,
	FOREIGN KEY (SystemID) REFERENCES EntitledSystem(SystemID),
);
--delete dbo.EntitledSystem 
INSERT INTO dbo.EntitledSystem (SystemId, EntitledSystemShortDescription, EntitledSystemLongDescription)
VALUES
    (1, 'System A', 'This is the short and long description for System A.'),
    (2, 'System B', 'This is the short and long description for System B.'),
    (3, 'System C', 'This is the short and long description for System C.');

-- Insert data into ObjectTypes table
--truncate table dbo.ObjectTypes 
INSERT INTO dbo.ObjectTypes (ObjectTypeID, ObjectTypeShortDescription, ObjectTypeLongDescription, SystemId)
VALUES
    (101, 'User Dashboard X', 'This is the short and long description for Type X.', 1),
    (102, 'Parts Screen Y', 'This is the short and long description for Type Y.', 1),
    (103, 'Monthly Revenue Report Z', 'This is the short and long description for Type Z.', 2),
    (104, 'Type W', 'This is the short and long description for Type W.', 2),
    (105, 'Type Q', 'This is the short and long description for Type Q.', 3);

-- Verify the data
SELECT * FROM dbo.EntitledSystem;
SELECT * FROM ObjectTypes;

drop table dbo.MockAzureAD 
CREATE TABLE dbo.MockAzureAD (
	FakeAzureAD_ID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	FirstName varchar(100),
	LastName varchar(100),
	EmailAddress varchar(200),
	UserID varchar(200) UNIQUE,
	HR_DefinedRole varchar(100),
	HR_DefinedDepartment varchar(100)	
)


--drop table dbo.SystemUser 
Create Table dbo.SystemUser (
	SystemUserId INT PRIMARY KEY IDENTITY(1,1),
	FirstName varchar(100),
	LastName varchar(100),
	EmailAddress varchar(200),
	UserID varchar(200) UNIQUE,
	HR_DefinedRole varchar(100),
	HR_DefinedDepartment varchar(100),
	SystemId INT ,
	FOREIGN KEY (SystemID) REFERENCES EntitledSystem(SystemID)
)


-- Insert data into dbo.MockAzureAD matching by email address
truncate table dbo.MockAzureAD 
INSERT INTO dbo.MockAzureAD (FirstName, LastName, EmailAddress, UserID, HR_DefinedRole, HR_DefinedDepartment)
VALUES
    ('Alice', 'Johnson', 'alice.johnson@example.com', 'alicej', 'Manager', 'HR Department'),
    ('Bob', 'Williams', 'bob.williams@example.com', 'bobw', 'Developer', 'IT Department'),
    ('Eva', 'Brown', 'eva.brown@example.com', 'evab', 'Analyst', 'Finance Department'),
	('Emily', 'Davis', 'emily.davis@example.com', 'emilyd', 'Manager', 'HR Department'),
    ('James', 'Wilson', 'james.wilson@example.com', 'jamesw', 'Developer', 'IT Department'),
    ('Sophia', 'Miller', 'sophia.miller@example.com', 'sophiam', 'Analyst', 'Finance Department'),
    ('Daniel', 'Moore', 'daniel.moore@example.com', 'danielm', 'Designer', 'Design Department'),
    ('Olivia', 'Lee', 'olivia.lee@example.com', 'olivial', 'Coordinator', 'Admin Department');


INSERT INTO dbo.SystemUser (FirstName, LastName, EmailAddress, UserID, HR_DefinedRole, HR_DefinedDepartment, SystemId)
VALUES
    ('Alice', 'Johnson', 'alice.johnson@example.com', 'alicej', 'Manager', 'HR Department', 1),
    ('Bob', 'Williams', 'bob.williams@example.com', 'bobw', 'Developer', 'IT Department', 2),
    ('Eva', 'Brown', 'eva.brown@example.com', 'evab', 'Analyst', 'Finance Department', 3);


CREATE TABLE dbo.AccessType (
    AccessTypeID INT PRIMARY KEY,
    AccessTypeShortName NVARCHAR(100),
	AccessTypeLongDescription NVARCHAR(200)
);

INSERT INTO dbo.AccessType (AccessTypeID, AccessTypeShortName, AccessTypeLongDescription)
VALUES
    (1, 'VIEW', 'View access'),
    (2, 'CREATE', 'Create New access'),
    (3, 'EDIT', 'Edit access'),
    (4, 'DENY', 'Deny Access');


CREATE TABLE UserObjectAccess (
    SystemUserId INT,
    ObjectTypeID INT,
    AccessTypeID INT,
    PRIMARY KEY (SystemUserId, ObjectTypeID),
    FOREIGN KEY (SystemUserId) REFERENCES dbo.SystemUser(SystemUserId),
    FOREIGN KEY (ObjectTypeID) REFERENCES dbo.ObjectTypes(ObjectTypeID),
    FOREIGN KEY (AccessTypeID) REFERENCES dbo.AccessType(AccessTypeID)
);

INSERT INTO UserObjectAccess (SystemUserId, ObjectTypeID, AccessTypeID)
VALUES
    (1, 101, 1), -- User 1 has Read Only access to Object Type 1
    (1, 102, 2), -- User 1 has Read/Write access to Object Type 2
    (2, 101, 2), -- User 2 has Read/Write access to Object Type 1
    (2, 103, 3), -- User 2 has Admin access to Object Type 3
    (3, 104, 3), -- User 3 has Admin access to Object Type 4
    (3, 102, 4); -- User 3 has Custom Access to Object Type 2

CREATE TABLE SystemRoles (
    RoleID INT PRIMARY KEY,
    RoleName NVARCHAR(100),
    RoleDescription NVARCHAR(200)
);

-- Insert example data into SystemRoles table
INSERT INTO SystemRoles (RoleID, RoleName, RoleDescription)
VALUES
    (1, 'Admin', 'Administrator role with full access'),
    (2, 'Manager', 'Manager role with elevated privileges'),
    (3, 'User', 'Standard user role'),
    (4, 'Guest', 'Guest role with limited access');
CREATE TABLE SystemRoleAccess (
    RoleID INT,
    SystemID INT,
    AccessTypeID INT,
    ObjectTypeID INT,
    PRIMARY KEY (RoleID, SystemID, AccessTypeID, ObjectTypeID),
    FOREIGN KEY (RoleID) REFERENCES dbo.SystemRoles(RoleID),
    FOREIGN KEY (SystemID) REFERENCES dbo.EntitledSystem(SystemID),
    FOREIGN KEY (AccessTypeID) REFERENCES dbo.AccessType(AccessTypeID),
    FOREIGN KEY (ObjectTypeID) REFERENCES dbo.ObjectTypes(ObjectTypeID)
);
select * from dbo.SystemRoleAccess 
INSERT INTO dbo.SystemRoleAccess (RoleID, SystemID, AccessTypeID, ObjectTypeID)
VALUES
     -- Admin role has full access to System 1 with Read Only access.
    (1, 1, 1, 101),
    -- Admin role has full access to System 2 with Read/Write access.
    (1, 2, 2, 102),
    -- Manager role has Read/Write access to System 1.
    (2, 1, 2, 101),
    -- Manager role has Read/Write access to System 2.
    (2, 2, 2, 102),
    -- Manager role has Admin access to System 3.
    (2, 3, 3, 103),
    -- User role has Read Only access to System 1.
    (3, 1, 1, 101),
    -- User role has Read Only access to System 2.
    (3, 2, 1, 102),
    -- User role has Read Only access to System 3.
    (3, 3, 1, 103),    
	-- Guest role has Read Only access to System 2.
    (4, 2, 1, 102);






SELECT
    su.FirstName + ' ' + su.LastName AS UserName,
    et.EntitledSystemShortDescription AS SystemName,
    at.AccessTypeShortName AS AccessType,
    ot.ObjectTypeShortDescription AS ObjectType
FROM
    dbo.SystemUser su 
join dbo.UserObjectAccess uoa (nolock) on su.SystemUserId = uoa.SystemUserId 
JOIN    dbo.AccessType at ON uoa.AccessTypeID = at.AccessTypeID
JOIN    dbo.ObjectTypes ot ON uoa.ObjectTypeID = ot.ObjectTypeID
JOIN    dbo.EntitledSystem et ON su.SystemID = et.SystemID
WHERE   su.UserID = 'alicej';

--JOIN    SystemRoleAccess sra ON su.SystemUserId = sra.SystemUserId


