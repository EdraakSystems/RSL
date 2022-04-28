USE [CS_RSL_2022]
GO

/****** Object:  View [dbo].[principle_containerwise_report]    Script Date: 16/03/2022 3:05:37 pm ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[principle_containerwise_report] as
 SELECT cntwise.*,psetup.Name as PrincipleOROwner from CS_RSL_2022.dbo.ContainerWiseReport cntwise				
	INNER JOIN Ctrack_RSL_ISOTank.dbo.Containers nvccCont on nvccCont.CntNo=cntwise.ContainerNumb				
	INNER Join Ctrack_RSL_ISOTank.dbo.PrincipleSetup psetup on psetup.PKID=nvccCont.PrincipleID
GO

