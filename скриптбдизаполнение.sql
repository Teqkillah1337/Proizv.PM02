-- Create database
CREATE DATABASE UnifiedWindowSystem;
GO

USE UnifiedWindowSystem;
GO

-- Create tables for clients (individuals and legal entities)
CREATE TABLE ClientTypes (
    ClientTypeID INT PRIMARY KEY IDENTITY(1,1),
    TypeName NVARCHAR(50) NOT NULL
);

CREATE TABLE Clients (
    ClientID INT PRIMARY KEY IDENTITY(1,1),
    ClientTypeID INT NOT NULL,
    AccountNumber NVARCHAR(50),
    FullName NVARCHAR(100),
    INN NVARCHAR(20),
    OGRN NVARCHAR(20),
    EGRULDate DATE,
    PassportSeries NVARCHAR(10),
    PassportNumber NVARCHAR(10),
    PassportIssueDate DATE,
    BirthDate DATE,
    RegistrationAddress NVARCHAR(200),
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    PostalAddress NVARCHAR(200),
    BankDetails NVARCHAR(200),
    RepresentativeName NVARCHAR(100),
    PreferredContactMethod NVARCHAR(50),
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ClientTypeID) REFERENCES ClientTypes(ClientTypeID)
);

-- Create table for application types
CREATE TABLE ApplicationTypes (
    ApplicationTypeID INT PRIMARY KEY IDENTITY(1,1),
    TypeName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500)
);

-- Create table for application statuses
CREATE TABLE ApplicationStatuses (
    StatusID INT PRIMARY KEY IDENTITY(1,1),
    StatusName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(200)
);

-- Create main applications table
CREATE TABLE Applications (
    ApplicationID INT PRIMARY KEY IDENTITY(1,1),
    ClientID INT NOT NULL,
    ApplicationTypeID INT NOT NULL,
    StatusID INT NOT NULL,
    ObjectName NVARCHAR(100),
    ConstructionCode NVARCHAR(50),
    ApplicationReason NVARCHAR(200),
    Comments NVARCHAR(1000),
    CreationDate DATETIME DEFAULT GETDATE(),
    ModificationDate DATETIME,
    CompletionDate DATETIME,
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
    FOREIGN KEY (ApplicationTypeID) REFERENCES ApplicationTypes(ApplicationTypeID),
    FOREIGN KEY (StatusID) REFERENCES ApplicationStatuses(StatusID)
);

-- Create table for departments
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(100) NOT NULL,
    Abbreviation NVARCHAR(10),
    Description NVARCHAR(500)
);

-- Create table for document types
CREATE TABLE DocumentTypes (
    DocumentTypeID INT PRIMARY KEY IDENTITY(1,1),
    TypeName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500)
);

-- Create table for documents
CREATE TABLE Documents (
    DocumentID INT PRIMARY KEY IDENTITY(1,1),
    ApplicationID INT NOT NULL,
    DocumentTypeID INT NOT NULL,
    FilePath NVARCHAR(500),
    IsAttached BIT DEFAULT 0,
    CreationDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ApplicationID) REFERENCES Applications(ApplicationID),
    FOREIGN KEY (DocumentTypeID) REFERENCES DocumentTypes(DocumentTypeID)
);

-- Create table for application workflow
CREATE TABLE ApplicationWorkflow (
    WorkflowID INT PRIMARY KEY IDENTITY(1,1),
    ApplicationID INT NOT NULL,
    FromDepartmentID INT,
    ToDepartmentID INT NOT NULL,
    StatusID INT NOT NULL,
    ActionDate DATETIME DEFAULT GETDATE(),
    Comments NVARCHAR(1000),
    ProcessingDeadline INT, -- in days
    DeadlineDate DATETIME,
    IsCompleted BIT DEFAULT 0,
    CompletionDate DATETIME,
    FOREIGN KEY (ApplicationID) REFERENCES Applications(ApplicationID),
    FOREIGN KEY (FromDepartmentID) REFERENCES Departments(DepartmentID),
    FOREIGN KEY (ToDepartmentID) REFERENCES Departments(DepartmentID),
    FOREIGN KEY (StatusID) REFERENCES ApplicationStatuses(StatusID)
);

-- Create table for technical conditions
CREATE TABLE TechnicalConditions (
    ConditionID INT PRIMARY KEY IDENTITY(1,1),
    ApplicationID INT NOT NULL,
    DocumentID INT,
    ConditionsText NVARCHAR(MAX),
    IsApproved BIT DEFAULT 0,
    ApprovalDate DATETIME,
    ApprovedBy NVARCHAR(100),
    FOREIGN KEY (ApplicationID) REFERENCES Applications(ApplicationID),
    FOREIGN KEY (DocumentID) REFERENCES Documents(DocumentID)
);

-- Create table for connection contracts
CREATE TABLE ConnectionContracts (
    ContractID INT PRIMARY KEY IDENTITY(1,1),
    ApplicationID INT NOT NULL,
    DocumentID INT,
    ContractNumber NVARCHAR(50),
    ContractDate DATE,
    ConnectionCost DECIMAL(18,2),
    IsSigned BIT DEFAULT 0,
    SignDate DATETIME,
    IsCompleted BIT DEFAULT 0,
    CompletionDate DATETIME,
    FOREIGN KEY (ApplicationID) REFERENCES Applications(ApplicationID),
    FOREIGN KEY (DocumentID) REFERENCES Documents(DocumentID)
);

