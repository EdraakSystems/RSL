USE [CS_RSL_2022]
GO

/****** Object:  View [dbo].[detentionwise_report]    Script Date: 16/03/2022 3:04:50 pm ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[detentionwise_report] as select sij.JobNumber,cust.FullName Agent,invmaster.INVOICENO,invmaster.INVDATE,nvccCont.CntNo,sizes.CntrSizeDesc,psetup.Name as Principle,sap.PortName as LoadingPort,invdet.*
from ADDON_INVMASTER invmaster 
inner join [ADDON_INVDETENTION] invdet on invdet.INVNO=invmaster.INVNO
inner join Customers cust on cust.CustCode=invmaster.CUSTCODE
inner join SIJobMaster SIJ on SIJ.TransNumber=invmaster.JOBTRANSNO
inner join SIRouting sirout on sirout.TransNumber=invmaster.JOBTRANSNO
inner join SeaAirPort sap on sap.PortCode=sirout.LoadingPort
INNER JOIN SIContainerInfo sicont on sicont.Transnumber=SIJ.TransNumber
INNER JOIN Ctrack_RSL_ISOTank.dbo.Containers nvccCont on nvccCont.CntNo=sicont.ContainerNumb
INNER Join Ctrack_RSL_ISOTank.dbo.PrincipleSetup psetup on psetup.PKID=nvccCont.PrincipleID
inner join Ctrack_RSL_ISOTank.dbo.CntrSizes sizes on sizes.CntrSizeID=nvccCont.cntSize
where Amount>0

GO

