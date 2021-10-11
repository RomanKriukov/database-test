
CREATE DATABASE Storehouse;
GO

USE Storehouse;

CREATE TABLE Contracts
(
	Id INT PRIMARY KEY IDENTITY,
	Number INT,
	DateOfConclusion DATE,
	ExpirationDate DATE,
	Contractor NVARCHAR(50),
	Culture NVARCHAR(50),
	Quantity INT,
	Price INT
);

CREATE TABLE RemainingGoods
(
	Id INT PRIMARY KEY IDENTITY,
	NameCulture NVARCHAR(50),
	Storage INT,
	OnTheDate DATE,
	Price INT,
	Quantity INT
);

CREATE TABLE ShipmentOfGoods
(
	Id INT PRIMARY KEY IDENTITY,
	ContractNumber INT,
	Storage INT,
	ShippingDate DATE,
	Quantity INT,
	CurrentProfit INT
)