-- Create table for additional agreements
CREATE TABLE AdditionalAgreements (
    AgreementID INT PRIMARY KEY IDENTITY(1,1),
    ContractID INT NOT NULL,
    DocumentID INT,
    AgreementType NVARCHAR(50),
    AgreementDate DATE,
    IsSigned BIT DEFAULT 0,
    SignDate DATETIME,
    FOREIGN KEY (ContractID) REFERENCES ConnectionContracts(ContractID),
    FOREIGN KEY (DocumentID) REFERENCES Documents(DocumentID)
);

-- Create table for construction projects
CREATE TABLE ConstructionProjects (
    ProjectID INT PRIMARY KEY IDENTITY(1,1),
    ApplicationID INT NOT NULL,
    DocumentID INT,
    ProjectName NVARCHAR(100),
    ProjectCost DECIMAL(18,2),
    StartDate DATE,
    PlannedEndDate DATE,
    ActualEndDate DATE,
    IsCompleted BIT DEFAULT 0,
    CompletionDate DATETIME,
    FOREIGN KEY (ApplicationID) REFERENCES Applications(ApplicationID),
    FOREIGN KEY (DocumentID) REFERENCES Documents(DocumentID)
);

-- Create table for gas connection acts
CREATE TABLE GasConnectionActs (
    ActID INT PRIMARY KEY IDENTITY(1,1),
    ApplicationID INT NOT NULL,
    DocumentID INT,
    ActNumber NVARCHAR(50),
    ActDate DATE,
    ConnectionDate DATE,
    IsSigned BIT DEFAULT 0,
    SignDate DATETIME,
    FOREIGN KEY (ApplicationID) REFERENCES Applications(ApplicationID),
    FOREIGN KEY (DocumentID) REFERENCES Documents(DocumentID)
);

-- Create table for notifications
CREATE TABLE Notifications (
    NotificationID INT PRIMARY KEY IDENTITY(1,1),
    ApplicationID INT NOT NULL,
    NotificationType NVARCHAR(50),
    NotificationText NVARCHAR(1000),
    NotificationDate DATETIME DEFAULT GETDATE(),
    IsSent BIT DEFAULT 0,
    SentDate DATETIME,
    Recipient NVARCHAR(100),
    ContactMethod NVARCHAR(50),
    FOREIGN KEY (ApplicationID) REFERENCES Applications(ApplicationID)
);

-- Create table for users/employees
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) NOT NULL,
    Password NVARCHAR(100) NOT NULL,
    FullName NVARCHAR(100) NOT NULL,
    DepartmentID INT,
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    IsActive BIT DEFAULT 1,
    LastLogin DATETIME,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- Create table for user roles
CREATE TABLE Roles (
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(200)
);

-- Create table for user-role assignments
CREATE TABLE UserRoles (
    UserRoleID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    RoleID INT NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);

-- Create table for permissions
CREATE TABLE Permissions (
    PermissionID INT PRIMARY KEY IDENTITY(1,1),
    PermissionName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(200)
);

-- Create table for role-permission assignments
CREATE TABLE RolePermissions (
    RolePermissionID INT PRIMARY KEY IDENTITY(1,1),
    RoleID INT NOT NULL,
    PermissionID INT NOT NULL,
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID),
    FOREIGN KEY (PermissionID) REFERENCES Permissions(PermissionID)
);

-- Create table for reporting
CREATE TABLE Reports (
    ReportID INT PRIMARY KEY IDENTITY(1,1),
    ReportName NVARCHAR(100) NOT NULL,
    DepartmentID INT,
    Frequency NVARCHAR(50),
    DueDay INT,
    DueMonth INT,
    TemplatePath NVARCHAR(500),
    Description NVARCHAR(500),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- Create table for report instances
CREATE TABLE ReportInstances (
    InstanceID INT PRIMARY KEY IDENTITY(1,1),
    ReportID INT NOT NULL,
    ReportingPeriod DATE,
    GeneratedDate DATETIME DEFAULT GETDATE(),
    GeneratedBy INT,
    FilePath NVARCHAR(500),
    IsSubmitted BIT DEFAULT 0,
    SubmittedDate DATETIME,
    FOREIGN KEY (ReportID) REFERENCES Reports(ReportID),
    FOREIGN KEY (GeneratedBy) REFERENCES Users(UserID)
);

-- Create table for deadlines configuration
CREATE TABLE ProcessingDeadlines (
    DeadlineID INT PRIMARY KEY IDENTITY(1,1),
    ApplicationTypeID INT,
    DepartmentID INT,
    DocumentTypeID INT,
    StandardDeadline INT NOT NULL, -- in days
    Description NVARCHAR(500),
    FOREIGN KEY (ApplicationTypeID) REFERENCES ApplicationTypes(ApplicationTypeID),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID),
    FOREIGN KEY (DocumentTypeID) REFERENCES DocumentTypes(DocumentTypeID)
);

