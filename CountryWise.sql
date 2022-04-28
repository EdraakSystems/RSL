USE [CS_RSL_2019]
GO

/****** Object:  View [dbo].[CountryWiseReport_pbi]    Script Date: 16/03/2022 3:07:29 pm ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[CountryWiseReport_pbi] as  select ovp.*,customers.Country,CityName from vuOverallPerformance ovp inner join Customers customers on customers.CustCode=ovp.CustCode 
GO