-- Create table for audit logs
CREATE TABLE AuditLogs (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT,
    ActionDate DATETIME DEFAULT GETDATE(),
    ActionType NVARCHAR(50),
    TableName NVARCHAR(50),
    RecordID INT,
    OldValue NVARCHAR(MAX),
    NewValue NVARCHAR(MAX),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Insert initial data for client types
INSERT INTO ClientTypes (TypeName) VALUES 
('Физическое лицо'),
('Юридическое лицо'),
('Индивидуальный предприниматель');

-- Insert initial data for application types
INSERT INTO ApplicationTypes (TypeName, Description) VALUES 
('Заявка на подключение', 'Заявка на технологическое присоединение к газораспределительным сетям'),
('Запрос на выдачу ТУ', 'Запрос на получение технических условий подключения'),
('Запрос на выполнение расчетов максимального часового расхода газа', 'Запрос на выполнение расчетов потребления газа');

-- Insert initial data for application statuses
INSERT INTO ApplicationStatuses (StatusName, Description) VALUES 
('На регистрации', 'Заявка зарегистрирована, но еще не обрабатывается'),
('В работе', 'Заявка находится в обработке'),
('Рассматривается', 'Заявка рассматривается соответствующим отделом'),
('Одобрена', 'Заявка одобрена для дальнейшей обработки'),
('Отказ', 'Заявка отклонена'),
('Готово', 'Заявка полностью обработана и завершена'),
('Аннулировано', 'Заявка отменена заявителем');

-- Insert initial data for departments
INSERT INTO Departments (DepartmentName, Abbreviation, Description) VALUES 
('Служба по работе с заявителями', 'СРЗ', 'Первичный прием и обработка заявок'),
('Производственно-технический отдел', 'ПТО', 'Определение технических возможностей подключения'),
('Проектно-сметный отдел', 'ПСО', 'Разработка проектов и смет'),
('Отдел капитального строительства', 'ОКС', 'Реализация строительных проектов'),
('Юридический отдел', 'ЮО', 'Подготовка договоров и юридическое сопровождение'),
('Центральная диспетчерская служба', 'ЦДС', 'Координация работ и пуска газа'),
('Отдел расчетов населения за газ', 'ОРГ', 'Начисление оплаты за услуги'),
('Отдел инвестиций', NULL, 'Управление инвестиционными проектами'),
('Финансовый отдел', NULL, 'Финансовый учет и контроль');

-- Insert initial data for document types
INSERT INTO DocumentTypes (TypeName, Description) VALUES 
('Заявление', 'Официальное заявление клиента'),
('Паспорт', 'Копия паспорта заявителя'),
('Договор', 'Договор на подключение'),
('Технические условия', 'Технические условия подключения'),
('Проектная документация', 'Проектно-сметная документация'),
('Акт выполненных работ', 'Акт о выполнении строительных работ'),
('Акт на пуск газа', 'Акт о вводе объекта в эксплуатацию'),
('Дополнительное соглашение', 'Дополнительное соглашение к договору'),
('Платежный документ', 'Документ об оплате услуг'),
('Отчет', 'Официальный отчет для контролирующих органов');

-- Insert initial data for processing deadlines (sample data)
INSERT INTO ProcessingDeadlines (ApplicationTypeID, DepartmentID, DocumentTypeID, StandardDeadline, Description) VALUES 
(1, 1, 1, 1, 'Первичная обработка заявки в СРЗ'),
(1, 2, 3, 5, 'Подготовка технических условий в ПТО'),
(1, 3, 5, 14, 'Разработка проектной документации в ПСО'),
(1, 4, 6, 30, 'Выполнение строительных работ ОКС'),
(1, 5, 3, 3, 'Подготовка договора в ЮО'),
(2, 1, 1, 1, 'Первичная обработка запроса ТУ в СРЗ'),
(2, 2, 4, 1, 'Подготовка ТУ в ПТО');

-- Insert sample roles
INSERT INTO Roles (RoleName, Description) VALUES 
('Администратор', 'Полный доступ ко всем функциям системы'),
('Оператор СРЗ', 'Служба по работе с заявителями - первичная обработка заявок'),
('Специалист ПТО', 'Производственно-технический отдел - технические условия'),
('Специалист ПСО', 'Проектно-сметный отдел - разработка проектов'),
('Специалист ОКС', 'Отдел капитального строительства - реализация проектов'),
('Юрист', 'Юридический отдел - подготовка договоров'),
('Диспетчер ЦДС', 'Центральная диспетчерская служба - координация работ'),
('Бухгалтер', 'Финансовый отдел - учет платежей'),
('Менеджер ОРГ', 'Отдел расчетов населения за газ - начисление оплаты');

-- Insert sample permissions
INSERT INTO Permissions (PermissionName, Description) VALUES 
('ViewApplications', 'Просмотр заявок'),
('CreateApplications', 'Создание новых заявок'),
('EditApplications', 'Редактирование заявок'),
('DeleteApplications', 'Удаление заявок'),
('ProcessApplications', 'Обработка заявок'),
('ApproveApplications', 'Утверждение заявок'),
('RejectApplications', 'Отклонение заявок'),
('ViewReports', 'Просмотр отчетов'),
('GenerateReports', 'Генерация отчетов'),
('ManageUsers', 'Управление пользователями'),
('ManageRoles', 'Управление ролями'),
('ManageSystem', 'Управление системными настройками');

-- Assign permissions to roles
-- Admin has all permissions
INSERT INTO RolePermissions (RoleID, PermissionID)
SELECT r.RoleID, p.PermissionID 
FROM Roles r, Permissions p
WHERE r.RoleName = 'Администратор';

-- Operator permissions
INSERT INTO RolePermissions (RoleID, PermissionID)
SELECT r.RoleID, p.PermissionID 
FROM Roles r, Permissions p
WHERE r.RoleName = 'Оператор СРЗ' 
AND p.PermissionName IN ('ViewApplications', 'CreateApplications', 'EditApplications', 'ProcessApplications');

-- PTO specialist permissions
INSERT INTO RolePermissions (RoleID, PermissionID)
SELECT r.RoleID, p.PermissionID 
FROM Roles r, Permissions p
WHERE r.RoleName = 'Специалист ПТО' 
AND p.PermissionName IN ('ViewApplications', 'ProcessApplications', 'ApproveApplications', 'RejectApplications');

-- PSO specialist permissions
INSERT INTO RolePermissions (RoleID, PermissionID)
SELECT r.RoleID, p.PermissionID 
FROM Roles r, Permissions p
WHERE r.RoleName = 'Специалист ПСО' 
AND p.PermissionName IN ('ViewApplications', 'ProcessApplications', 'ApproveApplications', 'RejectApplications');

-- OCS specialist permissions
INSERT INTO RolePermissions (RoleID, PermissionID)
SELECT r.RoleID, p.PermissionID 
FROM Roles r, Permissions p
WHERE r.RoleName = 'Специалист ОКС' 
AND p.PermissionName IN ('ViewApplications', 'ProcessApplications', 'ApproveApplications', 'RejectApplications');

-- Lawyer permissions
INSERT INTO RolePermissions (RoleID, PermissionID)
SELECT r.RoleID, p.PermissionID 
FROM Roles r, Permissions p
WHERE r.RoleName = 'Юрист' 
AND p.PermissionName IN ('ViewApplications', 'ProcessApplications', 'ApproveApplications', 'RejectApplications');

-- CDS dispatcher permissions
INSERT INTO RolePermissions (RoleID, PermissionID)
SELECT r.RoleID, p.PermissionID 
FROM Roles r, Permissions p
WHERE r.RoleName = 'Диспетчер ЦДС' 
AND p.PermissionName IN ('ViewApplications', 'ProcessApplications', 'ApproveApplications');

-- Accountant permissions
INSERT INTO RolePermissions (RoleID, PermissionID)
SELECT r.RoleID, p.PermissionID 
FROM Roles r, Permissions p
WHERE r.RoleName = 'Бухгалтер' 
AND p.PermissionName IN ('ViewApplications', 'ViewReports', 'GenerateReports');

-- ORG manager permissions
INSERT INTO RolePermissions (RoleID, PermissionID)
SELECT r.RoleID, p.PermissionID 
FROM Roles r, Permissions p
WHERE r.RoleName = 'Менеджер ОРГ' 
AND p.PermissionName IN ('ViewApplications', 'ProcessApplications', 'ViewReports', 'GenerateReports');

-- Insert sample users with departments
-- Department IDs: 1-СРЗ, 2-ПТО, 3-ПСО, 4-ОКС, 5-ЮО, 6-ЦДС, 7-ОРГ, 8-Отдел инвестиций, 9-Финансовый отдел

-- Admin user
INSERT INTO Users (Username, Password, FullName, DepartmentID, Email, Phone)
VALUES ('admin', 'admin123', 'Иванов Иван Иванович', NULL, 'admin@gazprom.ru', '+79001234567');

-- SRZ operators
INSERT INTO Users (Username, Password, FullName, DepartmentID, Email, Phone)
VALUES 
('operator1', 'operator1', 'Петрова Анна Сергеевна', 1, 'petrova@gazprom.ru', '+79001234568'),
('operator2', 'operator2', 'Сидоров Дмитрий Владимирович', 1, 'sidorov@gazprom.ru', '+79001234569');

-- PTO specialists
INSERT INTO Users (Username, Password, FullName, DepartmentID, Email, Phone)
VALUES 
('pto1', 'pto1123', 'Кузнецов Андрей Николаевич', 2, 'kuznetsov@gazprom.ru', '+79001234570'),
('pto2', 'pto2123', 'Смирнова Елена Викторовна', 2, 'smirnova@gazprom.ru', '+79001234571');

-- PSO specialists
INSERT INTO Users (Username, Password, FullName, DepartmentID, Email, Phone)
VALUES 
('pso1', 'pso1123', 'Васильев Павел Олегович', 3, 'vasilev@gazprom.ru', '+79001234572'),
('pso2', 'pso2123', 'Николаева Марина Игоревна', 3, 'nikolaeva@gazprom.ru', '+79001234573');

-- OCS specialists
INSERT INTO Users (Username, Password, FullName, DepartmentID, Email, Phone)
VALUES 
('ocs1', 'ocs1123', 'Федоров Сергей Александрович', 4, 'fedorov@gazprom.ru', '+79001234574'),
('ocs2', 'ocs2123', 'Морозова Ольга Дмитриевна', 4, 'morozova@gazprom.ru', '+79001234575');

-- Lawyers
INSERT INTO Users (Username, Password, FullName, DepartmentID, Email, Phone)
VALUES 
('lawyer1', 'lawyer1123', 'Алексеев Игорь Борисович', 5, 'alekseev@gazprom.ru', '+79001234576'),
('lawyer2', 'lawyer2123', 'Белова Татьяна Викторовна', 5, 'belova@gazprom.ru', '+79001234577');

-- CDS dispatchers
INSERT INTO Users (Username, Password, FullName, DepartmentID, Email, Phone)
VALUES 
('cds1', 'cds1123', 'Григорьев Артем Сергеевич', 6, 'grigoriev@gazprom.ru', '+79001234578'),
('cds2', 'cds2123', 'Ковалева Юлия Андреевна', 6, 'kovaleva@gazprom.ru', '+79001234579');

-- Accountants
INSERT INTO Users (Username, Password, FullName, DepartmentID, Email, Phone)
VALUES 
('accountant1', 'accountant1123', 'Павлов Денис Олегович', 9, 'pavlov@gazprom.ru', '+79001234580'),
('accountant2', 'accountant2123', 'Семенова Анастасия Игоревна', 9, 'semenova@gazprom.ru', '+79001234581');

-- ORG managers
INSERT INTO Users (Username, Password, FullName, DepartmentID, Email, Phone)
VALUES 
('org1', 'org1123', 'Тихонов Максим Владимирович', 7, 'tihonov@gazprom.ru', '+79001234582'),
('org2', 'org2123', 'Зайцева Екатерина Сергеевна', 7, 'zaitseva@gazprom.ru', '+79001234583');

-- Assign roles to users
-- Admin has all roles (for testing purposes)
INSERT INTO UserRoles (UserID, RoleID)
SELECT u.UserID, r.RoleID 
FROM Users u, Roles r
WHERE u.Username = 'admin';

-- Assign roles to SRZ operators
INSERT INTO UserRoles (UserID, RoleID)
SELECT u.UserID, r.RoleID 
FROM Users u, Roles r
WHERE u.Username IN ('operator1', 'operator2') AND r.RoleName = 'Оператор СРЗ';

-- Assign roles to PTO specialists
INSERT INTO UserRoles (UserID, RoleID)
SELECT u.UserID, r.RoleID 
FROM Users u, Roles r
WHERE u.Username IN ('pto1', 'pto2') AND r.RoleName = 'Специалист ПТО';

-- Assign roles to PSO specialists
INSERT INTO UserRoles (UserID, RoleID)
SELECT u.UserID, r.RoleID 
FROM Users u, Roles r
WHERE u.Username IN ('pso1', 'pso2') AND r.RoleName = 'Специалист ПСО';

-- Assign roles to OCS specialists
INSERT INTO UserRoles (UserID, RoleID)
SELECT u.UserID, r.RoleID 
FROM Users u, Roles r
WHERE u.Username IN ('ocs1', 'ocs2') AND r.RoleName = 'Специалист ОКС';

-- Assign roles to lawyers
INSERT INTO UserRoles (UserID, RoleID)
SELECT u.UserID, r.RoleID 
FROM Users u, Roles r
WHERE u.Username IN ('lawyer1', 'lawyer2') AND r.RoleName = 'Юрист';

-- Assign roles to CDS dispatchers
INSERT INTO UserRoles (UserID, RoleID)
SELECT u.UserID, r.RoleID 
FROM Users u, Roles r
WHERE u.Username IN ('cds1', 'cds2') AND r.RoleName = 'Диспетчер ЦДС';

-- Assign roles to accountants
INSERT INTO UserRoles (UserID, RoleID)
SELECT u.UserID, r.RoleID 
FROM Users u, Roles r
WHERE u.Username IN ('accountant1', 'accountant2') AND r.RoleName = 'Бухгалтер';

-- Assign roles to ORG managers
INSERT INTO UserRoles (UserID, RoleID)
SELECT u.UserID, r.RoleID 
FROM Users u, Roles r
WHERE u.Username IN ('org1', 'org2') AND r.RoleName = 'Менеджер ОРГ';

-- Insert sample clients (individuals, legal entities, entrepreneurs)
-- Individual clients
INSERT INTO Clients (ClientTypeID, AccountNumber, FullName, PassportSeries, PassportNumber, PassportIssueDate, 
                     BirthDate, RegistrationAddress, Phone, Email, PostalAddress, RepresentativeName, PreferredContactMethod)
VALUES 
(1, 'IND0001', 'Смирнов Алексей Петрович', '4501', '123456', '2010-05-15', '1980-03-22', 
 'г. Киров, ул. Ленина, д. 10, кв. 5', '+79001112233', 'smirnov@mail.ru', 'г. Киров, ул. Ленина, д. 10, кв. 5', 
 'Иванова Мария Сергеевна', 'Email'),
(1, 'IND0002', 'Козлова Елена Викторовна', '4502', '234567', '2012-07-20', '1975-11-10', 
 'г. Киров, ул. Советская, д. 25, кв. 12', '+79002223344', 'kozlova@mail.ru', 'г. Киров, ул. Советская, д. 25, кв. 12', 
 'Петров Сергей Иванович', 'Телефон'),
(1, 'IND0003', 'Новиков Дмитрий Александрович', '4503', '345678', '2015-03-10', '1985-08-15', 
 'г. Киров, ул. Московская, д. 5, кв. 7', '+79003334455', 'novikov@mail.ru', 'г. Киров, ул. Московская, д. 5, кв. 7', 
 'Сидорова Анна Дмитриевна', 'SMS');

-- Legal entities
INSERT INTO Clients (ClientTypeID, AccountNumber, FullName, INN, OGRN, EGRULDate, 
                     RegistrationAddress, Phone, Email, PostalAddress, BankDetails, RepresentativeName, PreferredContactMethod)
VALUES 
(2, 'LEG0001', 'ООО "СтройГазКомплект"', '4345001234', '1024300000123', '2005-10-12', 
 'г. Киров, ул. Производственная, д. 15', '+78332654321', 'info@sgk.ru', 'г. Киров, ул. Производственная, д. 15', 
 'Р/с 40702810500000001234 в ПАО "Сбербанк", БИК 043304612', 'Генеральный директор Волков Андрей Николаевич', 'Email'),
(2, 'LEG0002', 'АО "Кировский мясокомбинат"', '4345005678', '1024300000456', '1998-04-25', 
 'г. Киров, ул. Промышленная, д. 30', '+78332658765', 'office@kmk.ru', 'г. Киров, ул. Промышленная, д. 30', 
 'Р/с 40702810500000005678 в ПАО "ВТБ", БИК 044525187', 'Директор по развитию Семенова Ольга Викторовна', 'Телефон');

-- Individual entrepreneurs
INSERT INTO Clients (ClientTypeID, AccountNumber, FullName, INN, OGRN, EGRULDate, PassportSeries, PassportNumber, PassportIssueDate, 
                     BirthDate, RegistrationAddress, Phone, Email, PostalAddress, BankDetails, RepresentativeName, PreferredContactMethod)
VALUES 
(3, 'IP0001', 'ИП Соколов Роман Игоревич', '4345112233', '3044300000123', '2010-02-18', '4504', '456789', '2009-11-05', 
 '1978-09-30', 'г. Киров, ул. Труда, д. 8, кв. 3', '+79004445566', 'sokolov.ip@mail.ru', 'г. Киров, ул. Труда, д. 8, кв. 3', 
 'Р/с 40802810500000001234 в ПАО "Сбербанк", БИК 043304612', NULL, 'Email'),
(3, 'IP0002', 'ИП Захарова Анна Михайловна', '4345113344', '3044300000456', '2015-07-22', '4505', '567890', '2014-12-10', 
 '1982-04-15', 'г. Киров, ул. Садовая, д. 12, кв. 9', '+79005556677', 'zakharova.ip@mail.ru', 'г. Киров, ул. Садовая, д. 12, кв. 9', 
 'Р/с 40802810500000005678 в ПАО "ВТБ", БИК 044525187', NULL, 'SMS');

-- Insert sample applications
-- Application statuses: 1-На регистрации, 2-В работе, 3-Рассматривается, 4-Одобрена, 5-Отказ, 6-Готово, 7-Аннулировано

-- Application for connection (individual)
INSERT INTO Applications (ClientID, ApplicationTypeID, StatusID, ObjectName, ConstructionCode, ApplicationReason, Comments, ModificationDate)
VALUES 
(1, 1, 2, 'Частный дом', 'RES-001', 'Подключение к газораспределительной сети', 'Необходимо подключение газа для отопления жилого дома', GETDATE()),
(2, 1, 3, 'Квартира', 'RES-002', 'Подключение к газораспределительной сети', 'Подключение газа для плиты в новой квартире', GETDATE()),
(3, 1, 4, 'Дачный дом', 'RES-003', 'Подключение к газораспределительной сети', 'Подключение газа для отопления дачного дома', GETDATE());

-- Application for connection (legal entities)
INSERT INTO Applications (ClientID, ApplicationTypeID, StatusID, ObjectName, ConstructionCode, ApplicationReason, Comments, ModificationDate)
VALUES 
(4, 1, 2, 'Производственный цех', 'COM-001', 'Подключение к газораспределительной сети', 'Подключение газа для производственных нужд', GETDATE()),
(5, 1, 5, 'Административное здание', 'COM-002', 'Подключение к газораспределительной сети', 'Отказ из-за отсутствия технической возможности', GETDATE());

-- Application for connection (entrepreneurs)
INSERT INTO Applications (ClientID, ApplicationTypeID, StatusID, ObjectName, ConstructionCode, ApplicationReason, Comments, ModificationDate)
VALUES 
(6, 1, 6, 'Кафе', 'COM-003', 'Подключение к газораспределительной сети', 'Подключение газа для кухни кафе', GETDATE()),
(7, 1, 1, 'Автосервис', 'COM-004', 'Подключение к газораспределительной сети', 'Подключение газа для покрасочной камеры', NULL);

-- Applications for technical conditions
INSERT INTO Applications (ClientID, ApplicationTypeID, StatusID, ObjectName, ConstructionCode, ApplicationReason, Comments, ModificationDate)
VALUES 
(1, 2, 6, 'Частный дом', 'RES-001', 'Получение технических условий', 'Получение ТУ для проектирования газоснабжения', GETDATE()),
(4, 2, 4, 'Производственный цех', 'COM-001', 'Получение технических условий', 'Получение ТУ для проектирования газоснабжения цеха', GETDATE());

-- Applications for gas consumption calculations
INSERT INTO Applications (ClientID, ApplicationTypeID, StatusID, ObjectName, ConstructionCode, ApplicationReason, Comments, ModificationDate)
VALUES 
(2, 3, 2, 'Квартира', 'RES-002', 'Расчет максимального часового расхода газа', 'Расчет для подбора оборудования', GETDATE()),
(6, 3, 3, 'Кафе', 'COM-003', 'Расчет максимального часового расхода газа', 'Расчет для коммерческой кухни', GETDATE());

-- Insert sample documents
-- Document types: 1-Заявление, 2-Паспорт, 3-Договор, 4-Технические условия, 5-Проектная документация, 
-- 6-Акт выполненных работ, 7-Акт на пуск газа, 8-Дополнительное соглашение, 9-Платежный документ, 10-Отчет

-- Documents for application 1 (individual connection)
INSERT INTO Documents (ApplicationID, DocumentTypeID, FilePath, IsAttached)
VALUES 
(1, 1, '\\server\docs\app1\statement.pdf', 1),
(1, 2, '\\server\docs\app1\passport_scan.pdf', 1),
(1, 3, '\\server\docs\app1\contract.pdf', 0),
(1, 4, '\\server\docs\app1\technical_conditions.pdf', 0);

-- Documents for application 4 (legal entity connection)
INSERT INTO Documents (ApplicationID, DocumentTypeID, FilePath, IsAttached)
VALUES 
(4, 1, '\\server\docs\app4\statement.pdf', 1),
(4, 3, '\\server\docs\app4\contract.pdf', 0),
(4, 4, '\\server\docs\app4\technical_conditions.pdf', 1),
(4, 5, '\\server\docs\app4\project_docs.pdf', 0);

-- Documents for application 6 (entrepreneur connection - completed)
INSERT INTO Documents (ApplicationID, DocumentTypeID, FilePath, IsAttached)
VALUES 
(6, 1, '\\server\docs\app6\statement.pdf', 1),
(6, 3, '\\server\docs\app6\contract.pdf', 1),
(6, 4, '\\server\docs\app6\technical_conditions.pdf', 1),
(6, 5, '\\server\docs\app6\project_docs.pdf', 1),
(6, 6, '\\server\docs\app6\work_certificate.pdf', 1),
(6, 7, '\\server\docs\app6\gas_start_act.pdf', 1),
(6, 9, '\\server\docs\app6\payment.pdf', 1);

-- Insert sample application workflow
-- Application 1 workflow
INSERT INTO ApplicationWorkflow (ApplicationID, FromDepartmentID, ToDepartmentID, StatusID, ActionDate, Comments, ProcessingDeadline, DeadlineDate, IsCompleted, CompletionDate)
VALUES 
(1, NULL, 1, 1, DATEADD(day, -10, GETDATE()), 'Заявка зарегистрирована оператором', 1, DATEADD(day, -9, GETDATE()), 1, DATEADD(day, -9, GETDATE())),
(1, 1, 2, 2, DATEADD(day, -9, GETDATE()), 'Заявка передана в ПТО для проверки', 5, DATEADD(day, -4, GETDATE()), 1, DATEADD(day, -4, GETDATE())),
(1, 2, 3, 3, DATEADD(day, -4, GETDATE()), 'Заявка передана в ПСО для разработки проекта', 14, DATEADD(day, 10, GETDATE()), 0, NULL);

-- Application 6 workflow (completed)
INSERT INTO ApplicationWorkflow (ApplicationID, FromDepartmentID, ToDepartmentID, StatusID, ActionDate, Comments, ProcessingDeadline, DeadlineDate, IsCompleted, CompletionDate)
VALUES 
(6, NULL, 1, 1, DATEADD(day, -60, GETDATE()), 'Заявка зарегистрирована оператором', 1, DATEADD(day, -59, GETDATE()), 1, DATEADD(day, -59, GETDATE())),
(6, 1, 2, 2, DATEADD(day, -59, GETDATE()), 'Заявка передана в ПТО для проверки', 5, DATEADD(day, -54, GETDATE()), 1, DATEADD(day, -54, GETDATE())),
(6, 2, 3, 3, DATEADD(day, -54, GETDATE()), 'Заявка передана в ПСО для разработки проекта', 14, DATEADD(day, -40, GETDATE()), 1, DATEADD(day, -40, GETDATE())),
(6, 3, 4, 4, DATEADD(day, -40, GETDATE()), 'Проект передан в ОКС для реализации', 30, DATEADD(day, -10, GETDATE()), 1, DATEADD(day, -10, GETDATE())),
(6, 4, 6, 6, DATEADD(day, -10, GETDATE()), 'Объект передан в ЦДС для пуска газа', 5, DATEADD(day, -5, GETDATE()), 1, DATEADD(day, -5, GETDATE())),
(6, 6, 7, 6, DATEADD(day, -5, GETDATE()), 'Акт пуска газа передан в ОРГ', 1, DATEADD(day, -4, GETDATE()), 1, DATEADD(day, -4, GETDATE()));

-- Insert sample technical conditions
INSERT INTO TechnicalConditions (ApplicationID, DocumentID, ConditionsText, IsApproved, ApprovalDate, ApprovedBy)
VALUES 
(1, 4, '1. Давление газа на точке подключения - 0,3 МПа. 2. Максимальный часовой расход - 5 м³/ч. 3. Требования к газовому оборудованию...', 1, DATEADD(day, -5, GETDATE()), 'Кузнецов А.Н.'),
(6, 12, '1. Давление газа на точке подключения - 0,6 МПа. 2. Максимальный часовой расход - 25 м³/ч. 3. Требования к газовому оборудованию...', 1, DATEADD(day, -55, GETDATE()), 'Смирнова Е.В.');

-- Insert sample connection contracts
INSERT INTO ConnectionContracts (ApplicationID, DocumentID, ContractNumber, ContractDate, ConnectionCost, IsSigned, SignDate, IsCompleted, CompletionDate)
VALUES 
(1, 3, 'ДГ-2023-001', DATEADD(day, -6, GETDATE()), 50000.00, 0, NULL, 0, NULL),
(6, 10, 'ДГ-2023-002', DATEADD(day, -56, GETDATE()), 250000.00, 1, DATEADD(day, -55, GETDATE()), 1, DATEADD(day, -5, GETDATE()));

-- Insert sample construction projects
INSERT INTO ConstructionProjects (ApplicationID, DocumentID, ProjectName, ProjectCost, StartDate, PlannedEndDate, ActualEndDate, IsCompleted, CompletionDate)
VALUES 
(6, 13, 'Газоснабжение кафе "Уют"', 300000.00, DATEADD(day, -40, GETDATE()), DATEADD(day, -10, GETDATE()), DATEADD(day, -10, GETDATE()), 1, DATEADD(day, -10, GETDATE()));

-- Insert sample gas connection acts
INSERT INTO GasConnectionActs (ApplicationID, DocumentID, ActNumber, ActDate, ConnectionDate, IsSigned, SignDate)
VALUES 
(6, 14, 'АПГ-2023-001', DATEADD(day, -5, GETDATE()), DATEADD(day, -5, GETDATE()), 1, DATEADD(day, -5, GETDATE()));

-- Insert sample notifications
INSERT INTO Notifications (ApplicationID, NotificationType, NotificationText, NotificationDate, IsSent, SentDate, Recipient, ContactMethod)
VALUES 
(1, 'StatusChange', 'Ваша заявка №1 переведена в статус "В работе"', DATEADD(day, -9, GETDATE()), 1, DATEADD(day, -9, GETDATE()), 'Смирнов А.П.', 'Email'),
(6, 'Completion', 'Ваша заявка №6 завершена. Газ успешно подключен.', DATEADD(day, -5, GETDATE()), 1, DATEADD(day, -5, GETDATE()), 'Соколов Р.И.', 'SMS'),
(5, 'Rejection', 'Ваша заявка №5 отклонена. Причина: отсутствие технической возможности.', DATEADD(day, -3, GETDATE()), 1, DATEADD(day, -3, GETDATE()), 'ООО "СтройГазКомплект"', 'Email');

-- Insert sample reports
INSERT INTO Reports (ReportName, DepartmentID, Frequency, DueDay, DueMonth, TemplatePath, Description)
VALUES 
('Отчет по заключенным договорам', 1, 'Monthly', 5, NULL, '\\server\templates\contracts_report.xlsx', 'Ежемесячный отчет по заключенным договорам на подключение'),
('Отчет ФАС договоры', 2, 'Monthly', 10, NULL, '\\server\templates\fas_contracts.xlsx', 'Ежемесячный отчет для ФАС по договорам'),
('Отчет ФАС ТУП', 2, 'Monthly', 10, NULL, '\\server\templates\fas_tup.xlsx', 'Ежемесячный отчет для ФАС по техническим условиям'),
('Количество договоров', 5, 'Weekly', NULL, NULL, '\\server\templates\contracts_count.docx', 'Еженедельный отчет по количеству договоров'),
('Период работ', 6, 'Monthly', NULL, NULL, '\\server\templates\work_periods.docx', 'Ежемесячный отчет по проведенным работам');

-- Insert sample audit logs
INSERT INTO AuditLogs (UserID, ActionType, TableName, RecordID, OldValue, NewValue)
VALUES 
(11, 'Create', 'Applications', 1, NULL, 'Заявка создана'),
(11, 'Update', 'Applications', 1, 'StatusID=1', 'StatusID=2'),
(3, 'Update', 'Applications', 1, 'StatusID=2', 'StatusID=3'),
(15, 'Create', 'Documents', 1, NULL, 'Документ добавлен'),
(15, 'Update', 'Documents', 3, 'IsAttached=0', 'IsAttached=1');